#!/bin/bash
#
# patch_uboot_env.sh
#
# 修改 uboot 分区镜像内默认环境变量 bootcmd，生成补丁后的镜像
#
#   原 bootcmd: boot_android ${devtype} ${devnum};boot_fit;bootrkp;run distro_bootcmd;
#   新 bootcmd: sysboot <dev> any 0x00c00000 /extlinux/extlinux.conf
#               <dev> 默认 mmc 0:a，可用 --dev 指定（如 --dev "mmc 0:7"）
#
# 实现方式：Z96A 的 uboot 分区 (mmcblk2p2) 是 FIT 镜像，默认环境变量以原始
# NUL 分隔的 key=value 字符串直接嵌在 U-Boot 二进制里，且有两份冗余副本
# （相差 0x200000）。直接对 bootcmd 字符串做等长替换（尾部补空格），不改变
# 文件大小与任何偏移。
#
# 关键：SPL 加载 FIT 时会校验 images/uboot 的 hash 节点（sha256），改 bootcmd
# 后该 hash 失效，会报 "Bad hash value for 'hash' hash node in 'uboot' image
# node" 并拒绝启动。因此本脚本在替换 bootcmd 后，会重新解析 FIT 描述，对每个
# FIT 副本重算 images/uboot 数据的 sha256 并回写到 hash 节点（等长 32 字节）。
#
# 用法:
#   ./patch_uboot_env.sh                                     # 使用默认路径
#   ./patch_uboot_env.sh <input.img> [output.img]
#   ./patch_uboot_env.sh --dev "mmc 0:a"                     # 指定 sysboot 目标设备/分区
#   ./patch_uboot_env.sh --help
#
# 默认:
#   输入 : backup/Z96A-TYPEC/partitions/uboot_mmcblk2p2.img
#   输出 : ./uboot_patched.img
#   --dev: mmc 0:a
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------- 参数解析 ----------
DEV="mmc 0:a"
INPUT=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            sed -n '2,/^set -euo/p' "$0" | sed 's/^# \?//' | sed '$d'
            exit 0
            ;;
        --dev|-d)
            [[ $# -ge 2 ]] || { echo "错误: $1 需要一个参数，如 \"mmc 0:a\"" >&2; exit 1; }
            DEV="$2"
            shift 2
            ;;
        -*)
            echo "错误: 未知选项: $1" >&2
            exit 1
            ;;
        *)
            if [[ -z "$INPUT" ]]; then
                INPUT="$1"
            elif [[ -z "$OUTPUT" ]]; then
                OUTPUT="$1"
            else
                echo "错误: 多余参数: $1" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

INPUT="${INPUT:-${SCRIPT_DIR}/../backup/Z96A-TYPEC/partitions/uboot_mmcblk2p2.img}"
OUTPUT="${OUTPUT:-${SCRIPT_DIR}/uboot_patched.img}"

if [[ ! -f "$INPUT" ]]; then
    echo "错误: 输入文件不存在: $INPUT" >&2
    exit 1
fi

# ---------- 补丁 ----------
echo "======== U-Boot 默认环境变量补丁 ========"
echo "[1/2] patch bootcmd + 更新 FIT uboot hash: $INPUT (dev: $DEV)"
DEV="$DEV" python3 - "$INPUT" "$OUTPUT" <<'PYEOF'
import os, sys, struct, hashlib
src, dst = sys.argv[1], sys.argv[2]
DEV = os.environ["DEV"]

OLD = b"bootcmd=boot_android ${devtype} ${devnum};boot_fit;bootrkp;run distro_bootcmd;"
NEW = ("bootcmd=sysboot " + DEV + " any 0x00c00000 /extlinux/extlinux.conf").encode()

if len(NEW) > len(OLD):
    sys.exit(f"错误: 新 bootcmd 长度 ({len(NEW)}) 大于原值 ({len(OLD)})")

