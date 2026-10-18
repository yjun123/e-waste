# ET1020 设备信息（厂商设备树解析）

本文由厂商固件中的设备树反编译结果整理而来：

- 源文件：同目录下的 `xerox-et1020-vendor-dump.dts`（4104 行，94 KB）
- 来源：本机 Android 7.1.2 厂商固件（`kernel` 分区内的 DTB）
- 根节点 `compatible`：`"rockchip,rk3399-mid"`, `"rockchip,rk3399"`

下表所有电压、频率、引脚均从 DTS 属性解码，十六进制原值见「DTS 属性」列。**厂商 DTS 是固件实际配置，但不等于硬件一定存在该器件**——部分节点是 Rockchip 参考设计的残留，详见文末「存疑与差异」。



## 平台与启动

| 项目 | 值 | DTS 节点 / 属性 |
| --- | --- | --- |
| SoC | Rockchip RK3399，4×Cortex-A53 + 2×Cortex-A72 | `cpus` |
| 中断控制器 | ARM GICv3 + ITS | `interrupt-controller@fee00000` |
| 电源管理固件 | PSCI 1.0（`smc`） | `psci` |
| 调试串口 | UART2 @ `0xff1a0000`，115200 8N1 | `serial@ff1a0000`、`fiq-debugger` |
| 调试串口引脚 | TX = GPIO4_C3，RX = GPIO4_C4（UART2C 复用） | `uart2c-xfer` |
| 内核启动参数 | `earlycon=uart8250,mmio32,0xff1a0000 swiotlb=1` | `chosen/bootargs` |
| 控制台设备名 | `ttyFIQ0` | 厂商 cmdline |
| Ramoops | 地址 `0x00110000`，大小 `0xF0000`；record 128 KB / console 512 KB / pmsg 320 KB | `ramoops_mem`、`ramoops` |
| DDR 时序 | `ddr3_speed_bin = 0x15`；`dmc`、`dfi` 均 **disabled** | `ddr_timing`、`dmc` |

> 调试串口的 5 个 UART 中 `serial0`（BT）、`serial2`（调试）、`serial3` 为 okay，`serial1`、`serial4` 为 disabled。



## 电源

### PMIC：RK818 @ I2C0 `0x1c`

| 项目 | 值 | DTS 属性 |
| --- | --- | --- |
| 中断引脚 | GPIO1_C5，低电平触发 | `interrupts = <0x15 0x08>` |
| 系统电源控制器 | 是 | `rockchip,system-power-controller` |
| DC 充电检测 | 关闭 | `rk818,support_dc_chg = <0x00>` |
| 外部连接器检测 | FUSB302 | `extcon` |
| 32 kHz 输出 | `xin32k` / `wifibt_32kin`（供 Wi-Fi/BT） | `clock-output-names` |

RK818 输出的稳压器（全部 `always-on` + `boot-on`）：

| 稳压器 | 名称 | 电压 | 用途 |
| --- | --- | --- | --- |
| DCDC_REG1 | `vdd_cpu_l` | 0.75 – 1.35 V | A53 核心 |
| DCDC_REG2 | `vdd_center` | 0.85 – 1.35 V | 中心逻辑 |
| DCDC_REG3 | `vcc_ddr` | （固定） | DDR |
| DCDC_REG4 | `vcc_1v8` | 1.8 V | 1.8 V 系统 |
| LDO_REG1 | `vcca3v0_codec` | 3.0 V | 音频模拟 |
| LDO_REG2 | `vcc3v0_tp` | 3.0 V | **触摸屏供电** |
| LDO_REG3 | `vcca1v8_codec` | 1.8 V | 音频 IO 域 |
| LDO_REG4 | `vcc_power_on` | 3.3 V | 开机保持 |
| LDO_REG5 | `vcc_3v0` | 3.0 V | GPIO 3.0 V 域 |
| LDO_REG6 | `vcc_1v5` | 1.5 V | 1.5 V 系统 |
| LDO_REG7 | `vcc1v8_dvp` | 1.8 V | 摄像头/DVP |
| LDO_REG8 | `vcc3v3_s3` | 3.3 V | 3.3 V 系统 |
| LDO_REG9 | `vcc_sd` | 1.8 – 3.3 V | **SD 卡 IO（vqmmc）** |
| SWITCH_REG | `vcc3v3_s0` | 3.3 V | 屏供电（eDP 面板节点引用） |
| DCDC_BOOST | `boost_otg` | 5.0 V | OTG 升压 |

