# Sunniwell RH218 (Z96A/Z96H) 设备树外设硬件分析

> 源文件：`sunniwell-z96a_new-z96h-vendor-dump.dts`（173,696 字节）
> 平台：Rockchip RK3568

## 一、设备基本标识

- **平台**：Rockchip RK3568（4× Cortex-A55 @ 最高 1.8GHz）
- **板型**：`Sunniwell RK3568 RH218 V01 Board` / `rockchip,rk3568-evb1-ddr4-v10`
- **序列号**：`S561-0AAC-00001007`，机型 `Z96A`
- **启动介质**：`storagemedia=emmc`（chosen 节点，行 5944）
- **控制台**：`ttyFIQ0`，earlycon 串口 `0xfe660000`（即 UART2）
- **预留内存**：`0x0a100000` (140KB) 与 `0x0a200000` (~880KB) 两段

---

## 二、通信类外设

### 1. UART（10 路）— 行 1697

| 别名 | 基址 | 状态 | 用途推断 |
|------|------|------|---------|
| serial0 | 0xfdd50000 | disabled | 调试备用 |
| serial1 (UART2) | 0xfe650000 | **okay** | 系统调试串口（fiq-debugger 复用此端口） |
| serial2~9 | 0xfe660000~0xfe6d0000 | 除 serial1 外均 disabled | 蓝牙 UART 在 serial2 上配置 |

- 兼容 `rockchip,rk3568-uart / snps,dw-apb-uart`，带 DMA。

### 2. I2C（6 路）— 行 1280

| 总线 | 基址 | 状态 | 关键外挂器件 |
|------|------|------|------------|
| i2c0 | 0xfdd40000 | **okay** | PMIC rk809@0x20、PD 芯片 husb311@0x4e、CPU 供电 tcs4525@0x1c、充电 IC sc8886@0x6b |
| i2c1 | 0xfe5a0000 | okay | 空 |
| i2c2 | 0xfe5b0000 | disabled | — |
| i2c3 | 0xfe5c0000 | **okay** | 音频 ADC **ES7202@0x30**、ES7202_sdi3@0x32（PDM 麦克阵列） |
| i2c4 | 0xfe5d0000 | disabled | — |
| i2c5 | 0xfe5e0000 | **okay** | 加速度传感器 **mxc6655xa@0x15**（gs_mxc6655xa） |

### 3. SPI（4 路 + 1 SFC）— 行 4013

- spi0~spi3（0xfe610000~0xfe640000）：**全部 disabled**
- `spi4 = sfc@0xfe300000`：**okay**，SPI NOR/Flash 控制器，时钟 100MHz

### 4. CAN（3 路，均 disabled）— 行 3804

- 兼容 `rockchip,canfd-1.0`，FIFO 1/6，波特时钟 240MHz

### 5. USB — 行 937

| 控制器 | 基址 | 模式 | 状态 |
|--------|------|------|------|
| DWC3 OTG (USB3.0) | 0xfcc00000 | **otg**（双角色） | okay，由 husb311 PD 控制 extcon |
| DWC3 Host (USB3.0) | 0xfd000000 | host | okay |
| EHCI/OHCI #1 | 0xfd800000/0xfd840000 | host | okay（USB2.0 Host1） |
| EHCI/OHCI #2 | 0xfd880000/0xfd8c0000 | host | okay（USB2.0 Host2） |

- 2 个 USB2 PHY（0xfe8a0000、0xfe8b0000）均 okay，分别提供 OTG/Host 端口
- 3 路 vcc5v0 USB host 供电（含键盘专用 `vcc5v0-usb-keyboard`）
- 由 `regulator-ctrl`（sunniwell,regulator_ctrl）协调 host1/host2/keyboard 三路供电

### 6. 无线模块 — 行 5785

- **WiFi**：`rtl8822cs`（Realtek SDIO 模块），通过 dwmmc@0xfe000000（mmc3，supports-sdio）
- **蓝牙**：走 UART2（serial2/0xfe660000），PMIC rk809 提供休眠时钟，BT,wake_host_irq
- `sdio-pwrseq` 控制 WiFi 模块上电时序（reset gpio = gpio0 0x10）

---

## 三、存储类外设

### 1. eMMC — 行 3532

- **8-bit 总线**，`supports-emmc`，non-removable，最大频率 200MHz
- 启动盘（bootargs `boot_devices=fe310000.sdhci,...`）

