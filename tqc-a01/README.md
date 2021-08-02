# 泰奇猫 TQC-A01

[TQC official website](https://tq.ultrapower.com.cn/index.html)

![TQC](https://tqc.taiqigame.com/tqc/webImages/indexbanner.png)

![TQC](https://tqc.taiqigame.com/tqc/webImages/product.png)

## Hardware

| Specifications| Description |
| ----- | --- |
| PCB revision  | AZW-KT02 2.0 |
| SoC   | Allwinner [H6](https://linux-sunxi.org/H6)@1.8Ghz/V2000-AWIN/BGA451/15X15mm/Quad-core Cotex-A53 |
| DRAM  | 1GiB LPDDR3 SpecTek [SS256M32V01MD1LPF-107BT](https://www.spectek.com/menus/we_detail.aspx?memType=LPDDR3)/PB047-125 PT/BGA178/1600Mbps |
| Power | DC 5V@2A |
| eMMC  | 8GiB eMMC 5.1 Longsys Foresee eMMC [NCEMAM6G-08G](https://www.arrow.com/en/datasheets/9029653725/shenzhen-longsys-electronics-co.-ltd/ncemam6g-08g)/BGA153 |
| Wireless Module | 802.11b/g/n BT4.0 AMPAK [AP6212](https://fccid.io/PJ5-AX905/User-Manual/User-manual-3321089.pdf)/B11210011 1753/1T1R |
| PMU/PMIC | XPOWER [AXP805](http://linux-sunxi.org/images/b/bc/AXP805_Datasheet_V1.0_en.pdf)/H7044CA 67H1/3V to 5.5V/QFN56_7X7/|
| Lan Transformer | Apps [AE-SB16001](http://www.appselectronics.com/Uploads/product/5ae167b80285a.pdf) |
| Size  | 96 * 96 * 17mm|


| Interface | Description  |
| ------------ | --- |
| USB 2.0 Host | * 1 |
| USB 3.0 Host | * 1 |
| USB 2.0 OTG  | * 1 |
| HDMI         | * 1 |
| Ethernet     | integrated 10/100M PHY / RJ45 * 1 |
| WiFi         | integraed in AP6212 BCM43430 * 1 |
| SPDIF        | * 1 |
| MicroSD      | * 1 |
| Infrared     | * 1 |
| Bluetooth    | integraed in AP6212 BCM43430A1 *1 |

## Allwinner H6

[linux-sunxi H6](https://linux-sunxi.org/H6)

| Specification | Description |
| ------------- | ----------- |
| Process | 28nm |
| CPU | Quad-Core ARM Cortex-A53 @ 1.8GHz |
| GPU | Mali-T720 MP2 @ 600Mhz |
| Memory | LPDDR2/LPDDR3/DDR3/DDR4 |

### FEL

[FEL](https://linux-sunxi.org/FEL)

> FEL is a low-level subroutine contained in the BootROM on Allwinner devices. It is used for initial programming and recovery of devices using USB. 

connect to USB 2.0 port instead of the USB OTG port :). 

## AP6212

[AMPAK AP6212](https://deviwiki.com/wiki/AMPAK_AP6212)

| Function | Interface in use |
| -------- | --------- |
| WiFi     |  SDIO     |
| BT       |  UART     |

## TTL UART

![TQC-TTL](./image/TQC-TTL-UART.png)

## Mainline Linux
  
### linux kernel packge for Arch Linux ARM

  [linux-tqc-a01](https://aur.archlinux.org/packages/linux-tqc-a01/)

### Device Tree

  based on OrangePi 3 device tree, ethernet and wifi, BT enabled.

  it works fine with linux stable release [sun50i-h6-tqc-a01.dts](https://aur.archlinux.org/cgit/aur.git/plain/sun50i-h6-tqc-a01.dts?h=linux-tqc-a01)


  works fine with linux 5.11.4 [dts for linux 5.11](https://aur.archlinux.org/cgit/aur.git/plain/sun50i-h6-tqc-a01.dts?h=linux-tqc-a01&id=869858806a8fbf1e0121537eb724dfe25ff3728a)


### config

  based on linux-aarch64 config from Arch Linux ARM, with some extra changes for Allwinner H6.

  [config](https://aur.archlinux.org/cgit/aur.git/plain/config?h=linux-tqc-a01)

### patches

#### 5.11

  - mmc

    *libreELEC* :

    [0011-mmc-sunxi-fix-unusuable-eMMC-on-some-H6-boards-by-di.patch](https://github.com/LibreELEC/LibreELEC.tv/blob/master/projects/Allwinner/devices/H6/patches/linux/0011-mmc-sunxi-fix-unusuable-eMMC-on-some-H6-boards-by-di.patch)

  - ethernet

    *libreELEC* :

    [0002-net-stmmac-sun8i-Use-devm_regulator_get-for-PHY-regu.patch](https://github.com/LibreELEC/LibreELEC.tv/blob/master/projects/Allwinner/devices/H6/patches/linux/0002-net-stmmac-sun8i-Use-devm_regulator_get-for-PHY-regu.patch)

    [0003-net-stmmac-sun8i-Rename-PHY-regulator-variable-to-re.patch](https://github.com/LibreELEC/LibreELEC.tv/blob/master/projects/Allwinner/devices/H6/patches/linux/0003-net-stmmac-sun8i-Rename-PHY-regulator-variable-to-re.patch)

    [0004-net-stmmac-sun8i-Add-support-for-enabling-a-regulato.patch](https://github.com/LibreELEC/LibreELEC.tv/blob/master/projects/Allwinner/devices/H6/patches/linux/0004-net-stmmac-sun8i-Add-support-for-enabling-a-regulato.patch)

    *armbian* :

    [0001-mfd-Add-support-for-AC200.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.11/0001-mfd-Add-support-for-AC200.patch)

    [0002-net-phy-Add-support-for-AC200-EPHY.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.11/0002-net-phy-Add-support-for-AC200-EPHY.patch)

    [0003-arm64-dts-allwinner-h6-Add-AC200-EPHY-related-nodes.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.11/0003-arm64-dts-allwinner-h6-Add-AC200-EPHY-related-nodes.patch)

  - hdmi sound 

    *libreELEC*

    [0001-HACK-h6-Add-HDMI-sound-card.patch](https://github.com/LibreELEC/LibreELEC.tv/blob/master/projects/Allwinner/devices/H6/patches/linux/0001-HACK-h6-Add-HDMI-sound-card.patch) *whithout test*

#### 5.13

  is same as 5.11

## Firmware

### firmware packge for Arch Linux ARM

  [firmware-tqc-a01](https://aur.archlinux.org/packages/firmware-tqc-a01/)

### WiFi
    
  > brcmfmac43430-sdio.bin
    brcmfmac43430-sdio.AP6212.txt

### BT 

  > BCM43430A1.bin

Firmware url could get from [firmware-tqc-a01](https://aur.archlinux.org/cgit/aur.git/plain/.SRCINFO?h=firmware-tqc-a01)

## Mainline U-Boot

## TODO

- install arch to eMMC

- ~~enable wifi~~ 

- enable IrDA

- enable hdmi sound output

- ~~dump kernel verion~~

- build usable U-Boot for H6