DTS 中的 `battery` 子节点（`rk818-battery`）给了完整电量计参数，但**本机无电池**，这些只是固件默认值：

| 参数 | 值 | DTS 属性 |
| --- | --- | --- |
| 设计容量 | 7916 mAh | `design_capacity = <0x1eec>` |
| Qmax | 8708 mAh | `design_qmax = <0x2204>` |
| 最大充电电压 | 4350 mV | `max_chrg_voltage = <0x10fe>` |
| 最大输入/充电电流 | 3000 mA | `max_input_current` / `max_chrg_current = <0xbb8>` |
| 关机电压 | 3400 mV | `power_off_thresd = <0xd48>` |
| 电池内阻 / 采样电阻 | 65 / 20 mΩ | `bat_res` / `sample_res` |
| OCV 表 | 3400 – 4308 mV（21 点） | `ocv_table` |

### 分立 DCDC

| 器件 | 地址 | 名称 | 电压 | VSEL 引脚 |
| --- | --- | --- | --- | --- |
| Silergy SYR837（`silergy,syr827`） | I2C0 `0x40` | `vdd_cpu_b` | 0.7125 – 1.50 V | GPIO1_C1 |
| Silergy SYR828 | I2C0 `0x41` | `vdd_gpu` | 0.735 – 1.40 V | GPIO1_B6 |
| PWM 稳压器 | PWM2 @ `0xff420020` | `vdd_log` | 0.75 – 1.35 V，默认 950 mV | — |

### 固定稳压器

| 名称 | 电压 | 备注 |
| --- | --- | --- |
| `vcc_sys` | 3.9 V | 主输入，`always-on` |
| `vcc3v3_sys` | 3.3 V | `always-on` |
| `vcc5v0_host` | 5.0 V | USB Host VBUS，使能脚 GPIO4_D1，`always-on` |
| `vcc_phy` | — | `always-on` |



## 充电与 Type-C

| 项目 | 值 | DTS 节点 / 属性 |
| --- | --- | --- |
| Type-C 控制器 | Fairchild FUSB302 @ I2C4 `0x22` | `fusb30x@22` |
| FUSB302 中断 | GPIO1_A2，高有效 | `int-n-gpios = <0x2f 0x02 0x00>` |
| USB-C PHY0 | `0xff7c0000`，**okay**，含 DP + USB3 通道 | `phy@ff7c0000` |
| USB-C PHY1 | `0xff800000`，**disabled** | `phy@ff800000` |
| U-Boot 充电模式 | 关闭（Android 充电模式也关闭） | `uboot-charge` |
| 反向充电 | `power_dc2otg = <0x00>`，`support_dc_chg = 0` | `battery` |

FUSB302 是 `extcon` 源，被 RK818、USB2 PHY0、`dwc3@fe800000` 和 `dp@fec00000` 同时引用——即 Type-C 正反插/角色切换信息统一由它分发。



## 存储

| 接口 | 节点 | 配置 | 说明 |
| --- | --- | --- | --- |
| eMMC | `sdhci@fe330000` | HS400 @1.8 V + enhanced strobe，8-bit，非可移除，时钟 200 MHz | `mmc-hs400-enhanced-strobe` |
| SD 卡 | `dwmmc@fe320000` | 4-bit，SD 高速，`vqmmc = vcc_sd`，时钟 50 MHz | CD 引脚 GPIO0_A7 |
| SDIO（Wi-Fi） | `dwmmc@fe310000` | 4-bit，非可移除，SDR104，`cap-sdio-irq`，时钟 150 MHz | 供电/复位见下 |

Wi-Fi SDIO 的上下电由 `sdio-pwrseq` 控制：复位脚 GPIO0_B2（低有效），外部 32 kHz 时钟取自 RK818 的 `wifibt_32kin`。



## 无线

Wi-Fi 芯片类型由 DTS 直接声明为 **AP6255**（`wifi_chip_type = "ap6255"`，博通 BCM435x 系列 combo），SDIO 参考电压 1.8 V（`sdio_vref = <0x708>`）。