### 2. SDMMC — 行 3490

- 4-bit，cap-sd-highspeed、`sd-uhs-sdr104`（UHS-I SDR104）
- 关联 vccio_sd 由 PMIC LDO_REG5（3.3V）提供 + vcc3v3_sd 由 SWITCH_REG2 提供
- status = "disabled"

### 3. SDIO（WiFi）— 行 3503

- 4-bit，`supports-sdio`，non-removable，带 mmc-pwrseq

### 4. NAND — 行 3549

- 兼容 `rockchip,rk-nandc-v9`，**okay**
- 子节点 `nand@0`：8-bit 总线，硬件 ECC，strength=16，step=1024B
- 也作为可选 boot_device 之一

### 5. SFC（SPI Flash）— 行 3520

- okay，100MHz 时钟，用于存放 bootloader/小固件

---

## 四、显示与多媒体外设

### 1. 显示通路总览 — 行 522

VOP（`vop@fe040000`）三路 video port，路由配置：
- **route-edp**：okay（主显示屏，fullscreen logo）— `video,hdisplay=0x780 (1920)`, `vdisplay=0x438 (1080)`
- **route-hdmi**：okay（副屏，center logo）
- route-dsi0/dsi1/lvds/rgb：disabled

### 2. eDP 主屏 — 行 2959

- `force-hpd;` + `sunniwell,rh218=<0x01>`（厂商定制标识）
- 接 `edp_panel`（simple-panel，6 bpc，bus-format 0x1009 = MEDIA_BUS_FMT_RGB666_1x18）
- 背光：`backlight` (PWM0@0xfe6f0010)，256 级亮度
- 供电：`vcc3v3-lcd0-n` 由 gpio0 0x17 使能

### 3. HDMI — 行 2916

- DW-HDMI，含 CEC，phy-table 支持到 594MHz 像素时钟（4K@30）
- 接在 VOP port@1 endpoint@3（status okay）
- 音频：`hdmi-sound` simple-card，I2S0 作 CPU DAI

### 4. MIPI DSI — 行 2702

- dsi0 节点本身 `status=disabled`，但其下 `panel@0` status=okay
- panel：simple-panel-dsi，**4-lane**，timing：1080×1920 (hactive=0x438, vactive=0x780)，66MHz 像素时钟
- 含完整的 panel-init-sequence 命令数组
- dsi1（0xfe070000）：disabled

### 5. GPU — 行 1989

- `arm,mali-bifrost`（Mali-G52），最高 800MHz @ 1.0V
- 接 `opp-table2`，含 PVTM/leakage 自适应电压，独立电源域 pd_gpu

### 6. NPU — 行 1846

- `rockchip,rk3568-rknpu`，最高 1GHz @ 1.0V
- 默认运行点 600MHz，1GHz OPP 已 `disabled`

### 7. 视频编解码 — 集中在 0xfdea0000~0xfdf80000（行 2098）

| 模块 | 基址 | 功能 | 状态 |
|------|------|------|------|
| vdpu | 0xfdea0400 | VPU 解码（H.264/H.265 等） | okay |
| rk_rga | 0xfdeb0000 | RGA2 2D 加速 | okay |
| ebc | 0xfdec0000 | E-ink TCON | disabled |
| jpegd | 0xfded0000 | JPEG 解码 | okay |
| vepu | 0xfdee0000 | VPU 编码 | okay |
| iep | 0xfdef0000 | 图像增强 | (省略，含 IOMMU) |
| eink | 0xfdf00000 | E-ink | (省略) |
| rkvenc | 0xfdf40000 | H.265/H.264 视频编码器 | okay，含 OPP 表 |
| rkvdec | 0xfdf80200 | H.265/H.264 视频解码器 | okay |

### 8. 摄像头通路 — 行 2385

- MIPI CSI2 host、rkcif、rkisp、csi2-dphy0/1/2：**全部 disabled**
- 即本板未启用 SoC 原生摄像头通路（可能依赖 USB 摄像头）

---

## 五、网络外设

### GMAC — 行 2505 / 3417

| 接口 | 基址 | phy-mode | MAC | 状态 |
|------|------|---------|-----|------|
| ethernet0 (GMAC1) | 0xfe2a0000 | rgmii | 2e:fe:8c:3c:6c:9c | **disabled** |
| ethernet1 (GMAC0) | 0xfe010000 | rgmii | 32:fe:8c:3c:6c:9c | **disabled** |

