#!/bin/sh
# SPDX-License-Identifier: MIT
#
# goodix_cfg_dump.sh - 从 Goodix GT9110 触摸芯片导出板级配置
#
# 从芯片 0x8047 寄存器读出 186 字节配置，保存为 goodix_9110_cfg.bin。
#
# 用法（板上 root）:
#   sudo ./goodix_cfg_dump.sh -b <总线号> -a <地址> -o <输出文件>
#
#   -b  I2C 总线号，如 4
#   -a  I2C 地址，如 0x14（备用 0x5d）
#   -o  输出文件，如 goodix_9110_cfg.bin
#   -h  显示帮助
#
# 若提示总线被占用，先解绑驱动再试:
#   echo <bus>-<addr> > /sys/bus/i2c/drivers/goodix/unbind
#
set -u

BUS=
ADDR=
OUT=
LEN=186

usage() {
    sed -n '4,17p' "$0" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

while getopts "b:a:o:h" opt; do
    case "$opt" in
        b) BUS=$OPTARG ;;
        a) ADDR=$OPTARG ;;
        o) OUT=$OPTARG ;;
        h) usage 0 ;;
        *) usage 2 ;;
    esac
done

if [ -z "$BUS" ] || [ -z "$ADDR" ] || [ -z "$OUT" ]; then
    echo "错误: -b、-a、-o 都是必填参数" >&2
    usage 2
fi

[ "$(id -u)" -eq 0 ] || { echo "错误: 需要 root（i2c-dev 权限）" >&2; exit 1; }
command -v i2ctransfer >/dev/null 2>&1 || { echo "错误: 缺少 i2ctransfer（安装 i2c-tools）" >&2; exit 1; }
command -v xxd >/dev/null 2>&1 || { echo "错误: 缺少 xxd" >&2; exit 1; }
[ -e "/dev/i2c-$BUS" ] || { echo "错误: /dev/i2c-$BUS 不存在" >&2; exit 1; }

BUSADDR=$(printf '%d-%04x' "$BUS" "$((ADDR))")

i2c_read() { # $1=reg_hi $2=reg_lo $3=len
    i2ctransfer -y -f "$BUS" w2@"$ADDR" "$1" "$2" r"$3" 2>&1
}

fail_bus() {
    echo "错误: $1" >&2
    echo "提示: 驱动可能占用总线，先解绑后重试:" >&2
    echo "  echo $BUSADDR > /sys/bus/i2c/drivers/goodix/unbind" >&2
    exit 1
}

echo "== 目标: /dev/i2c-$BUS 地址 $ADDR"

# --- 1. 产品 ID（0x8140，4 字节 ASCII） ---
ID_RAW=$(i2c_read 0x81 0x40 4)
case "$ID_RAW" in
    *[Ee]rror*|*"Remote I/O"*|*"timed out"*) fail_bus "读产品 ID 失败: $ID_RAW" ;;
esac
ID=$(printf '%s\n' "$ID_RAW" | sed 's/0x//g' | tr -d ' \n' | xxd -r -p | tr -d '\0')
echo "== 产品 ID: ${ID:-?}"
case "$ID" in
    9110|911|9111) : ;;
    *) echo "警告: 产品 ID 不是 9110，仍按 $LEN 字节读取配置" >&2 ;;
esac

# --- 2. 读配置（0x8047，186 字节） ---
CFG_RAW=$(i2c_read 0x80 0x47 "$LEN")
case "$CFG_RAW" in
    *[Ee]rror*|*"Remote I/O"*|*"timed out"*) fail_bus "读配置失败: $CFG_RAW" ;;
esac
printf '%s\n' "$CFG_RAW" | sed 's/0x//g' | tr -d ' \n' | xxd -r -p > "$OUT"

SIZE=$(wc -c < "$OUT")
echo "== 配置长度: $SIZE 字节 -> $OUT"
if [ "$SIZE" -ne "$LEN" ]; then
    echo "错误: 期望 $LEN 字节，实际 $SIZE 字节（原始数据保留在 $OUT 供检查）" >&2
    exit 1
fi

# --- 3. 校验: GT9xx 8 位校验和 + config_fresh + 基本信息 ---
CHECK=$(od -An -tu1 -v "$OUT" | awk '{for(i=1;i<=NF;i++) b[n++]=$i} END{
    s=0; for(i=0;i<n-2;i++) s=(s+b[i])%256;
    printf "%d %d %d %d %d %d %d\n",
        (256-s)%256, b[n-2], b[n-1], b[5]%16, b[6]%4,
        b[1]+b[2]*256, b[3]+b[4]*256}')
set -- $CHECK
CALC=$1 FILE_SUM=$2 FRESH=$3 CONTACTS=$4 TRIGGER=$5 XMAX=$6 YMAX=$7

echo "== 分辨率: ${XMAX}x${YMAX}  触点数: $CONTACTS  触发方式: $TRIGGER"
echo "== 校验和: 计算 $CALC / 文件 $FILE_SUM"

if [ "$CALC" -ne "$FILE_SUM" ]; then
    echo "错误: 校验和不匹配，配置可能未正确读出（芯片未就绪/地址不对）" >&2
    echo "      可先复位触摸再试，或检查地址是否为 0x5d" >&2
    exit 1
fi
if [ "$FRESH" -ne 1 ]; then
    echo "警告: config_fresh 字节为 $FRESH（驱动要求 1）" >&2
fi

echo "== 完成"