| 功能 | 引脚 | 极性/触发 |
| --- | --- | --- |
| Wi-Fi 唤醒主机 | GPIO0_A3 | — |
| Wi-Fi 复位（SDIO pwrseq） | GPIO0_B2 | 低有效 |
| 蓝牙 `BT_REG_ON` | GPIO0_B1 | 高有效 |
| 蓝牙唤醒主机（中断） | GPIO0_A4 | — |
| 蓝牙唤醒（主机→模组） | GPIO2_D2 | 高有效 |
| 蓝牙 UART RTS | GPIO2_C3 | 低有效（作 GPIO） |

蓝牙走 **UART0**（`serial@ff180000`，okay），波特率由内核协商；DTS 里 `pinctrl-1 = "rts_gpio"` 表示 RTS 被当作普通 GPIO 用（BCM combo 的常规做法）。



## 显示

实际启用的是 **MIPI DSI** 通路，`display-subsystem` 中 `route-mipi` 为 okay，其余路由关闭：

| 路由 | 状态 | 连接 |
| --- | --- | --- |
| `route-mipi` | **okay** | VOPB（`vop@ff900000` endpoint@1） |
| `route-hdmi` | disabled | HDMI |
| `route-edp` | disabled | eDP |

### 面板

| 项目 | 值 | DTS 属性 |
| --- | --- | --- |
| 节点 | `simple-panel-dsi` @ `mipi@ff960000` | `panel` |
| 数据通道 | 4 lane，RGB888（`dsi,format = 0`） | `dsi,lanes` |
| DSI flags | `0x07` | `dsi,flags` |
| 使能脚 | GPIO4_D4，高有效 | `enable-gpios = <0x7f 0x1c 0x00>` |
| 背光 | `pwm-backlight`，PWM0 @ GPIO4_C2 | `backlight` |
| 背光使能 | GPIO4_D3，高有效 | `enable-gpios` |
| 背光等级 | 256 级（0xff → 0x00），默认 200 | `brightness-levels` |

面板内置三组时序，`native-mode` 指向 **timing1**：

| 时序 | 分辨率 | 像素时钟 | 估算刷新率 | 说明 |
| --- | --- | --- | --- | --- |
| timing0 | 800×1280 | 78 MHz | ≈59.6 Hz | 竖屏备选 |
| **timing1** | **1920×1200** | **150 MHz** | **≈61.4 Hz** | **实际使用（native）** |
| timing2 | 1200×1920 | 160 MHz | ≈59.9 Hz | 竖屏备选 |

1920×1200 与该机 README 记录一致。

### 显示控制器

| 控制器 | 节点 | 状态 |
| --- | --- | --- |
| VOPB（big） | `vop@ff900000` | okay，接 MIPI DSI（endpoint@1）+ eDP/HDMI/DP 端点 |
| VOPL（lit） | `vop@ff8f0000` | okay，接 CDN-DP（endpoint@3） |
| HDMI | `hdmi@ff940000` | okay（但 `route-hdmi` 关闭、HDMI 音频节点 disabled） |
| eDP | `edp@ff970000` | **disabled** |
| CDN-DP | `dp@fec00000` | **okay**，`extcon = FUSB302`，走 VOPL |

`edp-panel` 节点（`lg,lp079qx1-sp0v`）仍然存在，但 eDP 控制器是 disabled，所以未生效。



## 音频

| 项目 | 值 | DTS 节点 / 属性 |
| --- | --- | --- |
| 编解码器 | **Realtek RT5645** @ I2C1 `0x1a` | `rt5645@1a`（`realtek,rt5645`） |
| 声卡 | `simple-audio-card`，名称 `rockchip,rt5645-codec` | `rt5645-sound` |
| 数据通路 | I2S0（8 通道，`rockchip,i2s-broken-burst-len`） | `i2s@ff880000` |
| MCLK 比 | 256 fs | `simple-audio-card,mclk-fs = <0x100>` |
| I2S0 引脚 | GPIO3_C0–C7 + GPIO4_A0 | `i2s0-8ch-bus` |
| SPDIF | `spdif@ff870000` + `spdif-dit`，声卡名 `rockchip,spdif` | 单独一张声卡 |
| HDMI/DP 音频 | **disabled** | `hdmi-dp-sound` |
| I2S1 / I2S2 | disabled | `i2s@ff890000` / `i2s@ff8a0000` |

