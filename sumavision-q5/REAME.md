# 数码视讯 Sumavision Q5

## Hardware

| Specification   | Description                                                  |
| --------------- | ------------------------------------------------------------ |
| PCB Revision    | MB.S905.04                                                   |
| SoC             | S905M (?)                                                    |
| DRAM            | 512 MiB * 2 DDR3-1866 Micron [MT41K256M16LY-107](https://www.micron.com/products/dram/ddr3-sdram/part-catalog/mt41k256m16tw-107) D9SDD/6NN47/96-ball 7.5mm x 13.5mm FBGA |
| eMMC            | 8GiB Samsung [KLM8G1GEME-B041](https://www.samsung.com/semiconductor/estorage/emmc/KLM8G1GEME-B041/) |
| Wireless        | 802.11bgn 2.4G Realtek [RTL8189ETV](https://www.realtek.com/en/products/communications-network-ics/item/rtl8189etv) |
| Lan Transformer | 10/100M Base-T [PSF-16211](https://datasheetspdf.com/pdf/1312470/PPT/PSF-16211/1) |



| Interface | Description      |
| --------- | ---------------- |
| USB 2.0   | Host * 2         |
| HDMI      | * 1              |
| Ethernet  | 10/100M RJ45 * 1 |
| WiFi      | 802.11 bgn 2.4G  |
| Bluetooth | No               |
| MicroSD   | * 1              |
| Infrared  | * 1              |
| SPDIF     | * 1              |
| AUX       | * 1              |



## Wireless

- 802.11bgn
- SDIO interface

### Wiki

[RTL8189ES_.2F_RTL8189ETV](https://linux-sunxi.org/Wifi#RTL8189ES_.2F_RTL8189ETV)

### Driver

- [jwrdegoede/rtl8189ES_linux](https://github.com/jwrdegoede/rtl8189ES_linux)
- [rtl8189es-dkms-git](https://aur.archlinux.org/packages/rtl8189es-dkms-git/)

## USB Boot

## Mainline Linux

- just use mainline linux

## Mainline U-Boot

## Blogs and Forums

[免拆机！免刷机线！Q5刷机如此简单！——数码视讯Q5刷机教程 - 人中日月](https://www.bilibili.com/read/cv2970639)

>众所周知，由于数码视讯Q5是运营商定制的一款Amlogic（晶晨）S905方案机顶盒，在2016年~2017年广泛使用。之后因性能落伍而逐渐退市，目前闲鱼上有大量二手数码视讯Q5在售，由于量大性能够用，价格便宜，非常适合怀旧玩家拿来刷机用于怀旧游戏。目前（2019年6月）二手数码视讯Q5在闲鱼的正常价格大概50~60块一套，有的已经刷好机，有的则需要玩家自己亲自破解。

[17.数码视讯Q5-不完全折腾手册 - wdmomo](http://www.wdmomo.fun:81/default/?blog%2F17.%E6%95%B0%E7%A0%81%E8%A7%86%E8%AE%AFQ5-%E4%B8%8D%E5%AE%8C%E5%85%A8%E6%8A%98%E8%85%BE%E6%89%8B%E5%86%8C)

[北京数码视讯Q5 拆机TTL安装第三方软件教程! - hao501802766](https://www.znds.com/tv-509413-1-1.html)

[【二】 数码视讯Q5破解刷机 - 家麟](https://www.jianshu.com/p/ada66a94340b)

[求一个数码视讯q5芯片是905的op固件 - 恩山论坛](https://www.right.com.cn/forum/thread-4187400-1-1.html)

>顶贴同求Q5盒子openwrt固件,希望大佬将SDIO端口的RTL8189ETV(FTV),RTL8188等等瑞昱无线网卡驱动移植到openwrt固件中,造福坛友,让老盒子发挥一下余热,目前该类型机顶盒有大量现货还在流通,比如魔百盒G2 40F,3300M,小红盒,创维盒子,外贸盒子MXQ PRO,NEXBOX A95X,T95,MINIX等等,不胜枚举,我看市面上保守就有几十万到百万的量,要是能有偿定制也是可以的.

[捡垃圾：花60元打造最强游戏盒子! - 烈日冰峰](https://zhongce.sina.com.cn/article/view/43773/)

[北京联通数码视讯Q5线刷包 - wifijz.com](https://wifijz.com/archives/447)

[关于 s905 盒子数码Q5刷 armbian Ubuntu - powersee](https://powersee.github.io/2020/07/about-s905/)

[视讯数码 Q5 安装 armbian 开启 BBR - warehouse](https://ntgeralt.blogspot.com/2019/06/q5-armbian-bbr.html)
