# Z96A 两块主板设备树对比

对比两份厂商固件转储（`dtc` 反编译）的设备树：

| 版本 | 序列号 | 文件 |
| --- | --- | --- |
| **DC**（2022） | `S561-0AA9-00005339` | `Z96A-DC/dtb-S561-0AA9-00005339/sunniwell-z96a-2022-vendor-dump.dts` |
| **PD**（2023） | `S561-0AAC-00000348` | `Z96A-TYPEC/dtb-S561-0AAC-00000348/sunniwell-z96a-2023-vendor-dump.dts` |

> 结论一句话：这是 **两块不同主板的板级配置**。DC 版是早期“DC 圆头供电 + rk817 内部充电 + HDMI 输入/摄像头”的笔电板；PD 版是后期“USB-PD 充电（SC8886 + 2S 电池）+ ES7202 麦克风阵列 + RGMII 双网口”的整机板（型号 RH218 V01）。两者 SoC（RK3568）、内存（4GB DDR4）、eMMC 相同。

---

## 0. 差异规模与噪声说明

`diff` 共 **6167 行**（`+1309` / `-1339`），但其中**大部分是 phandle 重编号**，不是语义变化：

- PD 版删除了 `rknpu_reserved`（原 phandle `0x68`）这个 reserved-memory 节点，导致其后**所有节点 phandle 值整体偏移**（多数 +6，后续还有其它偏移）。
- 纯 `phandle = <0xNN>` 以及 `rockchip,grf = <0xNN>`、`pinctrl-0 = <0xNN>`、`interrupt-parent = <0xNN>` 这类**引用型数值的平移**都属于此噪声。

下文只列**语义上的真实差异**。

---

## 1. 板卡身份

| 属性 | DC（2022） | PD（2023） |
| --- | --- | --- |
| `serial-number` | `S561-0AA9-00005339` | `S561-0AAC-00000348` |
| `compatible` | `rockchip,rk3568-evb2-lp4x-v10` | `rockchip,rk3568-evb1-ddr4-v10` |
| `model` | `Sunniwell RK3568 DDR4 Laptop Board` | `Sunniwell RK3568 RH218 V01 Board` |
| 有线网卡 MAC（gmac0/gmac1） | `42:e6:60:23:a0:6f` / `3e:e6:60:23:a0:6f` | `82:b4:95:dd:43:8b` / `7e:b4:95:dd:43:8b` |

> `compatible` 的 `lp4x`→`ddr4` 只是参考板名字符串变化；`memory` 区域与 DDR 参数两份完全一致（见 §3），并不代表实际内存类型改变。

---

## 2. 电源 / 充电架构（最大差异）

这是两块板**最本质**的区别。

### 2.1 PMIC：`rk817` → `rk809`

| | DC | PD |
| --- | --- | --- |
| PMIC | `rockchip,rk817`（内置充电器 + 电量计 + Codec） | `rockchip,rk809`（**无充电器**，仅电量计） |
| CPU 降压 | `syr837@40`（`silergy,syr827`） | `tcs4525@1c`（`tcs,tcs452x`，新增 `regulator-init-microvolt=0.9V`、`regulator-boot-on`） |
| USB-C 控制器 | `fusb302`（`fusb30x@22`）+ `husb311`（`husb311@4e`） | 仅 `husb311`（新增 `switch-ctl-gpios`） |
| 充电器 | rk817 内部（`charging-gpios` / `charger-done-gpios`） | **`sc8886@6b`**（`southchip,sc8886`，NVDC 升降压，USB-PD，2S） |

### 2.2 充电芯片 SC8886（PD 版新增，DC 版无）