data = bytearray(open(src, "rb").read())
orig_len = len(data)

# ---------- 1. 等长替换 bootcmd ----------
if OLD not in data and NEW in data:
    print("      提示: 输入已包含目标 bootcmd，跳过 bootcmd 修改")
else:
    count = data.count(OLD)
    if count == 0:
        sys.exit("错误: 未找到原 bootcmd，可能已被修改")
    if count > 1:
        print(f"      提示: 发现 {count} 处 bootcmd（冗余副本），全部替换")
    NEW_PAD = NEW + b" " * (len(OLD) - len(NEW))
    data[:] = data.replace(OLD, NEW_PAD)
    print(f"      原 bootcmd: {OLD.decode()}")
    print(f"      新 bootcmd: {NEW.decode()}")
    print(f"      替换 {count} 处，长度 {len(OLD)} -> {len(NEW_PAD)} (等长填充 {len(OLD) - len(NEW)} 空格)")

# ---------- 2. 重算并回写 FIT 内 images/uboot 的 sha256 ----------
def find_all(buf, needle):
    offs, i = [], 0
    while True:
        i = buf.find(needle, i)
        if i < 0:
            return offs
        offs.append(i); i += 1

def parse_fdt(data, base):
    """解析 base 处的 FDT，返回 {path: {prop: (value_bytes, abs_offset)}}，失败返回 None。"""
    if base + 0x28 > len(data):
        return None
    magic, totalsize, off_struct, off_strings, off_rsv, ver, lv, bcp, ss, sst = \
        struct.unpack('>IIIIIIIIII', data[base:base + 0x28])
    if magic != 0xd00dfeed or base + totalsize > len(data):
        return None
    def pname(no):
        e = data.index(b'\x00', base + off_strings + no)
        return data[base + off_strings + no:e].decode()
    props = {}
    stack = []
    i = base + off_struct
    end = base + off_struct + sst
    while i < end:
        tok = struct.unpack('>I', data[i:i + 4])[0]; i += 4
        if tok == 0x1:            # FDT_BEGIN_NODE
            e = data.index(b'\x00', i)
            stack.append(data[i:e].decode())
            i = (e + 1 + 3) & ~3
        elif tok == 0x2:          # FDT_END_NODE
            stack.pop()
        elif tok == 0x3:          # FDT_PROP
            ln, no = struct.unpack('>II', data[i:i + 8]); i += 8
            nm = pname(no)
            valoff = i
            i = (i + ln + 3) & ~3
            props.setdefault('/'.join(stack), {})[nm] = (data[valoff:valoff + ln], valoff)
        elif tok == 0x9:          # FDT_END
            break
    return props

fixed = 0
for base in find_all(data, b"\xd0\x0d\xfe\xed"):
    props = parse_fdt(data, base)
    if not props:
        continue
    u = props.get('/images/uboot')
    h = props.get('/images/uboot/hash')
    if not u or not h or 'value' not in h or 'data-size' not in u:
        continue
    dsize = int.from_bytes(u['data-size'][0], 'big')
    if 'data-position' in u:
        dstart = base + int.from_bytes(u['data-position'][0], 'big')
    elif 'data-offset' in u:
        dstart = base + int.from_bytes(u['data-offset'][0], 'big')
    else:
        print(f"      跳过 FIT@{base:#x}: uboot 节点无 data-position/data-offset")
        continue
    oldh = bytes(data[h['value'][1]:h['value'][1] + 32]).hex()
    newh = hashlib.sha256(data[dstart:dstart + dsize]).digest()
    data[h['value'][1]:h['value'][1] + 32] = newh
    fixed += 1
    print(f"      FIT@{base:#x}: uboot 数据 @0x{dstart - base:x} 大小 {dsize} 字节")
    print(f"        sha256 {oldh} -> {newh.hex()}")

if fixed == 0:
    sys.exit("错误: 未在镜像内找到 FIT 的 images/uboot hash 节点，无法更新校验值")