声卡路由（`simple-audio-card,routing`）声明了三路：

- **Mic Jack** ← `micbias1` / `IN2P` / `IN2N`
- **Headphone Jack** ← `HPOL` / `HPOR`
- **Speaker** ← `SPOL` / `SPOR`（左右各重复一次，厂商写法冗余）

耳机检测由 `rk_headset` 完成：检测脚 GPIO4_C5，并复用 **SARADC 通道 4** 判断按键/线序类型。



## 传感器

| 器件 | 总线 / 地址 | 中断引脚 | 说明 |
| --- | --- | --- | --- |
| **MPU6500**（InvenSense 6 轴 IMU） | **SPI1** CS0，1 MHz，模式 3（CPHA+CPOL） | GPIO1_C4 | `inv-spi,mpu6500`，`support-hw-poweroff` |
| **LSM330 加速度计** | I2C4 `0x1e` | GPIO2_D3，上升沿 | 驱动 `lsm330_acc`，`layout = 4` |
| **AK8963 磁力计** | I2C4 `0x0d` | GPIO1_A3，上升沿 | `ak8963`，轮询 30 ms |
| **CM3218 环境光** | I2C4 `0x10` | GPIO4_D0，下降沿 | `capella,light_cm3218` |
| MH248 霍尔 | 节点存在但 **disabled** | 见下 | `hall-mh248` |

MPU6500 挂在 SPI1 上（`spi@ff1d0000`，CS0，`spi-cpha` + `spi-cpol`），是全机唯一的 6 轴器件；LSM330 只绑定了加速度计驱动。I2C4 同时是传感器总线和 FUSB302 所在总线（400 kHz）。



## 输入

### 按键

`rockchip,key` 使用 **SARADC 通道 1** 做电阻分压按键，另有一个 GPIO 电源键：

| 按键 | Linux code | 判据 | 引脚 |
| --- | --- | --- | --- |
| volume up | `0x72` (KEY_VOLUMEUP) | ADC = 1 | — |
| volume down | `0x73` (KEY_VOLUMEDOWN) | ADC = 170 | — |
| power | `0x74` (KEY_POWER) | GPIO，可唤醒 | GPIO0_A5，低有效 |
| menu | `0x3b` (KEY_MENU) | ADC = 746 | — |
| home | `0x66` (KEY_HOME) | ADC = 355 | — |
| back | `0x9e` (KEY_BACK) | ADC = 560 | — |
| camera | `0xd4` (KEY_CAMERA) | ADC = 450 | — |

ADC 值为原始采样码。DTS 里定义了 7 个按键，但该机外壳只有电源、返回、音量加、音量减四个物理键。

### 触摸屏

| 项目 | 值 | DTS 属性 |
| --- | --- | --- |
| 主方案 | Goodix GT9xx @ I2C4 `0x14` | `gt9xx@14` |
| 中断脚 | GPIO3_B5，低电平触发 | `touch-gpio = <0x37 0x0d 0x08>` |
| 复位脚 | GPIO3_B4，高有效 | `reset-gpio` |
| 分辨率 | 1920 × 1200 | `max-x = 0x780` / `max-y = 0x4b0` |
| 触摸面尺寸 | 101（`tp-size`） | `tp-size = <0x65>` |
| 供电 | `vcc3v0_tp`（RK818 LDO2） | `tp-supply` |
| 备选方案 | GSLX680 @ I2C4 `0x40` | `gslx680@40`，引脚与分辨率相同 |

GT9xx 与 GSLX680 定义在**同一条 I2C 总线的不同地址**上，都处于使能状态——典型的「同一块板两种屏厂方案」写法，实际只会有一颗焊上。两者共用中断/复位脚。



## USB

| 控制器 | 节点 | 角色 | PHY |
| --- | --- | --- | --- |
| USB3 OTG 0 | `usb@fe800000` + `dwc3@fe800000` | `dr_mode = "otg"` | USB2 PHY0 + USB3 PHY（Type-C PHY0） |
| USB3 OTG 1 | `usb@fe900000` + `dwc3@fe900000` | `dr_mode = "otg"`，`maximum-speed = "high-speed"` | 仅 USB2 PHY1 |
| EHCI/OHCI Host 0 | `usb@fe380000` / `usb@fe3a0000` | Host | USB2 PHY0 host-port，VBUS 由 `vcc5v0_host` 供给 |
| EHCI/OHCI Host 1 | `usb@fe3c0000` / `usb@fe3e0000` | Host | USB2 PHY1 host-port，VBUS 同样为 `vcc5v0_host` |