| 参数 | 值 | 属性 |
| --- | --- | --- |
| 充电电流 | 1.0 A | `ti,charge-current = 0xf4240` |
| 最大充电电压 | 8.4 V（2S） | `ti,max-charge-voltage = 0x803c20` |
| 输入电流 / 最大输入电流 | 3.0 A / 6.0 A | `ti,input-current` / `ti,max-input-current` |
| 最大输入电压 | 15 V | `ti,max-input-voltage` |
| 最小系统电压 | 6.6 V | `ti,minimum-sys-voltage` |
| OTG 输出 | 5 V / 0.5 A | `ti,otg-voltage` / `ti,otg-current` |

电池温度经 **SARADC 通道 4**（NTC 表 81 点，-20～+60°C）采样，电量经 **SARADC 通道 5** 判断。详见 [`battery-charging.md`](./battery-charging.md)。

### 2.3 电池节点（`battery`）

| 参数 | DC | PD |
| --- | --- | --- |
| 内阻上/下界 | `bat_res_up=110` / `bat_res_down=27` | `bat_res_up=140` / `bat_res_down=20` |
| 最大电压 | `design_max_voltage = 8350 mV` | `design_max_voltage = 8300 mV` |
| ADC 通道 | 通道 1（`capacity-chan-1`，`battery-use-adc`） | 通道 5（`battery-chan-5`） |
| 充电/完成 GPIO | `charging-gpios` / `charger-done-gpios`（rk817） | 移除，改为 `enough-led-ctl-gpios` / `charging-led-ctl-gpios`（指示灯） |

### 2.4 PMIC 各路电源重映射（regulator）

rk809 的通道比 rk817 少，厂商把原 rk817 的 rail 重新分配：

| 通道 | DC（rk817） | PD（rk809） |
| --- | --- | --- |
| `DCDC_REG4` | `vcc_3v3`（3.3V 固定） | `vdd_npu`（0.5～1.35V 可调） |
| `DCDC_REG5` | —（无此节点，用 `BOOST`） | `vcc_1v8`（新增） |
| `LDO_REG1` | `vcca1v8_pmu` | `vdda0v9_image`（0.9V） |
| `LDO_REG7` | `vcc_1v8` | `vcca_1v8` |
| `LDO_REG8` | `vcc1v8_dvp` | `vcca1v8_pmu` |
| `LDO_REG9` | `vcc2v8_dvp` | `vcca1v8_image`（新增） |
| `BOOST` | `boost`（5V） | 移除 |
| `OTG_SWITCH` | `otg_switch` | 移除 |
| `SWITCH_REG1` | — | `vcc_3v3`（新增） |
| `SWITCH_REG2` | — | `vcc3v3_sd`（新增） |

> 原来 DVP（并行摄像头）供电 `vcc1v8_dvp` / `vcc2v8_dvp` 全部消失，与 §9 摄像头被移除一致。

### 2.5 Codec 子节点

- `rk817_codec`（`#sound-dai-cells = <1>`，`use-ext-amplifier`，音量 hp=3/spk=10/capture=48）→ `rk809_codec`（`#sound-dai-cells = <0>`，音量 hp=20/spk=3，`use-ext-amplifier` 保留，`spk-ctl-gpios` 引脚变化）。

---

## 3. 内存 / DDR

**完全一致**：`memory` reg 相同（约 4GB：`0x200000..` + `0x9400000..` 两段 + 高于 4G 的 256MB），`ddr3/4/lpddr3/lpddr4/lpddr4x_params` 各参数（频率、时序、map）逐字节相同，只有 phandle 值偏移。

---

## 4. CPU / GPU / NPU / 媒体 OPP

### 4.1 CPU OPP（`cpu_opp_table`）

- **删除了 `opp-microvolt-L0/L1/L2` 泄漏分档**：DC 版有 L0=0.85V / L1=L2=0.825V 三档，PD 版去掉分档（保留单一 `opp-microvolt`）。
- 具体数值变化：
  - `opp-600000000`：`opp-microvolt` 从 `<0.85V 0.825V 1.15V>` → `<0.85V 0.85V 1.15V>`（低压档抬高到 0.85V）。
  - `opp-1104000000`（1.104GHz）：`L1/L2` 从 0.825V → 0.85V。

