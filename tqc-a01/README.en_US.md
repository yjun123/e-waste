# TaiqiCat TQC-A01

[简体中文](./README.md) | English

[TQC official website (closed)](http://web.archive.org/web/20190409212205/tq.ultrapower.com.cn/index.html)

![TQC](http://web.archive.org/web/20190409212205im_/https://tqc.taiqigame.com/tqc/webImages/indexbanner.png)

![TQC](http://web.archive.org/web/20190409212205im_/https://tqc.taiqigame.com/tqc/webImages/product.png)

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
| USB 2.0 Host (Type-A) | * 1 |
| USB 3.0 Host (Type-A) | * 1 |
| USB 2.0 OTG (Mirco USB) | * 1 |
| HDMI         | * 1 |
| Ethernet     | integrated 10/100M PHY / RJ45 * 1 |
| WiFi         | integraed in AP6212 BCM43430 * 1 |
| SPDIF        | * 1 |
| MicroSD      | * 1 |
| Infrared     | * 1 |
| Bluetooth    | integraed in AP6212 BCM43430A1 *1 |



## Allwinner H6

[linux-sunxi H6](https://linux-sunxi.org/H6)

[linux-sunxi AC200](https://linux-sunxi.org/AC200)

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

~~It is currently in the process of being mainlined.~~

~~https://lore.kernel.org/linux-sunxi/20260226084850.417731-1-jerrysteve1101@gmail.com/T/~~

The corresponding devicetree is included in Linux v7.1.



### Device Tree

https://github.com/torvalds/linux/blob/master/arch/arm64/boot/dts/allwinner/sun50i-h6-taiqicat-a01.dts



### Peripheral status

Actual (tested) status of each peripheral on the mainline kernel:

- ✅ Working
- ❌ Broken
- 🟡 Partial
- ⬜ No test

| Peripheral         | Status | Notes                                                        |
| ------------------ | ------ | ------------------------------------------------------------ |
| eMMC               | ✅      |                                                              |
| Wi-Fi (AP6212)     | ✅      |                                                              |
| Bluetooth (AP6212) | ✅      |                                                              |
| Ethernet           | ✅      | Merged for v7.4.                                             |
| Display - HDMI     | ✅      |                                                              |
| USB 2.0 Host       | ✅      |                                                              |
| USB 3.0 Host       | ✅      |                                                              |
| USB 2.0 OTG        | ⬜      |                                                              |
| Audio - HDMI       | ❌      | Need extra patches [patches.megous/audio-7.3](https://github.com/armbian/build/tree/main/patch/kernel/archive/sunxi-7.3/patches.megous/audio-7.3) |
| Audio - SPDIF      | ⬜      |                                                              |
| Storage - MicroSD  | ✅      |                                                              |
| Infrared           | ⬜      |                                                              |



## Firmware

Add symlink config for brcmfmac43430-sdio.ultrapower,taiqicat-a01.txt: [WHENCE: add missing symlink for TaiqiCat (TQC) A01](https://gitlab.com/kernel-firmware/linux-firmware/-/merge_requests/1240/commits)

### WiFi

  > brcmfmac43430-sdio.bin
    brcmfmac43430-sdio.AP6212.txt

### BT 

  > BCM43430A1.hcd



## Mainline U-Boot

see [uboot-tqc-a01](https://github.com/Izumiko/uboot-tqc-a01)



### Video Hardware Decode

> Mainline FFmpeg currently lacks the necessary patches to use the v4l2-requests based API, but a fork[https://github.com/jernejsk/FFmpeg.git] that can utilise it exists.
>
> https://wiki.pine64.org/wiki/Mainline_Hardware_Decoding

Arch Linux ARM users can install from AUR.

[ffmpeg-v4l2-request-git](https://aur.archlinux.org/packages/ffmpeg-v4l2-request-git)



## Forums and Blogs

[TaiqiCat TQC-A01 — a highly recommended TV box (Chinese)](https://www.znds.com/tv-1185657-1-1.html)

[Repurposing the TQC TaiqiCat mining box (Chinese)](https://www.right.com.cn/forum/thread-3469793-1-1.html)

> The TaiqiCat is a TV box based on the Allwinner H6 — a 64-bit ARM64 SoC. Its system is essentially a port of the reference sun50iw6 OrangePi 3 design.

[Network equipment miscellany, part 1: The kitten becomes a tiger?! — Notes from in-depth use of the TaiqiCat (Chinese)](https://post.m.smzdm.com/p/alxld6mp)

[Network equipment miscellany, part 2: Shocking! A mining-box Wi-Fi brought back to life, and the reason is heartwarming — zero-cost Wi-Fi for the TaiqiCat (Chinese)](https://post.m.smzdm.com/p/a4d4w5mx/)

[A 25-yuan TaiqiCat box that can also run the Zidoo set-top box system (Chinese)](https://post.smzdm.com/p/awrnn9vg/)

[Everyday life of a junk collector, part 14: Experience the Zidoo system for 25 yuan — a clean mining-box TV box, the TaiqiCat (Chinese)](https://post.smzdm.com/p/anxxvrgp/)

[How to flash the Zidoo player system — TaiqiCat (Chinese)](https://www.hao4k.cn/thread-57639-1-1.html)

![H6vsS905](https://data.hao4k.cn/forum/202105/24/zdm202105Mon091131k21ejyd2gjc.jpg)

[Mining box: flashing the Zidoo system on the TaiqiCat (Chinese)](https://www.amobbs.com/thread-5750868-1-1.html)

[TaiqiCat Zidoo H6 Pro ported firmware released (Chinese)](https://www.znds.com/tv-1183570-1-1.html)

[TaiqiCat Zidoo firmware released — updated perfect cable-flash image, 20201115 update with external NIC version (Chinese)](https://bbs.nas66.com/thread-12104-1-1.html)

[Mining box forum — Hardware section › TaiqiCat (Chinese)](https://bbs.nas66.com/forum-42-1.html)

[Mining box series: TaiqiCat hardware mods (Chinese)](https://www.bilibili.com/read/mobile?id=9995897&ivk_sa=1024320u)

[Flashing the original Android system on the TQC TaiqiCat (Chinese)](https://post.m.smzdm.com/p/adwgz3ox/)

[A 40-yuan mining-box TV box that originally cost 1299 — the TaiqiCat, can run Zidoo and output 4K (Chinese)](https://mbd.baidu.com/newspage/data/landingshare?pageType=1&nid=news_9259844976391711714&wfr=&_refluxos=)

[The kid made his dad's day! A 40-yuan shipped TaiqiCat TV box that can also run Zidoo (Chinese)](https://post.m.smzdm.com/p/ar66vp5z/)

[Porting LibreELEC to an Allwinner H6 mining box (Chinese)](https://www.amobbs.com/thread-5751326-1-1.html)