USB2 PHY1 另有一个 `otg-vbus-gpios = <GPIO3_B0>`（USB 口 VBUS 供电使能）。

**未使用**：PCIe（`pcie@f8000000`，disabled）、千兆以太网（`ethernet@fe300000`，disabled）。



## 其他外设

| 外设 | 节点 | 状态 | 备注 |
| --- | --- | --- | --- |
| GPU | `gpu@ff9a0000` | okay | ARM Mali-T860（`arm,malit860`），电源域 pd_gpu |
| 视频解码 | `vpu_service@ff650000` / `rkvdec@ff660000` | okay | 带 IOMMU |
| 图像处理 | `iep@ff670000` / `rga@ff680000` | okay | 带 IOMMU |
| ISP | `isp@ff910000` / `isp@ff920000` | okay | ISP0 / ISP1，均带 IOMMU |
| SARADC | `saradc@ff100000` | okay | 通道 1 按键，通道 4 耳机 |
| TSADC | `tsadc@ff260000` | okay | 双通道（soc / gpu），过温关断 95 ℃ |
| 振动马达 | `vibrator` | okay | `rk-vibrator-gpio`，GPIO4_D6，低有效 |
| 看门狗 | `watchdog@ff848000` | — | dw-wdt |
| 定时器 | `rktimer@ff850000` | — | — |
| eFuse | `efuse@ff690000` | — | CPU/GPU 漏电、wafer info、chip id |

### 温度保护点

| 触发点 | 温度 | 类型 |
| --- | --- | --- |
| trip-point@0 | 70 ℃ | passive |
| trip-point@1 | 85 ℃ | passive（触发 A53 / A72 / GPU 降频） |
| soc-crit | 95 ℃ | critical |

### PWM 使用情况

| PWM | 引脚 | 用途 |
| --- | --- | --- |
| PWM0 | GPIO4_C2 | 屏幕背光 |
| PWM2 | GPIO1_C3 | `vdd_log` 调压 |
| PWM1 / PWM3 | — | disabled |
| VOP PWM ×2 | — | disabled |



## 完整 GPIO 占用表

| 引脚 | 用途 | 有效电平 / 触发 |
| --- | --- | --- |
| GPIO0_A3 | Wi-Fi 唤醒主机（`WL_HOST_WAKE`） | — |
| GPIO0_A4 | 蓝牙唤醒主机（中断） | — |
| GPIO0_A5 | 电源键 | 低有效，可唤醒 |
| GPIO0_A7 | SD 卡插入检测（CD） | — |
| GPIO0_B1 | 蓝牙 `BT_REG_ON` 复位 | 高有效 |
| GPIO0_B2 | Wi-Fi SDIO 复位（pwrseq） | 低有效 |
| GPIO1_A2 | FUSB302 中断 | 高有效 |
| GPIO1_A3 | AK8963 中断 | 上升沿 |
| GPIO1_B6 | SYR828 VSEL（`vdd_gpu`） | 高有效 |
| GPIO1_C1 | SYR837 VSEL（`vdd_cpu_b`） | 高有效 |
| GPIO1_C4 | MPU6500 中断 | 上升沿 |
| GPIO1_C5 | RK818 PMIC 中断 | 低电平 |
| GPIO2_C3 | 蓝牙 UART RTS（作 GPIO） | 低有效 |
| GPIO2_D2 | 蓝牙唤醒（主机→模组） | 高有效 |
| GPIO2_D3 | LSM330 加速度计中断 | 上升沿 |
| GPIO3_B0 | USB2 PHY1 OTG VBUS 使能 | 高有效 |
| GPIO3_B4 | 触摸屏复位 | 高有效 |
| GPIO3_B5 | 触摸屏中断 | 低电平 |
| GPIO4_C5 | 耳机插入检测 | 低有效 |
| GPIO4_D0 | CM3218 中断 | 下降沿 |
| GPIO4_D1 | `vcc5v0_host` 使能（USB VBUS） | 高有效 |
| GPIO4_D3 | 背光使能 | 高有效 |
| GPIO4_D4 | MIPI 面板使能 | 高有效 |
| GPIO4_D6 | 振动马达 | 低有效 |

