# 泰奇猫 TQC-A01

[TQC official website](https://tq.ultrapower.com.cn/index.html)

![TQC](https://tqc.taiqigame.com/tqc/webImages/indexbanner.png)

![TQC](https://tqc.taiqigame.com/tqc/webImages/product.png)

## Hardware

| Specifications| Description |
| ----- | --- |
| PCB revision  | AZW-KT02 2.0 |
| SoC   | Allwinner [H6](https://linux-sunxi.org/H6)@1.8Ghz/V2000-AWIN/BGA451/15X15mm/Quad-core Cortex-A53 |
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

  based on OrangePi 3 device tree, ethernet, WiFi and Bluetooth enabled.

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

#### 5.17

- mmc

  [0012-fix-h6-emmc.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.armbian/0012-fix-h6-emmc.patch)

  [0013-x-fix-h6-emmc-dts.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.armbian/0013-x-fix-h6-emmc-dts.patch)

- ethernet

  [arm64-dts-sun50i-h6-Add-AC200-EPHY-related-nodes.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.armbian/arm64-dts-sun50i-h6-Add-AC200-EPHY-related-nodes.patch)

  [drv-net-phy-Add-support-for-AC200-EPHY.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.armbian/drv-net-phy-Add-support-for-AC200-EPHY.patch)

  [drv-mfd-Add-support-for-AC200.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.armbian/drv-mfd-Add-support-for-AC200.patch)

  [net-stmmac-sun8i-Add-support-for-enabling-a-regulator-for-PHY-I.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.megous/net-stmmac-sun8i-Add-support-for-enabling-a-regulator-for-PHY-I.patch)

  [net-stmmac-sun8i-Rename-PHY-regulator-variable-to-regulator_phy.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.megous/net-stmmac-sun8i-Rename-PHY-regulator-variable-to-regulator_phy.patch)

  [net-stmmac-sun8i-Use-devm_regulator_get-for-PHY-regulator.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.megous/net-stmmac-sun8i-Use-devm_regulator_get-for-PHY-regulator.patch)

- hdmi sound

  [arm64-dts-allwinner-h6-Add-hdmi-sound-card.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.megous/arm64-dts-allwinner-h6-Add-hdmi-sound-card.patch)

- audio codec

  [0009-allwinner-h6-support-ac200-audio-codec.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.armbian/0009-allwinner-h6-support-ac200-audio-codec.patch)

- misc

  [0010-allwinner-add-sunxi_get_soc_chipid-and-sunxi_get_ser.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.armbian/0010-allwinner-add-sunxi_get_soc_chipid-and-sunxi_get_ser.patch)

  [arm64-dts-sun50i-h6.dtsi-improve-thermals.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.armbian/arm64-dts-sun50i-h6.dtsi-improve-thermals.patch)

  [arm64-dts-allwinner-h6-Add-SCPI-protocol.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.megous/arm64-dts-allwinner-h6-Add-SCPI-protocol.patch)

  [arm64-dts-allwinner-h6-Protect-SCP-clocks.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.megous/arm64-dts-allwinner-h6-Protect-SCP-clocks.patch)

  [drv-pinctrl-sunxi-pinctrl-sun50i-h6.c-GPIO-disable_strict_mode.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.armbian/drv-pinctrl-sunxi-pinctrl-sun50i-h6.c-GPIO-disable_strict_mode.patch)

- cedrus (VPU driver)

  [drv-media-cedrus-10-bit-HEVC-support.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.armbian/drv-media-cedrus-10-bit-HEVC-support.patch)

  [drv-media-cedrus-Add-callback-for-buffer-cleanup.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.armbian/drv-media-cedrus-Add-callback-for-buffer-cleanup.patch)

  [drv-media-cedrus-h264-Improve-buffer-management.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.armbian/drv-media-cedrus-h264-Improve-buffer-management.patch)
  [drv-media-cedrus-hevc-Improve-buffer-management.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.armbian/drv-media-cedrus-hevc-Improve-buffer-management.patch)

  [drv-media-cedrus-hevc-tiles-hack.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.armbian/drv-media-cedrus-hevc-tiles-hack.patch)

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

## Forums and Blogs

[泰奇猫TQC-A01强力推荐此盒子](https://www.znds.com/tv-1185657-1-1.html)

[TQC泰奇猫矿渣利用](https://www.right.com.cn/forum/thread-3469793-1-1.html)

> 泰奇猫这个是基于Allwinner H6 也就是全志H6 ARM64 芯片的一个盒子,整体这个机子的系统其实也是套用了公版sun50iw6 OrangePi3 实施的一个方案。

[网络设备杂谈 篇一：小猫变脑斧？？？！！！泰奇猫深度使用记录](https://post.m.smzdm.com/p/alxld6mp)

[网络设备杂谈 篇二：震惊! 矿渣wifi起死回生，背后的原因令人暖心。泰奇猫0成本wifi](https://post.m.smzdm.com/p/a4d4w5mx/)

[25元的泰奇猫盒子 还能刷Zidoo机顶盒系统](https://post.smzdm.com/p/awrnn9vg/)

[垃圾佬的日常 篇十四：25元就能体验到芝杜（zidoo）系统，一个纯净的电视盒子矿渣——泰奇猫](https://post.m.smzdm.com/p/anxxvrgp/)

[教你怎么刷芝杜/zidoo播放器系统-泰奇猫](https://www.hao4k.cn/thread-57639-1-1.html)

![H6vsS905](https://data.hao4k.cn/forum/202105/24/zdm202105Mon091131k21ejyd2gjc.jpg)

[矿渣 ：泰奇猫刷机芝杜（zidoo）系统](https://www.amobbs.com/thread-5750868-1-1.html)

[泰奇猫Zidoo h6 pro移植固件发布](https://www.znds.com/tv-1183570-1-1.html)

[泰奇猫Zidoo固件发布-更新完美线刷包20201115更新外置网卡版](https://bbs.nas66.com/thread-12104-1-1.html)

[矿渣论坛 - 硬件专区›泰奇猫](https://bbs.nas66.com/forum-42-1.html)

[矿渣篇：泰奇猫魔改](https://www.bilibili.com/read/mobile?id=9995897&ivk_sa=1024320u)

[TQC泰奇猫刷原版Android系统](https://post.m.smzdm.com/p/adwgz3ox/)

[40块买到原价1299的矿渣电视盒泰奇猫，能刷芝杜系统还能上4K](https://mbd.baidu.com/newspage/data/landingshare?pageType=1&nid=news_9259844976391711714&wfr=&_refluxos=)

[熊娃成全了他爹！40块包邮的泰奇猫电视盒子，还能刷芝杜系统](https://post.m.smzdm.com/p/ar66vp5z/)

[记录某全志H6矿渣LibreELEC系统适配过程](https://www.amobbs.com/thread-5751326-1-1.html)

## TODO

- install arch to eMMC

- ~~enable WiFi~~ 

- enable IrDA

- enable hdmi sound output

- ~~dump kernel verion~~

- build usable U-Boot for H6

