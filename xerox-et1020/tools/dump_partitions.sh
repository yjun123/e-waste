#!/bin/bash
# 从 ET1020 (RK3399, Android 7.1.2) 导出 eMMC 分区
#
# 用法:
#   ./dump_partitions.sh [adb-serial] [输出目录]
#
# 环境变量:
#   SKIP_USERDATA=1  跳过 userdata（该分区约 13GB，默认会导出）
#   ONLY=boot,system 只导出指定名称的分区（逗号分隔）
#   VERIFY=0         关闭导出后的 md5 校验（默认开启）
#   DRY_RUN=1        只列出分区信息，不实际导出
#
# 说明:
#   - 本机为 user 版固件，adbd 无法通过 `adb root` 提权，脚本会自动回退到
#     Magisk 的 `su`。
#   - eMMC 为 mmcblk1，SD 卡为 mmcblk0，这里只导出 eMMC。
#   - 二进制传输必须用 `adb shell`，不要用 `adb exec-out`：在本机实测，Magisk
#     `su` 在 exec-out 下会分配 pty 并做 LF(0x0A) -> CRLF(0x0D 0x0A) 转换，
#     导致镜像被污染；`adb shell` 在 stdout 重定向到管道/文件时输出原始字节。
set -euo pipefail

SERIAL="${1:-${ADB_SERIAL:-192.168.0.115:5555}}"
OUTDIR="${2:-${OUTDIR:-$PWD}}"
SKIP_USERDATA="${SKIP_USERDATA:-0}"
ONLY="${ONLY:-}"
VERIFY="${VERIFY:-1}"
DRY_RUN="${DRY_RUN:-0}"

ADB=(adb -s "$SERIAL")

# 网络 adb（serial 形如 host:port）先尝试连接，设备掉线后可自动恢复
if [[ "$SERIAL" == *:* ]]; then
  adb connect "$SERIAL" >/dev/null 2>&1 || true
fi

echo "==> 等待设备 $SERIAL 上线"
"${ADB[@]}" wait-for-device

echo "==> 检查 root 权限"
"${ADB[@]}" root >/dev/null 2>&1 || true
"${ADB[@]}" wait-for-device

if [ "$("${ADB[@]}" shell id -u 2>/dev/null | tr -d '\r')" = "0" ]; then
  USE_SU=0
  echo "    adbd 已以 root 运行"
elif "${ADB[@]}" shell 'su -c id -u' 2>/dev/null | tr -d '\r' | grep -qx 0; then
  USE_SU=1
  echo "    adbd 为 shell 用户（user 版固件），使用 Magisk su"
else
  echo "错误: 既无法 adb root，也无法通过 su 提权" >&2
  exit 1
fi

# 以 root 执行 shell 命令。注意两点：
#   1. su -c 的命令必须作为单个参数传入，否则 adb 会按空格拆分参数，
#      带 ; do ...; done 的命令会被设备的 shell 提前解析。
#   2. 二进制数据也走 `adb shell`（stdout 重定向时是原始字节）；exec-out 在
#      本机 Magisk su 下会做 LF->CRLF 转换，禁止用于镜像导出。
if [ "$USE_SU" -eq 1 ]; then
  rsh() { "${ADB[@]}" shell "su -c '$*'"; }
else
  rsh() { "${ADB[@]}" shell "$*"; }
fi

remote_md5() {
  rsh "dd if=$1 bs=4096 2>/dev/null | md5sum" | tr -d '\r' | awk '{print $1}'
}

echo "==> 定位 by-name 目录"
BYNAME=$(rsh 'for d in /dev/block/by-name /dev/block/platform/*/by-name; do [ -e "$d/system" ] && echo "$d" && break; done' | tr -d '\r')
if [ -z "$BYNAME" ]; then
  echo "错误: 未找到包含 system 的 by-name 目录" >&2
  exit 1
fi
echo "    $BYNAME"

echo "==> 确定 eMMC 块设备"
SYSTEM_LINK=$(rsh "readlink $BYNAME/system" | tr -d '\r')
if [ -z "$SYSTEM_LINK" ]; then
  SYSTEM_LINK=$(rsh "ls -l $BYNAME/system" | tr -d '\r' | sed -n 's/.* -> //p')