### 4.2 NPU（`rknpu`）——由禁用变为启用

| | DC | PD |
| --- | --- | --- |
| `rknpu` 状态 | `disabled` | `okay` |
| `rknpu_iommu` | `disabled` | `okay` |
| `bus_npu` | `disabled` | `okay` |
| `memory-region`（`rknpu_reserved`，128MB） | 有 | **移除** |

> DC 版保留了一个 128MB 的 NPU 保留内存却把 NPU 禁用；PD 版启用 NPU 并移除该保留区（改由 CMA 分配）。

### 4.3 视频/编解码（VPU / VENC / VDEC）

- `vdec` / `venc` / `vpu` OPP 表里 `opp-microvolt` 由 `0x00`（未指定）改为 `0xdbba0`（0.9V），并补 `L0=0.9V / L1=L2=0.875V` 分档。
- `rkvdec` 新增 `nvmem-cells`（`leakage` / `pvtm`）及 `rockchip,leakage-voltage-sel`、`rockchip,pvtm-voltage-sel`、`rockchip,pvtm-ch` —— 即 PD 版为编解码器加入了**按芯片泄漏/温度分档的电压选择**。
- GPU（`gpu@fde60000`）OPP 的 `L1/L2` 由 0.825V → 0.85V（与 CPU 一致的去分档/抬压处理）。

---

## 5. 存储（eMMC / SD / SATA）

| 接口 | DC | PD |
| --- | --- | --- |
| eMMC `sdhci@fe310000` | `supports-emmc`（相同） | 相同 |
| SD 卡 `sdmmc0@fe2b0000` | `supports-sd`（`status=disabled`） | **移除全部 SD 配置**（`status=disabled`，空节点） |
| WiFi `sdmmc1@fe2c0000` | `supports-sdio`，`rtl8821cs` | `supports-sdio`，**`rtl8822cs`** |
| `sdmmc2@fe000000` | 空（`disabled`） | 新增一套 `supports-sdio` 配置（仍 `disabled`） |
| **SATA** `sata@fc800000` | `disabled` | **`okay`**（启用 SATA 口） |

> WiFi 芯片从 **RTL8821CS** 换为 **RTL8822CS**（`wifi_chip_type`），BT 相关 GPIO（`BT,reset_gpio` / `BT,wake_gpio`，并新增 `BT,wake_host_irq`）引脚也不同。

---

## 6. 以太网

DC 版 `gmac0` 走 **QSGMII**，一个 MDIO 总线上挂了 **4 个 PHY**（`qsgmii_phy0..3`，`ethernet-phy-id001c.c942`），典型是板载四口交换机 PHY，但该 gmac 状态为 `disabled`。

PD 版改为 **RGMII**，两个 GMAC 都配置：

| | DC | PD |
| --- | --- | --- |
| `gmac0@fe010000` | QSGMII，4×PHY，无复位/延迟 | RGMII（`phy-mode="rgmii"`、`clock_in_out="output"`、`reset-gpio`、`tx_delay=0x4f`、`rx_delay=0x26`、单 PHY `rgmii_phy1`） |
| `gmac1@fe2a0000` | `disabled` | RGMII（同套配置 + 单 PHY `rgmii_phy0`、`tx_delay=0x3c`、`rx_delay=0x2f`） |
| `xpcs` | `okay` | `disabled` |

- 新增 `gmac0` / `gmac1` 的 pinctrl 组（`gmac0_miim`、`gmac0_rgmii_bus` 等 10 个）。

---

## 7. USB / Type-C

