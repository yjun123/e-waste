# 9Tripod Live3588V4

[English](README.md) · 简体中文

九鼎创展 [Live3588v4.0 直播机主板](http://www.9tripod.com/showpro.php?id=139)，由深圳市九鼎创展科技有限公司推出，基于
Rockchip RK3588 八核处理器（4×A76 + 4×A55），搭载 LPDDR4/4X 内存（可选 8GB/16GB）与 eMMC 闪存（可选 128GB/256GB），官
方适配了 Android 系统，具备 EDP 屏及 LVDS 大屏接口(?), 定位为直播机场景的主板方案。

该主板采用底板与核心板分离式架构，核心板为 [I3588核心板](http://www.9tripod.com/showpro.php?id=125)。

![Live3588V4.0](./images/Live3588V4.0.png)

官网公布的硬件规格信息仅对应 4.0 版本。经实物拆解验证，市面上实际流通的硬件版本已迭代至 V4.2 与 V4.3，二者相较 4.0 在
外围器件选型及 PCB 布局上均做了小幅调整。


下表列出了市面上采用九鼎创展直播机主板的常见直播机：

| 直播机 | 主板 |
| --- | --- |
| 聆晰直播一体机 | Live3588V4.2 |
| 九影G5 | Live3588SV54 |

**以下章节中所列信息对应聆晰直播一体机（Live3588 V4.2） 硬件版本。**

## 硬件

型号前缀标注 * 表示该芯片在主板上尚未定位。

| 规格 | 描述 |
| --- | --- |
| 型号 | LE2110 |
| 底板PCB 版本 | Live3588V4.2 20230919 |
| 核心板PCB 版本 | I3588CV2_20220719 |
| SoC | 瑞芯微 Rockchip [RK3588](https://www.rock-chips.com/a/en/products/RK35_Series/2022/0926/1660.html) / 8nm / 8 核（4×Cortex-A76 @2.4GHz + 4×Cortex-A55 @1.8GHz） / Mali-G610 MP4 GPU / 6 TOPS NPU / 8K@60fps H.265/VP9 解码、4K@60fps AV1 解码、8K@30fps H.264/H.265 编码 |
| DDR | 2 * 8GB 佰维 BIWIN [BWMZCX32H2A-64G-X](https://www.biwintechnology.com/product/lpddr4-4x/) / LPDDR4/4X / FBGA200 / 4266 Mbps |
| eMMC | 256GB 时创意 SCY [E256CSAG4ABE00](https://www.shichuangyi.com/qianrushicunchuxinpian/7.html) / eMMC5.1 |
| 电源管理芯片 | 瑞芯微 Rockchip [RK806-1](https://item.szlcsc.com/5789556.html) / RK3588 配套 PMIC / SPI / 10×BUCK + 5×NLDO + 6×PLDO / 中断：PWRON、HOTDIE、VDC、VB_LO |
| WiFi | 瑞昱 Realtek RTL8852BE / 802.11ax WiFi6 / 2T2R / PCIe Gen2 x1 |
| BT | 瑞昱 Realtek RTL8852BE / BT5.2 / USB2.0 |
| 千兆 PHY | 瑞昱 Realtek [RTL8211FD-CG](https://item.szlcsc.com/2790637.html) / 10Base-T、100Base-TX和1000Base-T |
| USB3 控制器 | 威锋 VIA Labs（VLI）[VL805-Q6](https://www.via-labs.com/product_show.php?id=48) / PCIe Gen2  x1 -> USB3.0 xHCI 4 口 |
| Type-C 端口控制器 | 安森美 ON Semi [FUSB302BMPX](https://www.onsemi.cn/products/interfaces/usb-type-c/fusb302b) /  Max 100 W  / 丝印 PBAB CLH |
| EDP 屏              | 正通仁禾 ZTRH ZTRH154FHD02 / 1920 x 1080 / 34cm x 19cm       |
| 触屏                | 汇顶 Goodix GT9110 / 十点电容触控 / I2C                      |
| HDMI 转 MIPI 桥芯片 | 龙迅 Lontium [LT6911C](https://m.elecfans.com/article/2107781.html) / HDMI1.4 → MIPI CSI |
| 摄像头 | 索尼 Sony [IMX766](https://bbs.16rd.com/citiao-sensor-imx766.html) / MIPI CSI-2 |
| 立体声Audio Codec | 顺芯 Everest [ES8388](https://item.szlcsc.com/339918.html) / 2×ADC + 2×DAC / 24bit |
| 音频功率放大器 | 纳芯威 Nsiway [NS4150B](https://www.nsiway.com.cn/list_38/82.html) / 3W / 单声道 / D类 |
| *RTC 时钟       | 浩宇 Haoyu [HYM8563](https://item.szlcsc.com/108470.html) / I2C / 带 CLKOUT 时钟输出 |  
| SPI NOR Flash | 亮月 BRIGHTMOON T25S40 / 4Mb / 连接至 **VL805-Q6** |
| USB 音频 | 骅讯 Cmedia [HS-100C](https://warmseaic.com/cmedia/hs-100c) / USB 2.0 |
| *加速度计 | 士兰微 Silan [SC7A20](https://www.silan.com.cn/index.php/product/details/47.html) / 12bit / 数字三轴加速度 |
| DC-DC | 芯源 MPS [MP8759GD-Z](https://www.monolithicpower.cn/cn/mp8759.html) / 同步降压  / 26V / 8A / 丝印 AQQ P52 789 |
| MOSFET | 美森科 MSKSEMI [AO4480-MS](https://item.szlcsc.com/3498500.html) / N 沟道/ 丝印 4480 MS80N |

| 接口 | 描述 |
| --- | --- |
| 供电口 | 12V/5A DC 供电输入座 |
| USB 3.1 TypeC | TCPC 芯片为 **FUSB302B** |
| HDMI-IN1 | 最大支持 1080P@60fps， 通过 **LT6911C** 扩展实现 |
| HDMI-IN2 | HDMI 2.0 RX，最大支持 4K@60fps |
| HDMI-OUT | HDMI 2.1 TX |
| 以太网口 | 千兆 |
| USB 3.0 Type-A * 4 | Host，通过 **VL805-Q6** 扩展实现 |
| 耳机口 |      |
| Line-IN | 音频线性输入接口 |
| SIM 卡槽 | 未上料，接口未焊接 |
| USB 2.0 | 2 * 4P 线对板连接器 |
| 补光灯接口 | 4P 线对板连接器，5V |
| MIPI CSI | 30P 连接器，连接相机 |
| EDP | 40P 屏线连接器，连接屏幕 |

## 图片

拆解与器件照片见 [images](./images)：

- [outside](./images/outside)：整机外观
- [inside](./images/inside)：底板、核心板、散热器/风扇、扬声器、天线、USB 音频小板及局部特写
- [chip](./images/chip)：芯片丝印（RK3588、RK806-1、LPDDR4X、eMMC、RTL8852BE、LT6911C、FUSB302BMPX 等）
- [interface](./images/interface)：调试串口、Maskrom 按键

底板 `Live3588V4.2 20230919`；

<img src="./images/inside/board-overview.jpg" alt="board overview" style="zoom: 25%;" />



核心板 `I3588CV2_20220719`：RK3588 + 2×BIWIN 16GB LPDDR4X + SCY 256GB eMMC + RK806-1；

<img src="./images/inside/core-board.jpg" alt="core board" style="zoom:25%;" />



## 调试串口

<img src="images/interface/Debug-UART.jpg" alt="Debug UART" style="zoom:50%;" />

## Maskrom 模式

按住 BOOT 按键 开机， 进入 Maskrom 模式

<img src="images/interface/Maskrom-Button.jpg" style="zoom: 25%;" />

直播机原厂固件启用了安全启动，因此必须使用专用的 [MiniLoaderAll](./loader/MiniLoaderAll.bin)。



## Mainline Linux

RK3588 自 Linux 6.3 进入主线，到 7.x 已支持 CPU/GPU（Panthor）、VOP2/eDP/HDMI/DP 显示、HDMI RX、音频、eMMC/SD、GMAC、PCIe、USB3/Type-C、PMIC/RTC、NPU（Rocket）、VPU 解码（rkvdec）、VICAP（rkcif）和 RGA3 等大部分核心模块。主线目前主要缺 VPU 编码（VENC）和 RK3588 ISP（rkisp3.0）驱动，其余核心外设基本齐全。



### 启动

由于原厂固件启用了安全启动（Secure Boot），对启动链的任何修改（如 loader、U-Boot 等）均会导致启动失败。

庆幸的是，当前设备处于 unlock 状态，AVB（Android Verified Boot）未生效，因此可通过 mkbootimg 工具将 Linux 内核与设备树打包为 Android Boot Image，替换 boot 分区，从而实现主线内核的启动。



### 设备树

[rk3588-9tripod-live3588-v4.dts](https://github.com/yjun123/linux/blob/add_9tripod_live3588_v4_support_v7.3/arch/arm64/boot/dts/rockchip/rk3588-9tripod-live3588-v4.dts)



### 发行版

#### Arch Linux ARM



### 驱动

关键外设的主线支持状态。

“树外（Out-of-tree）”项由 [armbian/linux-rockchip](https://github.com/armbian/linux-rockchip) fork 中的 Rockchip BSP 厂商驱动覆盖，尚未进入上游 Linux

| 组件 | 芯片 | 主线驱动 | 状态 |
| --- | --- | --- | --- |
| PMIC | RK806-1 | `rk806`（MFD + Regulator，SPI） | ✅ |
| GPU | Mali-G610 MP4 | `panthor` | ✅ |
| NPU | RK3588 6TOPS | `rocket` | ✅ |
| VPU 解码 | RKVDEC / Hantro | `hantro_vpu`（H.264/H.265/VP8/AV1） | ✅ |
| VPU 编码 | RKVENC | 无 | ❌ |
| HDMI-OUT | HDMI 2.1 TX | `dw-hdmi-qp` | ✅ |
| HDMI-IN2 | HDMI 2.0 RX | `snps_hdmirx` | 🟡 需要开源 TF-A |
| HDMI-IN1 | LT6911C (MEDIA, I2C ) | 树外：[drivers/media/i2c/lt6911c.c](https://github.com/armbian/linux-rockchip/blob/rk-6.1-rkr7.2/drivers/media/i2c/lt6911c.c) | ❌ |
| eDP | ZTRH ZTRH154FHD02 | `analogix_dp` + `panel-edp` | ✅ ，面板支持需要非主线补丁：[drivers/gpu/drm/panel/panel-edp.c](https://github.com/yjun123/linux/commits/add_9tripod_live3588_v4_support_v7.3/)|
| 音频 Codec | ES8388（I2C）| `snd-soc-es8328` | ✅ |
| 扬声器功放 | NS4150B | `snd-soc-simple-amplifier` | ✅ |
| USB 音频 | Cmedia HS-100C | `snd-usb-audio` | ✅ |
| 千兆 PHY | RTL8211FD-CG | `rk_gmac-dwmac` | ✅ |
| WiFi | RTL8852BE（PCIe） | `rtw89_8852be` | ✅ |
| BT | RTL8852BE（UART） | `btrtl` | ✅ |
| Type-C | FUSB302B(I2C) | `typec_fusb302` | ✅ |
| 触摸 | GT9110（I2C) | `goodix` | ✅ |
| 加速度计 | SC7A20(I2C)| `st_accel_i2c` | ✅ |
| 风扇 | — | `gpio_fan` | ✅ |
| LED | — | `leds-gpio` | ✅ |
| 按键 | 电源键 | `rk806` | ✅ |



### 外设状态

各外设在主线内核上的实际（测试）状态：

- ✅ 正常
- ❌ 异常
- 🟡 部分可用
- ⬜ 未测试

| 外设 | 状态 | 备注 |
| --- | --- | --- |
| eMMC | ✅ |  |
| WiFi | ✅ |  |
| Type-C | 🟡 | FUSB302 I2C 无应答；固定 host + VBUS 常开 |
| USB 3.0 ×4 | ❌ | VL805 四个口全部报过流，端口被禁用；VBUS无电压，四个PE脚都没接，4个OC脚引出了，但是没确定控制方法 |
| USB 2.0 插针 | ✅ | USB 音频 HS-100C 可识别 |
| 千兆网 | ❌ | 初始化无报错，网络不通 |
| 蓝牙 | ❌ | 蓝牙通过UART接入，但是无法扫描 |
| 显示 - EDP 屏 | ✅ | 见 [#驱动 - eDP](###驱动) |
| 显示 - HDMI-OUT | ✅ | |
| 显示 - HDMI-IN1 | ❌ | 见 [驱动 - HDMI-IN2](#驱动) |
| 显示 - HDMI-IN2 | ❌ | 见 [驱动 - HDMI-IN2](#驱动) |
| 音频 - HDMI | ✅ |  |
| 音频 - 扬声器 | ⬜ | ES8388 + NS4150B； 单声道喇叭 |
| 音频 - 麦克风 | ⬜ |  |
| 音频 - 耳机 | ⬜ |  |
| 摄像头 | ❌ | IMX766 无主线驱动（设备树已描述） |
| 触摸 | ✅ | 固件可从芯片寄存器中提取 |
| NPU | ⬜ | rocket 已加载 |
| VPU 解码 | ⬜ | hantro 已注册（AV1 / H.264） |
| VPU 编码 | ❌ | 见 [驱动 - VPU 编码](#驱动)  |
| GPU | ✅ |                                   |
| 电源键 | ✅ | |
| LED | ✅ | |
| 风扇 | ✅ | |



### 固件

| 固件 | 用途 | 来源 |
| --- | --- | --- |
| `rtw89/rtw8852b_fw.bin` | WiFi RTL8852BE | linux-firmware |
| `rtl8852bs_fw.bin` + `rtl8852bs_config.bin` | 蓝牙 | [vendor blob，提取自原厂安卓系统](./firmware/rtl_bt) |
| `goodix_9110_cfg.bin` | 触屏 | [goodix_9110_cfg.bin，从芯片寄存器中dump](./firmware/goodix_9110_cfg.bin) |



## 待实现功能

| 功能 | 描述 |
| ---- | ---- |
| 通过 chainload 启动主线 U-Boot |  |



## 参考

[九鼎创展官网 - Live3588v4.0](http://www.9tripod.com/showpro.php?id=139)

[九鼎创展官网 - I3588 核心板](http://www.9tripod.com/showpro.php?id=125)

[九鼎创展论坛社区 - 直播一体机镜像发布最新帖](http://bbs.9tripod.com/forum.php?mod=viewthread&tid=119419&extra=page%3D1)

[yifengyou/live3588 - 九鼎创展 Live3588v4.0 开发板](https://github.com/yifengyou/live3588)

[Armbian Forum - Request for Firmware – Device Live Broadcast V4 (Board: LIVE3588V4.2) - Eng.ahmedflash](https://forum.armbian.com/topic/54363-request-for-firmware-%E2%80%93-device-live-broadcast-v4-board-live3588v42/)

[rockchip.fr - julienchauveau](https://rockchip.fr/)