复用引脚（非 GPIO）：UART2C = GPIO4_C3/C4（调试串口）、UART0 = GPIO2_C0/C1（蓝牙）、I2S0 = GPIO3_C0–C7 + GPIO4_A0、SPI1 = GPIO1_A7/B0/B1/B2（MPU6500）、I2C0 = GPIO1_C7/D0、I2C1 = GPIO4_A1/A2、I2C4 = GPIO1_B3/B4。



## 存疑与差异

分析中发现的、与 README 记录或常理不符的地方，供后续上主线时留意：

1. **编解码器型号**：README 猜测 `ALC5645?`，DTS 明确是 **RT5645**（`realtek,rt5645`）。
2. **传感器对应关系**：README 把 `AK8963?` 标成霍尔传感器、把磁力计留空。DTS 里 AK8963 是 **I2C4 `0x0d` 的磁力计**；霍尔节点是 MH248 且 **disabled**。加速度计另有一颗 **LSM330**（I2C4 `0x1e`），MPU6500 是 SPI 上的 6 轴 IMU。
3. **摄像头**：DTS 中**没有任何摄像头 sensor 节点**（没有 GC2145 / OV8858），只有 ISP0/ISP1 控制器和 MIPI/CIF PHY 配置。前摄/后摄的型号需要另找依据（Android 层 HAL 配置或实际拆机）。
4. **霍尔传感器引脚自相矛盾**：`hall-mh248` 节点写 `irq-gpio = <GPIO1_A2>`，而 pinctrl 的 `mh248-irq-gpio` 配置的是 **GPIO1_A1**；同时 GPIO1_A2 已被 FUSB302 占用。该节点本就 disabled，推测是厂商从参考板抄来的残留。
5. **设备树反编译产物的坑**：`DCDC_REG2` 的 `regulator-min-microvolt` 被反编译成了字符串 `"" "\f5"`（原本应是 4 字节大端 `0x000CF850` = **850 mV**）。凡是 4 字节属性里含 `0x00` 的值，反编译后都可能退化成字符串，读到这类属性时要还原成原始字节再解释。
6. **HDMI 与 DP 控制器是 okay 但没路由**：`hdmi@ff940000` 使能且 `route-hdmi` 关闭、HDMI 音频节点 disabled；`dp@fec00000` 使能并挂在 VOPL 上，由 FUSB302 的 extcon 驱动。结合 USB-C PHY0 已使能 DP 通道来看，**Type-C 很可能支持 DP Alt Mode 输出**，但该机外壳上没有 HDMI 口，具体是走 Type-C 还是未引出的焊盘需要实测。
7. **`edp-panel` 与 USB2 PHY1 争用 GPIO3_B0**：前者作为 eDP 面板使能脚，后者作为 OTG VBUS 使能。eDP 未启用，所以当前无冲突，但若要启用 eDP 需先处理这个引脚。
8. **两套触摸驱动并存**：GT9xx（`0x14`）与 GSLX680（`0x40`）同时使能，需按实机确认焊的是哪一颗。
9. **DDR 参数不完整**：`ddr_timing` 只有 LPDDR3/DDR3/LPDDR4 的通用参数且 `ddr3_speed_bin = 0x15`，`dmc`/`dfi` 均 disabled——意味着 DDR 频率与类型完全由 U-Boot 初始化，DTS 里读不出实际 DDR 型号（README 记的「2GB DDR」需用别的方式确认是 DDR3 还是 LPDDR3/4）。



## 附：解析方法

```bash
# 从 kernel 分区提取的 DTB 反编译为 DTS（本文档的来源）
dtc -I dtb -O dts -o xerox-et1020-vendor-dump.dts <提取出的.dtb>
```

十六进制属性按大端整数解释；`phandle` 引用需要回到对应节点查名字（本文档中的 GPIO 引脚号即由此还原：`rockchip,pins` 的第二个 cell 是 bank 内引脚号，0–7 = A0–A7、8–15 = B0–B7、16–23 = C0–C7、24–31 = D0–D7）。



## 参考

[rockchip-devices/xerox-et1020](https://github.com/retro98boy/rockchip-devices/tree/main/devices/xerox-et1020)

[本机分区表解读](../partitions_table/partition_table.txt)