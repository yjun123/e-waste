#!/usr/bin/sh

# UICR       0x1000 1000
# FICR       0x1000 0000
# Core Flash 0x0000 0000

adapter=${1:-stlink}
device=${2:-nrf51}

# flash & uicr
openocd -f interface/${adapter}.cfg  -f target/${device}.cfg -c init -c halt \
                                                             -c "nrf51 mass_erase" \
                                                             -c "program sensoro-yunzi-flash-firmware-dump.bin 0x00000000 verify" \
                                                             -c "program sensoro-yunzi-uicr-firmware-dump.bin 0x10001000 verify reset exit"