- `usbdrd_dwc3`（USB3）：`extcon` 从 2 路（fusb302 + husb311）减为 **1 路**（仅 husb311），`extcon_num` 移除。
- `husb311` 的 `connector`（`usb_con`）两份都存在（`power-role/dual`、`sink-pdos=0x40190c8` 即 15V/3A），**保留**。
- PD 版新增固定 5V 稳压器 + 控制节点：
  - `vcc5v0_usb2_host1` / `vcc5v0_usb2_host2` / `vcc5v0_usb_keyboard`
  - `regulator_ctrl`（`sunniwell,regulator_ctrl`，聚合上面三个 supply）
- 相应 pinctrl：`vcc5v0_otg_en` 引脚变化，新增 `vcc5v0_usb2_host1_en` / `host2_en`。

---

## 8. 显示（eDP / HDMI）

| 项 | DC | PD |
| --- | --- | --- |
| eDP `route_edp` 时钟 | `video,clock = 0x2283a`（约 141.4kHz 单位） | `video,clock = 0x223d0` |
| HDMI `route_hdmi` | `cubic_lut,offset = <0>` | 改为 **`bcsh` 色彩参数**（`hue/saturation/contrast/brightness = 0x32` = 50） |
| 开机 logo 模式 | `fullscreen` | `center` |
| `edp_panel` | `bus-format=0x100a`（RGB888）、`bpc=8`、`enable-gpios` | **`bus-format=0x1009`（RGB666）、`bpc=6`、无 `enable-gpios`** |
| eDP 节点 | — | 新增 `sunniwell,rh218 = <1>`（板级标记） |
| 背光 PWM | `pwm10`（okay） | **`pwm9`（disabled→okay）** 作背光，`pwm10` 改为 disabled |

---

## 9. 摄像头 / HDMI 输入（DC 有、PD 全删）

DC 版存在以下节点，PD 版**全部移除**：

- `mipi_csi2@fdfb0000`（含 `mipi_csi2_input` / `mipi_csi2_output` 端点）
- `rkcif_mipi_lvds`（`cif_mipi_in` 端点）
- `csi2-dphy0`（`hdmi_to_mipi_in` / `csidphy_out` 端点）
- `lt6911uxc@2b`（Lontium **HDMI 输入**采集芯片，带 power/reset/plugin/hpd GPIO）
- `ext_cam_clk`（24MHz `CLK_CAMERA_24MHZ` 固定时钟）

> 即 PD 版不再支持摄像头与 HDMI-in（画面采集）功能，与 §2.4 DVP 电源移除相互印证。

---

## 10. 音频

| 项 | DC | PD |
| --- | --- | --- |
| Codec | rk817 内置 codec | rk809 codec |
| 麦克风 | （无独立） | **`es7202@30` + `es7202_sdi3@32`**（双 PDM 数字麦克风，`ES7202_PDM_ADC_1/2`） |
| 声卡 | `rk817_sound` | `rk809_sound` + **`sound_es7202`**（`format=pdm`） |
| PDM `pdm@fe440000` | `disabled` | `okay`（新增 `rockchip,path-map`） |
| SPDIF | `disabled` | `okay`（`spdif-sound`、`spdif_out` 均启用） |
| VAD | — | 新增 `vad_sound`（`disabled`，唤醒词） |
| 耳机 | `rk_headset`（含 `mic_sw_gpio`） | `rk_headset`（**移除 `mic_sw_gpio`**，`headset_gpio` 引脚变化） |

---

## 11. 传感器 / I2C

- **加速度计 `gs_mxc6655xa@15`**：从 `i2c4@fe5d0000` 移到 **`i2c5@fe5e0000`**，节点名改为 `mxc6655xa`，`irq-gpio` 引脚变化（GPIO 组引用从 `0x42`→`0x44`）。
- I2C 状态变化：`i2c1@fe5a0000`、`i2c3@fe5c0000`、`i2c5@fe5e0000` 由 `disabled` → `okay`。
- **霍尔传感器 `hall_mh248`**：`irq-gpio` 引脚变化（`0x3a 0x16` → `0x37 0x16`）。

---

