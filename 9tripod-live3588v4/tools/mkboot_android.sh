#!/usr/bin/env bash
# usage: mkboot_android.sh -k <kernel> -d <dtb> -o <output> [-c <cmdline>] [-r <ramdisk>] [--pad]
set -euo pipefail

usage() {
    echo "usage: $(basename "$0") -k <kernel> -d <dtb> -o <output> [-c <cmdline>] [-r <ramdisk>] [--pad]" >&2
    exit "${1:-2}"
}

KERNEL= DTB= OUT= RAMDISK= PAD=0
CMDLINE="console=ttyS2,1500000n8 earlycon=uart8250,mmio32,0xfeb50000 root=/dev/mmcblk0p15 rootwait rw"

while (( $# )); do
    case "$1" in
        -k) [[ $# -ge 2 ]] || usage; KERNEL=$2; shift 2 ;;
        -d) [[ $# -ge 2 ]] || usage; DTB=$2; shift 2 ;;
        -o) [[ $# -ge 2 ]] || usage; OUT=$2; shift 2 ;;
        -c) [[ $# -ge 2 ]] || usage; CMDLINE=$2; shift 2 ;;
        -r) [[ $# -ge 2 ]] || usage; RAMDISK=$2; shift 2 ;;
        --pad) PAD=1; shift ;;
        -h|--help) usage 0 ;;
        *) usage ;;
    esac
done

[[ -n "$KERNEL" && -n "$DTB" && -n "$OUT" ]] || usage

[[ -f "$KERNEL" ]] || { echo "kernel not found: $KERNEL" >&2; exit 1; }
[[ -f "$DTB" ]] || { echo "dtb not found: $DTB" >&2; exit 1; }
[[ -z "$RAMDISK" || -f "$RAMDISK" ]] || { echo "ramdisk not found: $RAMDISK" >&2; exit 1; }
command -v mkbootimg >/dev/null || { echo "mkbootimg not found" >&2; exit 1; }

mkdir -p "$(dirname "$OUT")"

args=(
    --header_version 2
    --pagesize 2048
    --base 0x10000000
    --kernel_offset 0x8000
    --ramdisk_offset 0x1000000
    --second_offset 0xf00000
    --tags_offset 0x100
    --dtb_offset 0x1f00000
    --kernel "$KERNEL"
    --dtb "$DTB"
    --cmdline "$CMDLINE"
    -o "$OUT"
)
[[ -n "$RAMDISK" ]] && args+=(--ramdisk "$RAMDISK")

mkbootimg "${args[@]}"

size=$(stat -c%s "$OUT")
if (( size > 67108864 )); then
    echo "boot image is ${size} bytes, exceeds the 64 MiB partition" >&2
    if [[ "$PAD" == 1 ]]; then
        exit 1
    fi
fi

if [[ "$PAD" == 1 ]]; then
    truncate -s 67108864 "$OUT"
fi

echo "$OUT"
