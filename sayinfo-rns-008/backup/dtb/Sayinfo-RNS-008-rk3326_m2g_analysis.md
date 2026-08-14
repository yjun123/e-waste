# DTS 分析报告: Sayinfo-RNS-008 (RK3326 平板)

来源: `backup/dtb/Sayinfo-RNS-008-rk3326_m2g_dump.dts`

## 系统总体信息

| 项目 | 值 |
|---|---|
| Model | "Rockchip rk3326 S863 7 avb board" (S863 = Rockchip PX30/rk3326 官方 SDK 平板方案, 7 英寸) |
| Compatible | `rockchip,rk3326-s863-pc3-rtl8703bs` |
| SoC | RK3326 (PX30) 四核 Cortex-A35 |
| GPU | Mali-G31 (arm,malit602) |
| 序列号 | 100419092403099 |
| 内存 | 约 1GB (两个 region: 0x200000+0x8200000, 0xa200000+0x35e00000, 合计 ~992MB) |
| 启动存储 | eMMC (bootargs `storagemedia=emmc`, fstab 挂 /vendor) |

## 外挂设备清单

### 1. 电源管理 PMIC —— RK817 (I2C0 @0x20)
- `rockchip,rk817`, 中断 GPIO0_A10, `system-power-controller` (系统主电源)
- 稳压器: DCDC1-5 (vdd_logic/vdd_arm/vcc_ddr/vcc_3v0/vcc3v3_sys) + 4 组 LDO + SWITCH1/2
- 电池/充电: `rk817,battery`, 容量 2800mAh (0xaf0), OCV 表, 支持充电动画 (uboot-charge)
- 内置 **RK809 音频 codec** (i2s0 + PDM 双路), 外置功放 `use-ext-amplifier` (PA 驱动 GPIO3_A0, spk-ctl GPIO3_B2)

### 2. 触摸屏 —— GSLX680 电容触控 (I2C1 @0x40)
- `gslX680-d708` (SiS/思立微 GSL1680 系), 分辨率 1024x600
- touch-gpio GPIO0_D5, wake-gpio GPIO0_D4

### 3. 前置摄像头 —— GalaxyCore GC5025 (I2C2 @0x37)
- 500 万像素, MIPI CSI-2 (data-lanes 1,2), facing="front"
- 电源: avdd 2.8V / dovdd 1.8V / dvdd 1.8V (vcc2v8_dvp, vcc1v8_dvp, vdd1v8_lcd)
- pwdn-gpio GPIO2_C6, 镜头模组 "CameraKing"/"Largan"
- `cif_sensor` 节点还定义了 gc2145/gc0312 传感器, 但 status=disabled (未用)

### 4. 显示屏 —— MIPI DSI 7 英寸面板 (ST7703 驱动 IC)
- `simple-panel-dsi`, 1024x600, 4-lane, clock 80MHz
- 使能/STBYB/RESET: GPIO3_A7 / GPIO3_B3 / GPIO3_C4
- PWM 背光 (backlight), enable-gpio GPIO0_B3; route_dsi = active, LVDS/RGB 路由均 disabled

### 5. WiFi/蓝牙 —— 瑞昱 RTL8723BS (compatible 中写为 rtl8703bs)
- WiFi: SDIO 接口 (`sdio` dwmmc), `wifi_chip_type = "rtl8723bs"`, host_wake_irq GPIO0_A5, pwrseq 复位 GPIO0_A2
- 蓝牙: UART1, BT reset GPIO0_C1, wake GPIO0_A1, wake_host GPIO0_A7, uart_rts GPIO1_B3

### 6. 其他外设
- **存储**: eMMC 8-bit HS200 + NAND Flash (nandc0) + SD 卡槽 (sdmmc 4-bit)
- **USB**: OTG (dwc2, dr_mode=otg, 用于充电/数据), host 端口 DT 中 disabled
- **按键**: ADC-keys (音量+/-, SARADC ch2)
- **耳机检测**: rk_headset, headset_gpio GPIO3_A4 + SARADC ch1
- **以太网 GMAC**: RMII, 但 status=disabled (未用, 以 WiFi 为主)
- **FIQ 调试串口**: UART2, 1500000 baud

## 屏幕 / 电源 / 按键 专题分析