## 12. 红外遥控 / ADC 按键

- **红外遥控**：DC 版 `remotectl-pwm`（`rockchip,remotectl-pwm`）带 `ir_key1/2/3` 三个按键表；PD 版改为普通 `rockchip,rk3568-pwm`，**删除了全部 IR 键表**（PD 版无红外接收）。
- **ADC 按键 `adc_keys`**：阈值表达方式变化
  - `keyup-threshold-microvolt = <0x1b7740>`（单一值）→ `keyup-threshold-microvolt-max/min`
  - 各键 `press-threshold-microvolt`（单一值）→ `press-threshold-microvolt-min/max` 区间
  - 按键数量与 `linux,code` 有调整（menu/back 键定义合并变化）

---

## 13. 其他节点增删

**PD 版新增：**

- `regulator_ctrl`（`sunniwell,regulator_ctrl`）、`vcc5v0_usb2_host1/2`、`vcc5v0_usb_keyboard`
- `sound_es7202`、`vad_sound`
- `es7202@30`、`es7202_sdi3@32`
- `sc8886@6b`
- `gmac0` / `gmac1` pinctrl 组
- 指示灯 LED（`label="work"`、`default-state="on"`、`linux,default-trigger="none"`）

**PD 版删除：**

- `rknpu_reserved`（128MB NPU 保留内存）
- `fusb0`（fusb302）
- `lt6911uxc` 及其端点、`mipi_csi2` / `csi2-dphy0` / `rkcif_mipi_lvds`、`ext_cam_clk`
- `dc_det`（`sunniwell_dc_det`，DC 插入检测）
- `vcc_sys` 固定稳压器
- IR 遥控键表（`ir_key1/2/3`）
- `vsel_gpio`、`uart8_gpios` 等 pinctrl 节点

---

## 14. 启动参数（`bootargs`）

两处差异：

1. `androidboot.serialno=S561-0AA9-00005339` → `androidboot.serialno=S561-0AAC-00000348`
2. PD 版新增 **`androidboot.model=Z96A`**

其余（`storagemedia=emmc`、`androidboot.boot_devices=fe310000.sdhci,fe330000.nandc`、`earlycon=uart8250,mmio32,0xfe660000` 等）完全一致。

---

## 附录 A：电压/数值对照

| 十六进制 | 十进制 | 含义 |
| --- | --- | --- |
| `0xcf850` | 850000 µV | 0.85V（CPU 低压档） |
| `0xc96a8` | 825000 µV | 0.825V（泄漏 L1/L2 档） |
| `0xd59f8` | 875000 µV | 0.875V |
| `0xdbba0` | 900000 µV | 0.9V |
| `0x118c30` | 1150000 µV | 1.15V（上限） |
| `0x325aa0` | 3300000 µV | 3.3V |
| `0x1b7740` | 1800000 µV | 1.8V |
| `0x7a120` | 500000 µV | 0.5V |
| `0x149970` | 1350000 µV | 1.35V |
| `0x803c20` | 8400000 µV | 8.4V（2S 充电电压） |
| `0xe4e1c0` | 15000000 µV | 15V |
| `0x4c4b40` | 5000000 µV | 5V |

## 附录 B：phandle 偏移说明

`dtc` 在反编译时按节点出现顺序给 `phandle` 编号。PD 版删除 `rknpu_reserved`（原 `phandle = <0x68>`）后，其后所有节点的 phandle 依次前移（+6 起步，后续还因删/增节点叠加更多偏移）。因此 diff 中大量：

```
-  phandle = <0x141>;
+  phandle = <0x146>;
```

以及 `rockchip,grf = <0x35>` → `<0x33>`、`pinctrl-0 = <0xNN>`、`interrupt-parent = <0xNN>`、`dmas = <0xNN ...>`、`remote-endpoint = <0xNN>` 等的数值变化，**均为同一次重编号的连锁反应，不代表硬件连接变化**。