- 两路 GMAC 均 **disabled**，板子通过 WiFi（rtl8822cs）联网
- XPCS（10G/2.5G PCS，`syscon@fda00000`）也 disabled
- PHY 复位 gpio 通过 `snps,reset-gpio` 配置（PA25 / PA27）

### SATA — 行 892

- sata0@0xfc000000、sata1@0xfc400000：disabled
- **sata2@0xfc800000：okay**（实际启用的 SATA 口），使用 combphy@0xfe840000
- 兼容 `snps,dwc-ahci`

### PCIe — 行 3297

| 控制器 | 域 | lanes | link-speed | 状态 |
|--------|----|----|---------|------|
| pcie@fe260000 | 0 | 1 | Gen2 | disabled |
| pcie@fe270000 | 1 | 1 | Gen3 | disabled |
| pcie@fe280000 | 2 | 2 | Gen3 | disabled |

- 三路 PCIe 全 disabled，pcie3-phy@0xfe8c0000 也 disabled

---

## 六、音频外设

集中在 0xfe400000~0xfe478000（行 3614）：

| 模块 | 基址 | 用途 | 状态 |
|------|------|------|------|
| i2s0 | 0xfe400000 | HDMI 音频输出（playback-only） | **okay** |
| i2s1 | 0xfe410000 | rk809 codec（I2S 双工） | **okay** |
| i2s2 | 0xfe420000 | 蓝牙 SCO（bt-sound，dsp_b 格式） | **okay** |
| i2s3 | 0xfe430000 | 预留 | disabled |
| pdm | 0xfe440000 | PDM 麦克阵列采集 | **okay** |
| vad | 0xfe450000 | 语音活动检测 | disabled |
| spdif | 0xfe460000 | S/PDIF 输出 | **okay** |
| audpwm | 0xfe470000 | Audio PWM | disabled |
| codec-digital | 0xfe478000 | 数字 codec | disabled |

### 关键音频链路（simple-audio-card）

1. **rk809-sound**：I2S1 ↔ PMIC 内置 codec（rk809/rk817），mclk-fs=256
2. **hdmi-sound**：I2S0 ↔ HDMI，mclk-fs=128
3. **sound_es7202**：PDM ↔ ES7202 PDM ADC（i2c3 上的 2 片 ES7202）
4. **bt-sound**：I2S2 ↔ bt-sco (dfbmcs320)
5. **spdif-sound**：SPDIF ↔ linux,spdif-dit

### PMIC codec 配置 — 行 1654

- mclk 12.288MHz，mic-in-differential，use-ext-amplifier
- `spk-use-aw8737s`（外挂 AW8737S 功放），spk-ctl-gpio = gpio4 0x06

---

## 七、其他外设

### 1. 电源管理 PMIC — 行 1336

挂在 i2c0，是核心 PMIC：
- 5 路 DCDC：vdd_logic / vdd_gpu / vcc_ddr / vdd_npu / vcc_1v8
- 9 路 LDO：vdda0v9_image、vdda_0v9、vdda0v9_pmu、vccio_acodec、vccio_sd、vcc3v3_pmu、vcca_1v8、vcca1v8_pmu、vcca1v8_image
- 2 路 Switch：vcc_3v3、vcc3v3_sd
- 内置 pwrkey、`rockchip,system-power-controller`、长按 6s 重启
- 集成电量计（`rk817,battery`，design_capacity=5125mAh，design_qmax=5500mAh）

### 2. 充电管理 — 行 1666

- SouthChip SC8886，I2C0 0x6b
- 支持最大充电电压 8.4V、最大充电电流 1A、输入电压 15V、输入电流 6A
- 含 NTC 温度检测表，OTG 输出 5V/0.5A

### 3. USB-C PD — 行 1313

- Hynetek HUSB311，I2C0 0x4e
- dual-role（source/sink），op-sink-microwatt = 10W
- 控制 USB3 OTG 的 extcon 与 vbus-switch

### 4. CPU 供电 — 行 1293

- TCS4525/FAN53555，vdd_cpu，0.6–1.4V，ramp-delay 2300uV/us

### 5. ADC / 按键 — 行 4398