fi
EMMC=$(basename "$SYSTEM_LINK" | sed -E 's/p[0-9]+$//')
if [ -z "$EMMC" ] || [ "$EMMC" = "$SYSTEM_LINK" ]; then
  echo "错误: 无法从 $BYNAME/system -> '$SYSTEM_LINK' 解析 eMMC 设备" >&2
  exit 1
fi
echo "    /dev/block/$EMMC（SD 卡等其他块设备不会导出）"

echo "==> 解析分区大小（/proc/partitions，单位 1024B/block）"
mapfile -t PART < <(
  "${ADB[@]}" shell cat /proc/partitions \
    | tr -d '\r' \
    | awk -v dev="$EMMC" '$4 ~ ("^" dev "p[0-9]+$") {sub("^" dev "p", "", $4); print $4, $3}' \
    | sort -n
)
if [ "${#PART[@]}" -eq 0 ]; then
  echo "错误: 未找到 /dev/${EMMC}p* 分区" >&2
  exit 1
fi

echo "==> 解析分区名称"
declare -A NAMES=()
while read -r pname pnum; do
  [ -n "$pname" ] && [ -n "$pnum" ] && NAMES["$pnum"]="$pname"
done < <(
  rsh "ls -l $BYNAME" \
    | tr -d '\r' \
    | awk -F' -> ' 'NF == 2 {
        name = $1; sub(/^.* /, "", name)
        target = $2; sub(/^.*p/, "", target)
        print name, target
      }'
)

human_size() {
  local bytes=$1
  if [ "$bytes" -ge $(( 1024 * 1024 )) ]; then
    echo "$(( bytes / 1024 / 1024 )) MB"
  elif [ "$bytes" -ge 1024 ]; then
    echo "$(( bytes / 1024 )) KB"
  else
    echo "$bytes B"
  fi
}

mkdir -p "$OUTDIR"

for entry in "${PART[@]}"; do
  num="${entry%% *}"
  blocks="${entry##* }"
  size=$(( blocks * 1024 ))
  size_h=$(human_size "$size")
  name="${NAMES[$num]:-p$num}"
  dev="/dev/block/${EMMC}p${num}"
  outfile="$OUTDIR/${name}_${EMMC}p${num}.img"

  if [ "$SKIP_USERDATA" -eq 1 ] && [ "$name" = "userdata" ]; then
    echo "==> 跳过 $dev ($name，$size_h)"
    continue
  fi
  if [ -n "$ONLY" ] && [[ ",$ONLY," != *",$name,"* ]]; then
    continue
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    printf '    %-10s %-14s %10s  (%s)\n' \
      "${EMMC}p${num}" "$name" "$size_h" "$dev"
    continue
  fi

  echo "==> 导出 $dev ($name) $size_h"
  # adb shell 输出原始字节；head -c 按分区实际大小截断，防止尾部多余数据
  rsh "dd if=$dev bs=4096 2>/dev/null" | head -c "$size" > "$outfile"

  actual=$(stat -c%s "$outfile")
  if [ "$actual" -ne "$size" ]; then
    echo "    错误: 实际 $actual bytes，期望 $size bytes" >&2
    rm -f "$outfile"
    exit 1
  fi

  if [ "$VERIFY" -eq 1 ]; then
    remote_hash=$(remote_md5 "$dev")
    local_hash=$(md5sum "$outfile" | awk '{print $1}')
    if [ "$remote_hash" != "$local_hash" ]; then
      echo "    错误: md5 不一致 (设备 $remote_hash / 本地 $local_hash)" >&2
      rm -f "$outfile"
      exit 1
    fi
    echo "    完成: $actual bytes, md5 $local_hash"
  else
    echo "    完成: $actual bytes"
  fi
done

if [ "$DRY_RUN" -eq 1 ]; then
  echo "==> 预演结束（未写入任何文件）"
  exit 0
fi

echo "==> 全部完成，输出目录: $OUTDIR"
shopt -s nullglob
IMAGES=("$OUTDIR"/*.img)
[ "${#IMAGES[@]}" -eq 0 ] || ls -lh "${IMAGES[@]}"
