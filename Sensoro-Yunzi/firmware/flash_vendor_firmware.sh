#!/usr/bin/sh

# UICR       0x1000 100
# FICR       0x1000 000
# Core Flash 0x0000 0000

# flash
openocd -f interface/stlink.cfg  -f target/nrf51.cfg -c "program sensoro-yunzi-flash-firmware-dump.bin 0x00000000 verify reset exit"

# uicr
openocd -f interface/stlink.cfg  -f target/nrf51.cfg -c "program sensoro-yunzi-uicr-firmware-dump.bin 0x10001000 verify reset exit"
