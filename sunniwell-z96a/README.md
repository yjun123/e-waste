# Sunniwell Z96A

English · [简体中文](README.zh-CN.md)

The [Sunniwell](https://www.sunniwell.com/) Z96A is an RK3568‑based ARM cloud laptop pre‑loaded with Android 11 for cloud desktop VDI usage.

![Z96A](./images/laptop.jpg)

Multiple hardware revisions exist on the market: although they all carry the *Z96A* label, they differ in their casing material, connectors (charging connector and Micro SD slot) and peripheral chips (charger, fuel gauge, Type-C controller, PMIC and Wi-Fi).

The revision can be roughly identified by the serial number on the casing label (note: the serial number is visible in both the stock Android system and the device tree):

| Serial number | Casing material | Charging port | Micro SD slot | Charger | Fuel gauge | Type-C controller | PMIC | Wi-Fi |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S561-0AA4-xxxxxxxx<br />S561-0AA5-xxxxxxxx<br />S561-0AA9-xxxxxxxx<br />S561-0AAB-xxxxxxxx | Metal | DC | reserved pads present | CN3705 | none | FUSB302<br />HUSB311 | RK817 | RTL8821CS |
| S561-0AAC-xxxxxxxx | Plastic | Type-C | none | SC8886S | none | HUSB311 | RK809 | RTL882**2**CS |



## Hardware

The hardware listed below currently only includes the Type‑C charging revision.

| Specifications          | Description                                                  |
| ----------------------- | ------------------------------------------------------------ |
| Model                   | Z96A                                                         |
| Main board PCB revision | V02 201132                                                   |
| USB board PCB revision  | V01 528032                                                   |
| SoC                     | Rockchip [RK3568B2](https://www.rock-chips.com/a/en/products/RK35_Series/2021/0113/1276.html) @2.0GHz / Quad-Core ARM Cortex-A55 / Mali-G52 2EE GPU |
| PMIC                    | Rockchip [RK809-5](https://rockchip.fr/RK809%20datasheet%20V2.7.pdf) / PMIC / Audio codec |
| DRAM                    | 4GB Rayson [RS1G32LO4D2BDS-53BT](https://szrayson.com/product_23/136.html) / LPDDR4X / x32 / 3733Mbps / FBGA 200-ball / 1.8/1.1/0.6V |
| eMMC                    | 32GB SiliconGo SGM8200C-S32BBG / HS400 / eMMC 5.1 / FBGA153 |
| WiFi/BT                 | Realtek [RTL8822CS](https://bbs.16rd.com/thread-602771-1-1.html) / 802.11 a/b/g/n/ac / BT4.2 / 2T2R |
| Display                 | BOE [NV140FHD‑N43](https://www.panelook.cn/NV140FHM-N43_BOE_14.0_LCM_overview_cn_27125.html) / 14 inch 16:9 IPS / 1920x1080 / 31 cm x 17 cm / 60HZ / eDP |
| Keyboard                | SinoWealth [SH61F83Q](https://www.sinowealth.com/detaile?pro_id=100) / AMR-TOUCH-MOUSE 202110 USB KEYBOARD / USB 1.1 / 6080:8060 |
| Touchpad                | Hynitron [CST128-A](http://www.hynitron.com/product/pen/208) / connected to SH61F83Q |
| USB Hub                 | Genesys Logic [GL852G](https://www.genesyslogic.com.tw/en/product/show.php?num=GL852G&kind=USB2_Hub) / USB 2.0 / 4 MTT / QFN 28 / 05e3:0610 |
| Camera                  | Microdia Sonix Camera / USB 2.0 / UVC 1.00 / 0c45:6368 |
| Type-C Controller        | Hynetek [HUSB311BLA](https://www.hynetek.com/2422.html) / CC detection / QFN-14L |
| USB 3.1 Switch          | Unknown / D3EB 2342 F1                                       |
| Battery Charger         | SouthChip [SC8886SQDER](https://www.southchip.com/product/SC8886S) / 8A / QFN-32 |
| Battery                 | SHT [3585130-2S](https://www.newlaptopaccessory.com/cn/sht-3585130-2s-3585130-7.4v-37wh-batteries-p-11746.html) / 5000mAh / 37Wh / 8.4V (2S) |
| Hall Effect Switch      | Yasemi Magnesensor [MH248](https://www.yasemi.com.cn/productinfo/2155346.html?templateId=1133605) |
| Audio ADC               | 3 * Everest [ES7202](http://www.everest-semi.com/pdf/ES7202%20PB.pdf) / Analog -> PDM / 2 channels |
| Audio Amplifier         | Awinic [AW8737AFCR](https://www.awinic.com/en/evbInfo/AW8737AFCR/289) / Class-K audio power amplifier / FCQFN-16L |
| Speaker                 | 2 * [BER-NM14G-R](https://rozetka.com.ua/ua/438553034/p438553034/) |
| DC-DC                   | Torch [TCS4525](https://www.tctek.cn/product/tcs4525/) / 6A / WCSP-20 |
| N MOSFET                | Vgsemi [VS3652DB](https://vgsemi.com/index/good_detail/?id=30&series_id=1) / Asymmetric Dual N-Channel / 30V / 24A |
| P MOSFET                | Ncepower [NCE30P20Q](https://item.szlcsc.com/datasheet/NCE30P20Q/515299.html) / Single P-Channel / 30V / 20A |
| Size                    | 329.6mm × 220mm × 14.9mm                                     |

| Interface | Description |
| --------- | ----------- |
| Power     | Type-C *1 |
| USB   | USB 2.0 Type A Host * 2 / USB 3.0 Type A Host * 1 / USB 3.1 Type C OTG * 1 |
| HDMI | HDMI 2.0 * 1 |
| Audio | 3.5mm Jack *1 |
| Mic | Analog Mic * 2 |
| Speaker | Speaker * 2                                                  |
| LED | Power LED / Caps Lock LED / Mic Mute LED / Charging LED / Charged LED |



## Images

See [images](./images) for device disassembly details.



## Debug UART

Z96A Type-C:

- **UART** — UART2
- **Baud rate** — 1500000, 8N1
- **Interface** — MX1.25mm 4P flat connector

<img src="./images/Z96A-TYPEC/debug/debug-uart.jpg" alt="debug-uart" style="zoom: 25%;" />



## Maskrom Mode

Z96A Type-C:

Short arrow-marked test points and enter Maskrom mode on power‑up.

<img src="./images/Z96A-TYPEC/debug/maskrom-mode.jpg" style="zoom: 25%;" />



## Mainline Linux

RK3568 is one of the best-supported Rockchip SoCs in upstream Linux. 

Initial SoC support (Cortex-A55, GIC, timers, UART, SD/eMMC, USB3 DWC3, PCIe, GMAC, I2C/SPI/PWM and the RK809 PMIC) landed in Linux 5.16,

followed by the [VOP2](https://github.com/torvalds/linux/commit/604be85547ce4d61b89292d2f9a78c721b778c16) display controller (HDMI / MIPI-DSI) in 5.19. The Mali-G52 GPU is driven by the mainline [Panfrost](https://docs.mesa3d.org/drivers/panfrost.html) driver. 



### Device Tree

#### BSP kernel

Thanks to [bingo1991](https://github.com/bingo1991) and [kemp233](https://github.com/kemp233), device-tree adaptation for both revisions on the Rockchip **BSP** kernel is already complete:

- **Early revision (DC)** — [rk3568-z96a.dts](https://github.com/bingo1991/rk3568_laptop_sunniwell_z96a/blob/main/rk3568-z96a.dts)
- **Later revision (Type‑C)** — [rk3568-z96a-laptop-v2.dts](https://github.com/kemp233/armbian-build-sunniwell-Z96a/blob/main/patch/kernel/rockchip-rk3568-z96a/legacy/dt/rk3568-z96a-laptop-v2.dts)

#### Mainline (not upstream)

- **Later revision (Type‑C)** — [rk3568-sunniwell-z96a-typec.dts](https://github.com/yjun123/linux/blob/add_sunniwell_z96a/arch/arm64/boot/dts/rockchip/rk3568-sunniwell-z96a-typec.dts)



### Distribution

#### Arch Linux ARM

[`linux-aarch64` PKGBUILD](https://github.com/yjun123/PKGBUILDs/tree/feature-sunniwell-z96a-typec/core/linux-aarch64) carrying the Z96A Type‑C patch series, for building a mainline kernel package.

[`z96a-typec-post-install` PKGBUILD](https://github.com/yjun123/PKGBUILDs/tree/feature-sunniwell-z96a-typec/alarm/z96a-typec-post-install), the Z96A Type-C specific tuning configuration.



#### Armbian

[kemp233/armbian-build-sunniwell-Z96a](https://github.com/kemp233/armbian-build-sunniwell-Z96a), Armbian Legacy firmware based on the Rockchip BSP kernel, supporting Z96A Type‑C.

[alkaid-ops/armbian-build-sunniwell-Z96a](https://github.com/alkaid-ops/armbian-build-sunniwell-Z96a), Armbian firmware based on the mainline kernel, supporting Z96A Type‑C.



### Drivers

Mainline support status for the key peripherals.

"Out-of-tree" items are covered by the Rockchip BSP vendor drivers carried in the [armbian/linux-rockchip](https://github.com/armbian/linux-rockchip) fork, not yet in upstream Linux.

| Component          | Chip                 | Mainline driver                                              | Status                                                       |
| ------------------ | -------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| PMIC               | Rockchip RK809-5     | `rk808` (MFD/regulator)                                      | Mainline                                                     |
| WiFi               | Realtek RTL8822CS    | `rtw88` (`CONFIG_RTW88_8822CS`)                              | Mainline (SDIO, since v6.3)                                  |
| Bluetooth          | Realtek RTL8822CS    | `hci_uart` + `btrtl`                                         | Mainline                                                     |
| Keyboard           | SinoWealth SH61F83Q  | `usbhid` (USB HID)                                           | Mainline                                                     |
| Touchpad           | SinoWealth SH61F83Q  | `usbhid` (USB HID)                                           | Mainline                                                     |
| Camera             | Microdia 0c45:6368   | `uvcvideo` (USB UVC)                                         | Mainline                                                     |
| Display            | BOE NV140FHD-N43     | `rockchip-vop` (DRM) + Analogix `analogix_dp` (eDP) + `phy-rockchip-naneng-edp` (PHY) + `panel-edp` | `rockchip-vop`  mainline. developing driver,  pending upstream submission: [rk3568-edp](https://github.com/yjun123/linux/commits/add_sunniwell_z96a/) |
| Audio ADC          | Everest ES7202       | `snd_soc_es7202`                                             | developing codec driver, pending upstream submission: [`es7202.c`](https://github.com/yjun123/linux/blob/add_sunniwell_z96a/sound/soc/codecs/es7202.c) |
| Audio Amplifier    | Awinic AW8737AFCR    | `simple-amplifier` (GPIO `enable-gpios`)                     | Mainline                                                     |
| USB Hub            | Genesys Logic GL852G | `usbcore` (generic hub)                                      | Mainline                                                     |
| Hall Effect Switch | Magnesensor MH248    | — (GPIO interrupt, no dedicated driver)                      | Not needed (GPIO)                                            |
| Type-C Controller   | Hynetek HUSB311      | `tcpci_rt1711h` (tcpm)                                              | Mainline (since v7.1)                                        |
| Battery Charger    | SouthChip SC8886     | `bq257xx` (power_supply)                                                            | Reuses mainline bq257xx; driver in development, pending upstream submission: [sc8886s](https://github.com/yjun123/linux/commits/add_sunniwell_z96a/) |
| DC-DC              | Torch TCS4525        | `fan53555` (regulator)                                       | Mainline (since v5.13)                                       |



### Peripheral status

Actual (tested) status of each peripheral on the mainline kernel:

- ✅ Working
- ❌ Broken
- 🟡 Partial
- ⬜ No test

| Peripheral | Status | Notes |
| --- | --- | --- |
| Wi-Fi (RTL8822CS) | ✅ | Disable LPS Deep to work around Wi-Fi disconnects<br />Add `options rtw88_core disable_lps_deep=y` to /etc/modprobe.d/rtw88.conf |
| Bluetooth (RTL8822CS) | ✅ | |
| Display — HDMI | 🟡 | Sometimes only detected when booted with HDMI plugged in |
| Display — eDP panel | ✅ | Needs non-mainline driver; see [Drivers -> Display](#drivers)                                   |
| Keyboard (SH61F83Q) | ✅ | |
| Touchpad (SH61F83Q, CST128-A) | ✅ | |
| Camera (Microdia 0c45:6368) | ✅ | |
| Audio — speaker (AW8737AFCR) | ✅ | Output via RK809 Headphone |
| Audio — headphone playback (3.5mm jack) | 🟡 | Output via RK809 Headphone, mono (right channel) output |
| Audio — headphone mic (3.5mm jack) | ✅ | Input via RK809 Microphone |
| Audio — microphone (ES7202 ADC) | ✅ | Needs non-mainline driver; see [Drivers -> Audio ADC](#drivers)                                 |
| Audio — HDMI | 🟡 | Sometimes only detected when booted with HDMI plugged in |
| Battery / charger (SC8886) | ✅ | Needs non-mainline patch; see [Drivers -> Battery Charger](#drivers) |
| Charging indication (LED) | ✅ | Power connected, charging, fully charged |
| Battery monitor (temperature and battery level display) | ✅ | Needs non-mainline patch; see [Drivers -> Battery Charger](#drivers) |
| USB 2.0 Type-A host (×2) | ✅ | |
| USB 3.0 Type-A host | ✅ | |
| USB 3.1 Type-C OTG port (HUSB311) | ✅ | |
| Lid switch (MH248) | ✅ | |



### Battery & Charging

Battery protection board disassembly photo (from @不如茶相伴 in the QQ group):

<img src="./images/Z96A-TYPEC/debug/battery-protection-board.jpg" alt="battery-protection-board" style="zoom:50%;" />



Battery connector definition:

| Pin | Color | Function | Notes |
| --- | --- | --- | --- |
| 1 | Red | Power + | |
| 2 | Red | Power + | |
| 3 | Red | Power + | |
| 4 | Yellow | ID (battery identification) | SARADC ch5, 98.3 Ω to GND |
| 5 | White | T (NTC, temperature) | SARADC ch4, 9.3 Ω to GND |
| 6 | Blue | IN (presence detection) | unused?, 9.2 Ω to GND |
| 7 | NC | Not connected | |
| 8 | Black | Power − | |
| 9 | Black | Power − | |
| 10 | Black | Power − | |



### Keyboard

Function key mapping

| Function key        | Original keycode      | Scancode    | Correct keycode                  | Notes                                                                                                     |
| ------------------- | --------------------- | ----------- | -------------------------------- | --------------------------------------------------------------------------------------------------------- |
| Lock screen/F1      | KEY_SCREENLOCK        |             | KEY_SCREENLOCK                   | ✅                                                                                                         |
| Mic mute/F2         | KEY_REFRESH           | 700FA       | KEY_MICMUTE                      | ✅, keycode corrected                                                                                      |
| Speaker mute/F3     | KEY_MUTE              |             | KEY_MUTE                         | ✅                                                                                                         |
| Volume down/F4      | KEY_VOLUMEDOWN        |             | KEY_VOLUMEDOWN                   | ✅                                                                                                         |
| Volume up/F5        | KEY_VOLUMEUP          |             | KEY_VOLUMEUP                     | ✅                                                                                                         |
| Brightness down/F6  | KEY_BRIGHTNESSDOWN    |             | KEY_BRIGHTNESSDOWN               | ✅                                                                                                         |
| Brightness up/F7    | KEY_BRIGHTNESSUP      |             | KEY_BRIGHTNESSUP                 | ✅                                                                                                         |
| Wireless switch/F8  | KEY_CALC              | 700FB       | KEY_RFKILL                       | 🟡, keycode corrected, but the wireless switch function is unavailable; may need software/hardware support |
| Battery level/F9    | KEY_UNKNOWN           | 700FC       | KEY_BATTERY                      | 🟡, keycode corrected, but the battery level display is unavailable; may need software/hardware support    |
| Touchpad toggle/F10 | KEY_FIND/KEY_SCROLLUP | 700F4/700F5 | KEY_TOUCHPAD_OFF/KEY_TOUCHPAD_ON | ✅, keycode corrected, original keycode is wrong but the function works; may be implemented in hardware    |
| Screen cast/F11     | KEY_STOPCD            | 700E9       | KEY_SWITCHVIDEOMODE              | ✅, keycode corrected                                                                                      |

Note: the function key keycodes have been corrected after configuring [99-sunniwell-z96a-typec-keyboard.hwdb](https://github.com/yjun123/PKGBUILDs/blob/feature-sunniwell-z96a-typec/alarm/z96a-typec-post-install/99-sunniwell-z96a-typec-keyboard.hwdb).



### Firmware



## Questions

The following details are not yet fully understood:

1. How is the PD protocol implemented for the Type-C charging port? Is there a separate PD trigger/decoy chip?

   Disassembly reveals a QFN20 chip on the back of the motherboard near the charging port, suspected to be a fast-charge protocol chip. Tracing the Type-C pins to the chip, D+/D- are routed to it, VBUS is broken out (whether it reaches the chip is uncertain), and TX- is also broken out, but the CC pins appear not to be connected. With an adapter plugged in, VBUS measures 15 V — pointing to a D+/D--negotiated fast-charge protocol (rather than PD-over-CC); the exact chip and protocol are still TBD.
   
2. How is the power-connection indicator LED state toggled under the Android firmware?

   Currently the behavior is: the LED turns on when the adapter is connected and off when it is removed.

3. Does the Type-C charging port support reverse charging (powering external devices)?

   No output support; the later TYC4A product supports powering external devices from the charging port.

### Not yet implemented

| Feature                      | Description                                                                                                                                                                                            |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Mic mute LED                 | There are three LEDs at the top-left of the keyboard; the rightmost mic-status LED is not driven yet, and its pin has not been found                                                                   |
| Keyboard wireless switch key | See [Wireless switch/F8](#keyboard); this function needs user-space software support                                                                                                                   |
| Battery level key            | See [Battery level/F9](#keyboard); this function needs user-space software support. Under the KDE desktop this key switches the power profile; whether the RK3568 has a supported power profile is TBD |
| Three ES7202                 | The hardware has three ES7202 chips; one of them (connected to the microphone) has been successfully driven, and the roles of the other two are not yet clear                                                                              |
| Chromium hardware decoding   | VDEC hardware decoding support already exists; it still needs software support                                                                                                                         |



## Reference

[华为云商店 - Z96A云笔电](https://marketplace.huaweicloud.com/contents/bfc3050c-2596-4c18-91ea-d2482201a308)

[Github - bingo1991/rk3568_laptop_sunniwell_z96a](https://github.com/bingo1991/rk3568_laptop_sunniwell_z96a)

[Github - baidxi/rk35xx_kernel_5_10](https://github.com/baidxi/rk35xx_kernel_5_10/blob/master/arch/arm64/boot/dts/rockchip/rk3568-z96a.dts)

[Github - kemp233/armbian-build-sunniwell-Z96a](https://github.com/kemp233/armbian-build-sunniwell-Z96a)

[Github - dontshootitsme/armbian-build-sunniwell-Z96a](https://github.com/dontshootitsme/armbian-build-sunniwell-Z96a)

[Github - momokind/armbian-build](https://github.com/momokind/armbian-build)

[Github - armbian/build - Evaneee@Add new board in future- #6274](https://github.com/armbian/build/pull/6274)

[Github - ophub/amlogic-s9xxx-armbian - bingo1991@申请增加朝歌Z96A这款电信天翼云电脑笔记本终端(RK3568,4+32)的适配 #1967](https://github.com/ophub/amlogic-s9xxx-armbian/issues/1967)

[Github - armbian/linux-rockchip - bingo1991@Add support for Sunniwell Z96A RK3568 Laptop- #213](https://github.com/armbian/linux-rockchip/pull/213)

[Github - gjrtimmer/ubuntu-rockchip - gjrtimmer@[BC-14] Add Sunniwell Z96A laptop (RK3568) board support #58](https://github.com/gjrtimmer/ubuntu-rockchip/issues/58)

[Bilibili - 一路人甲一 - 朝歌z96a移植GarlicOS系统体验](https://www.bilibili.com/video/BV1e38TeCEKp)

[CSDN - 云笔记本，刷linux，天翼云笔记本rk3568](https://blog.csdn.net/xueyizhi/article/details/163784149)
