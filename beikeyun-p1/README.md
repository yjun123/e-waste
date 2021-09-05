# 美贝壳 Meibeike 贝壳云 P1

[Beikeyun official website](http://www.meibeike.com/index.php/Product/index/cat_id/2)

![Beikeyun Spec](http://www.meibeike.com/Uploads/goods/1530780946.jpg)

## Hardware

| Specification | Description |
| ------------- | ----------- |
| PCB Resivion  | RK3328 A3 |
| SoC           | Rockchip [RK3328](https://www.rock-chips.com/a/en/products/RK33_Series/2017/0118/829.html)@1.5Ghz/Quad-core Cortex A53 |
| DRAM          | 512 MiB * 2 DDR3L Nanya [NT5CC256M16EP-EK](https://www.memory-distributor.com/nt5cc256m16ep-ek.html)/4Gb/FBGA96 |
| Power         | 12V/2.5A |
| eMMC          | 8 GiB Samsung [KLM8G1GETF-B041](https://www.samsung.com/semiconductor/estorage/emmc/KLM8G1GETF-B041/)/eMMC 5.1/HS400/FBGA153 |
| USB Hub controller | 4 Ports USB Hub Genesys Logic [GL3520](http://www.genesyslogic.com/en/product_view.php?show=26)/integrated USB PHY |
| Ethernet Phyceivers |  10/100/1000M PHY Realtek [RTL8211F](https://www.realtek.com/en/products/communications-network-ics/item/rtl8211f-i-cg) |
| Wireless Module | No |
| PMU/PMIC      | No (RK805 in Rock64) |
| Lan Transformer | |
| Size          | 137 * 87.8 * 36.3mm |

| Interface     | Description |
| ------------- | ----------- |
| USB 3.0       | Host * 4    |
| USB 2.0       | No          |
| HDMI          | 2.0a * 1    |
| Ethernet      | 10/100/1000M RJ45 * 1 |
| WiFi          | No          |
| Bluetooth     | No          |
| MircoSD       | No          |
| Infrared      | No          |
| SPDIF         | No          |

## Rockchip RK3328

| Specification | Description |
| ------------- | ----------- |
| CPU           | ARM Cortex-A53 Quad-Core @1.5Ghz |
| GPU           | Mali-450MP4 |
| Memory        | DDR3/DDR3L/LPDDR3/DDR4 4GB(max) |

[Rockchip RK3328 Product-Page ](https://www.rock-chips.com/a/en/products/RK33_Series/2017/0118/829.html)

[Rockchip RK3328 Wiki](http://opensource.rock-chips.com/wiki_RK3328)

[Rockchip RK3328 Datasheet](http://opensource.rock-chips.com/images/9/95/Rockchip_RK3328_Datasheet_V1.3-20200310.pdf)

[Rockchip RK3328 TRM](http://opensource.rock-chips.com/images/8/8f/Rockchip_RK3288_TRM_V1.2_Part1-20170321.pdf)

[Rockchip RK3328 Hadrware Reference (Schematic & Layout Guide)](http://opensource.rock-chips.com/images/9/97/Rockchip_RK3328TRM_V1.1-Part1-20170321.pdf)

## Flash

### Firefly Wiki

[烧写 eMMC](https://wiki.t-firefly.com/zh_CN/ROC-RK3328-CC/flash_emmc.html)

### Linux Flash Tool

[rkdeveloptool](https://aur.archlinux.org/packages/rkdeveloptool-git/)

#### 步骤

- 检测 maskrom 设备

  ```
  $ rkdeveloptool ld                   
  DevNo=1 Vid=0x2207,Pid=0x320c,LocationID=101    Maskrom
  ```

- 烧入镜像

  ```
  rkdeveloptool db rk3328_loader.bin #rk3328_loader_v1.14.249.bin
  rkdeveloptool wl 0x0 ArchLinuxARM-aarch64-beikeyun-2019-09-16.img
  rkdeveloptool rd
  
  $ rkdeveloptool db rk3328_loader.bin
  Downloading bootloader succeeded.
  $ rkdeveloptool wl 0x0 ArchLinuxARM-aarch64-beikeyun-2019-09-16.img
  Write LBA from file (100%)
  ```
  
  

## TTL UART

**baudrate**: `1500000`

## Device Tree

[hanwckf/linux-rk3328 - rk3328-beikeyun.dts](https://github.com/hanwckf/linux-rk3328/blob/master/arch/arm64/boot/dts/rockchip/rk3328-beikeyun.dts)

[unifreq/linux-5.14.y - rk3328-beikeyun-1296mhz.dts](https://github.com/unifreq/linux-5.14.y/blob/main/arch/arm64/boot/dts/rockchip/rk3328-beikeyun-1296mhz.dts)

## Mainline Linux

## Mainline U-Boot

## Bootable Image

[hanwckf/build-beikeyun - ArchLinuxARM-aarch64-beikeyun-2019-09-16.img.xz](https://github.com/hanwckf/build-beikeyun/releases/download/v2019-9-16-1/ArchLinuxARM-aarch64-beikeyun-2019-09-16.img.xz)

- kernel: 4.4.182

## Blogs and Forums

[轶哥 - 贝壳云P1刷OpenWrt教程](https://www.wyr.me/post/627)

[libgcc - 贝壳云P1 刷机指南](https://www.jianshu.com/p/21d3954231dc)

> 掀开屏蔽罩后可以看到主板全貌，主板正面有一个USB焊盘，一个微动开关和一个TTL接口，需要自行焊接排针引出，此外还留有一个SPI FLASH焊盘；背面有DDR3空焊盘。

[wdmomo - 贝壳云折腾](http://www.wdmomo.fun:81/doc/web/#/5)

[矿渣论坛 - 贝壳云分区](https://bbs.nas66.com/forum-39-1.html)

[smzdm - imsatan - 矿难无情人有情，垃圾佬的贝壳云的低成本改造之路。](https://post.smzdm.com/p/41348/)

[宏创网络 - 贝壳云刷机教程](http://x9pc.com/firmware/beikeyun/)

> 如果USB3.0不能正常工作，请观察USB插座附近的焊盘是否有下图中的磁珠，如果有，用小号的一字螺丝批撬掉即可
> 刷机需要进入maskrom模式。如果进入LOADER模式可以在刷机工具内切换到maskrom模式。

[right.com.cn - network007 - 贝壳云改2G内存](https://www.right.com.cn/forum/thread-4070978-1-1.html)

> 新增SDRAM：NT5CB256M16CP-DI X2 为小米mini盒子拆机内存颗 电阻：240欧 
> 如系统启动后没有识别2G内存，可直接检查TTL开机记录，若DRAM显示1G，则证明系统没有识别2G，请重新植锡焊接内存DRAM（不排除DRAM有问题）+电阻
> 必须刷2次机，第一次正常教程刷入，第二次直接将loader刷入0x00000000起始地址，这样贝壳云2G内存就可以正常启动了 (?)

[right.com.cn - h010310534 - 贝壳云P1 刷机指南](https://www.right.com.cn/forum/thread-563762-1-1.html)

> 个别硬盘需要禁用uas (USB Attached SCSI)

[Salmonkr's Blog - 贝壳云之刷机指南](http://salmonkr.com/index.php/archives/31/)

> usb和串口都连接成功（串口一般波特率1500000，我使用发现PL2303的USB转TTL芯片支持不了如此高的速度，一直乱码，CH340的没有问题），算是完工。

[mydigit.cn - hzy3774 - 矿渣贝壳云P1改造之引出刷机接口，加装风扇](https://www.mydigit.cn/thread-62654-2-1.html)

[zdns.com - wdmomoxx - 给贝壳云NAS添加OLED屏幕](https://www.znds.com/tv-1183784-1-1.html)

[anywlan.com - 我都能pin死你 - 矿渣贝壳云刷小钢炮不改壳子散热方案](https://www.anywlan.com/thread-442710-1-1.html)

> jellyfin硬件加速：jellyfin就不介绍了，主要说下硬件加速，这块网上说的人不多。小钢炮是可以硬件加速的，开启后会造成系统不稳定，保存时系统会弹出提示。对于贝壳云硬件加速要选择API，API设备路径是：/dev/dri/renderD128、勾选启用硬件编码，FFMPEG路径是：/usr/bin/ffmpeg，其他默认就好

[CSDN - 罗翔说刑法 - android 卸载状态码 贝壳云刷Android官改固件——氧气UI·贝壳云](https://blog.csdn.net/weixin_26642481/article/details/112137237)

[Nano Disk Manager - 贝壳云抠电阻](https://nanodm.net/post/nanodm/beikeyun-remove-the-magic-resistor/)

[快,快到碗里来 - 贝壳云小钢炮root分区扩容](https://inpot.github.io/2020/07/23/%E8%B4%9D%E5%A3%B3%E4%BA%91%E5%B0%8F%E9%92%A2%E7%82%AEroot%E5%88%86%E5%8C%BA%E6%89%A9%E5%AE%B9/)

[xins - 贝壳云刷Armbian](https://xins134.xyz/archives/bei-ke-yun-shua-armbian)

> 群里流传的, 大家一顿操作猛如虎之后，发现效果确实杠杠滴。如果不抠掉这几颗电阻，USB3接口的速率会非常慢，甚至可能导致USB3存储调协接上去后无法识别。

## Github

[hanwckf/build-beikeyun - scripts for build beikeyun firmware](https://github.com/hanwckf/build-beikeyun)

[Izumiko/PKGBUILD-beikeyun - PKGBUILD of linux-image, U-Boot, linux-firmware for Beikeyun P1. Archlinux ARM Image](https://github.com/Izumiko/PKGBUILD-beikeyun)

[Izumiko/uboot-beikeyun - mainline U-Boot for beikeyun P1](https://github.com/Izumiko/uboot-beikeyun)

[unifreq/linux-5.14.y](https://github.com/unifreq/linux-5.14.y)

[unifreq/arm64-kernel-configs - my arm64 kernel configs for armbian/openwrt , platform: amlogic/allwinner/rockchip](https://github.com/unifreq/arm64-kernel-configs)

## Wiki

[Firefly ROC-RK3328-CC Wiki](https://wiki.t-firefly.com/zh_CN/ROC-RK3328-CC/intro.html)

[Rockchip Wiki](http://opensource.rock-chips.com/wiki_Main_Page)