### 屏幕显示通路
- **VOP 双通道**: VOPB (大核, `rockchip,px30-vop-big`) + VOPL (小核, `rockchip,px30-vop-lit`), 均带 MMU (iommu)
- **VOPB → DSI** 为当前激活通路 (route_dsi = ok), DSI `rockchip,lane-rate = 0x1f4` (500 MHz/lane)
- **DSI 面板**: `simple-panel-dsi`, 4-lane, RGB888 (dsi,format=0), 初始化序列为首条命令写 ST7703 驱动 (0x8b/0xff/0x82... 即 ST7703 的命令页切换, 复位/STBY 时序 300ms 延时)
  - enable-gpio: GPIO3_A7 (高有效)
  - stbyb-gpio: GPIO3_B3 (STBY 释放)
  - reset-gpio: GPIO3_C4 (低有效)
  - 时序: 1024x600, 80MHz pixel clock, vrefresh 93Hz (route 中 video,vrefresh=0x5d)
- **背光**: `pwm-backlight`, PWM1 (pwm@ff200010, 周期 25000ns=40kHz), 256 级亮度表 (255→0, 低亮度 0x16 段钳位), 默认亮度 200 (0xc8), enable-gpio GPIO0_B3
- LVDS / RGB 输出控制器均存在但 route disabled

### 电源系统
- **主 PMIC**: RK817 (I2C0@0x20), 系统电源控制器, 带 pwrkey (电源键集成在 PMIC 内, status=okay), wakeup-source
- **DCDC 核心轨**:
  - DCDC_REG1 `vdd_logic` (logic 0.95V~1.35V, always-on)
  - DCDC_REG2 `vdd_arm` (CPU 1.0V~1.35V, 由 OPP 表调压)
  - DCDC_REG3 `vcc_ddr` (DDR, always-on)
  - DCDC_REG4 `vcc_3v0` (固定 3.0V)
  - DCDC_REG5 `vcc3v3_sys` (固定 3.3V, 系统主电源轨, always-on)
- **LDO 轨**: vcc_1v0 / vcc1v8_soc / vdd1v0_soc / vcc3v0_pmu / vccio_sd / vcc_sd / vcc2v8_dvp / vcc1v8_dvp / vdd1v8_lcd
- **SWITCH**: vcc3v3_lcd (LCD 背光电源) / vcc5v0_host (USB Host 5V, 常开)
- **电池/充电**: rk817 battery, 2800mAh, 4.2V 满电 (max_chrg_voltage=0x20d0), 充电电流 1800mA (0x708), 输入限流 2000mA (0x7d0), 电池采样电阻 10mΩ
- **Suspend**: `rockchip,pm-px30`, sleep-debug-en; 各轨 suspend 状态: vdd_arm off / vdd_logic on / vcc_ddr on, PMIC slppin 引脚由 GPIO0_A4 (soc_slppin) 控制
- **外部输入电源**: vcc5v0_sys (regulator-fixed, 5V 输入)

### 按键与唤醒
- **Power 键**: 集成于 RK817 pwrkey (长按开关机)
- **音量键**: ADC-keys (SARADC ch2), 三段式电阻分压
  - vol-down: 代码 0x72, 阈值 0x493e0 (300mV)
  - vol-up: 代码 0x73, 阈值 0x4268 (272mV)
  - keyup 阈值 1.8V (0x1b7740)
- **唤醒源配置**: rockchip,wakeup-config = 0x85 (PMIC 电源键 + GPIO 唤醒)
- **耳机检测**: rk_headset, headset_gpio GPIO3_A4 (低有效) + SARADC ch1, 支持线控/麦克风

## 值得注意的几点
1. DTS 中 `wifi_enable_h` pinctrl (GPIO0_B3) 与背光 enable-gpio (GPIO0_B3) 复用了同一引脚, 可能与实际硬件不符 (常见于模板遗留)。
2. 文件名 `m2g` 与 DT 内存 (~1GB) 不匹配, 可能是产品型号命名而非内存容量。
3. 无独立蓝牙/WiFi 芯片 DT 节点, 均通过 `wlan-platdata`/`bluetooth-platdata` 通用驱动挂载, 依赖内核模块 (rtl8723bs) 提供实际功能。