assert len(data) == orig_len, "修改后文件大小变化"
open(dst, "wb").write(data)
PYEOF

# ---------- 验证 ----------
echo "[2/2] verify"
echo "      bootcmd in output:"
strings "$OUTPUT" | grep '^bootcmd=' | sort -u | sed 's/[[:space:]]*$//' | sed 's/^/        /'

python3 - "$INPUT" "$OUTPUT" <<'PYEOF'
import hashlib, struct, sys
src, dst = sys.argv[1], sys.argv[2]
s = open(src, "rb").read()
d = open(dst, "rb").read()
print(f"        input  MD5  = {hashlib.md5(s).hexdigest()}")
print(f"        output MD5  = {hashlib.md5(d).hexdigest()}")
print(f"        size        = {len(d)} bytes, 与输入一致: {len(s) == len(d)}")

# ---------- FIT hash 自检 ----------
def find_all(buf, needle):
    offs, i = [], 0
    while True:
        i = buf.find(needle, i)
        if i < 0:
            return offs
        offs.append(i); i += 1

def parse_fdt(data, base):
    if base + 0x28 > len(data):
        return None
    magic, totalsize, off_struct, off_strings, off_rsv, ver, lv, bcp, ss, sst = \
        struct.unpack('>IIIIIIIIII', data[base:base + 0x28])
    if magic != 0xd00dfeed or base + totalsize > len(data):
        return None
    def pname(no):
        e = data.index(b'\x00', base + off_strings + no)
        return data[base + off_strings + no:e].decode()
    props = {}
    stack = []
    i = base + off_struct
    end = base + off_struct + sst
    while i < end:
        tok = struct.unpack('>I', data[i:i + 4])[0]; i += 4
        if tok == 0x1:
            e = data.index(b'\x00', i)
            stack.append(data[i:e].decode())
            i = (e + 1 + 3) & ~3
        elif tok == 0x2:
            stack.pop()
        elif tok == 0x3:
            ln, no = struct.unpack('>II', data[i:i + 8]); i += 8
            nm = pname(no)
            vo = i
            i = (i + ln + 3) & ~3
            props.setdefault('/'.join(stack), {})[nm] = (data[vo:vo + ln], vo)
        elif tok == 0x9:
            break
    return props

fits = [b for b in find_all(d, b"\xd0\x0d\xfe\xed") if parse_fdt(d, b)]
if not fits:
    sys.exit("错误: 输出镜像内未找到 FIT 结构")

ok_all = True
n_checked = 0
for base in fits:
    props = parse_fdt(d, base)
    img_names = set()
    for k in props:
        parts = k.split('/')
        if len(parts) == 3 and parts[1] == 'images':
            img_names.add(parts[2])
    for name in sorted(img_names):
        u = props.get('/images/' + name)
        h = props.get('/images/' + name + '/hash')
        if not u or not h or 'value' not in h or 'data-size' not in u:
            continue
        dsize = int.from_bytes(u['data-size'][0], 'big')
        if 'data-position' in u:
            dstart = base + int.from_bytes(u['data-position'][0], 'big')
        elif 'data-offset' in u:
            dstart = base + int.from_bytes(u['data-offset'][0], 'big')
        else:
            continue
        stored = bytes(h['value'][0]).hex()
        actual = hashlib.sha256(d[dstart:dstart + dsize]).hexdigest()
        ok = stored == actual
        ok_all = ok_all and ok
        n_checked += 1
        print(f"        FIT@{base:#x}/{name}: {'PASS' if ok else 'FAIL'}  {actual[:16]}…")

print(f"        共校验 {n_checked} 个 FIT 子镜像 hash：{'全部通过' if ok_all else '存在不匹配'}")
if not ok_all:
    sys.exit("错误: FIT hash 自检未通过")
PYEOF

echo "========================================="