- SARADC 6 通道，vref = vcca_1v8
- `adc-keys` 用 channel 2 实现音量+/音量- 按键（轮询 100ms）
- channel 4 给 SC8886 测温、channel 5 给 rk817 测电池

### 6. 温度传感 — 行 4383

- `rockchip,rk3568-tsadc`，硬件过热关断 120°C（0x1d4c0），关断模式 GPIO

### 7. 其他外挂器件

| 设备 | 类型 | 节点 |
|------|------|------|
| mxc6655xa@0x15 | 三轴加速度传感器（i2c5） | gs_mxc6655xa，irq-gpio=PA17 |
| hall-mh248 | 霍尔开关（皮套检测） | irq-gpio=gpio0 0x16，hall-active=1 |
| rk-headset | 耳机插入检测 | headset_gpio=gpio4 0x12 |
| leds | 工作 LED | gpio-leds，work led = gpio0 0x1b，默认常亮 |
| adc-keys | 音量键 | 通过 SARADC 分压 |
| pwm@fe6e0030 | 红外遥控解码 | rockchip,remotectl-pwm，3 套 usercode |

### 8. DMA / 中断 / 安全

- 2 个 PL330 DMAC（0xfe530000、0xfe550000）
- GIC-v3 @ 0xfd400000，含 ITS @0xfd440000（MSI）
- `crypto@fe380000`（RSA/AES/SHA）：disabled
- `rng@fe388000`（TRNG）：okay
- `otp@fe38c000`：存 CPU code/leakage/pvtm 等
- `mailbox@fe780000`：disabled
- `rkscr@fe560000`（智能卡控制器）：disabled

### 9. GPIO — 行 4612

5 个 GPIO bank（gpio0~gpio4），gpio0 在 PMU 域（0xfdd60000），其余 0xfe740000~0xfe770000。

---

## 八、外设启用状态总览

```
启用 (okay)：
  UART1(调试), UART2(蓝牙/fiq)
  I2C0/1/3/5 (PMIC/PD/充电/ES7202/加速度计)
  eMMC, NAND, SFC, SDIO(WiFi)
  USB3 OTG, USB3 Host, USB2 Host×2
  HDMI, eDP, MIPI-DSI0 panel, VOP, GPU, NPU
  VPU/VEPU/JPEGD/RKVENC/RKVDEC/RGA, IEP
  I2S0/1/2, PDM, SPDIF (4 路音频链)
  WiFi(rtl8822cs), Bluetooth
  SATA2, SARADC, TSADC, TRNG, GPIO×5
  rk809 PMIC, sc8886 充电, husb311 PD, tcs4525 CPU 供电
  加速度计, 霍尔, 耳机检测, LED, 红外遥控

禁用 (disabled)：
  GMAC×2 (有线网), XPCS
  PCIe×3 + pcie3-phy
  SATA0/1, CAN×3
  SPI0~SPI3, I2C2/4
  UART0, UART3~9
  MIPI-CSI2/CIF/ISP/CSI2-DPHY×3 (无原生摄像头)
  I2S3, VAD, audpwm, codec-digital, ebc/eink
  Crypto, Mailbox, rkscr 智能卡
```

---

## 九、关键硬件设计要点

1. **电池供电便携设备**：完整含充电 IC（SC8886）+ PD 协商（HUSB311）+ 电量计（rk817）+ 关机充电动画（`charge-animation`）
2. **显示双屏**：eDP 主屏（1080p，可能为 1920×1080 IPS，带背光）+ HDMI 副屏
3. **音频丰富**：4 路并行音频链（HDMI / PMIC codec+AW8737S 功放 / 蓝牙 SCO / PDM 麦克阵列）
4. **无有线网/无 PCIe 设备**：网络依赖 WiFi；存储主走 eMMC，NAND 与 SFC 备用
5. **sunniwell 定制**：在 edp 节点带 `sunniwell,rh218=<0x01>` 标识，以及 `sunniwell,regulator_ctrl` 协调多路 USB 供电
6. **启动路径**：`androidboot.boot_devices=fe310000.sdhci,fe330000.nandc` —— eMMC 优先，NAND 备选
7. **DDR 配置**：提供 DDR3/DDR4/LPDDR3/LPDDR4/LPDDR4X 五套参数表（`dmc-fsp`），实际使用 DDR4（板型字符串 `evb1-ddr4-v10`）
