# 泰奇猫问题

## 主线内核

更新 5.17.7 以后，以太网接口无法识别到， dwmac-sunxi/ac200报错

```
$ dmesg | grep -e dwmac -e ac200
[    3.479773] ac200 0-0010: Can't obtain the clock!
[    3.484589] ac200: probe of 0-0010 failed with error -2
[   13.729843] dwmac-sun8i 5020000.ethernet: IRQ eth_wake_irq not found
[   13.736423] dwmac-sun8i 5020000.ethernet: IRQ eth_lpi not found
[   13.746699] dwmac-sun8i 5020000.ethernet: supply phy not found, using dummy regulator
[   13.755011] dwmac-sun8i 5020000.ethernet: supply phy-io not found, using dummy regulator
[   13.765526] dwmac-sun8i 5020000.ethernet: PTP uses main clock
[   13.782409] dwmac-sun8i 5020000.ethernet: Current syscon value is not the default 58000 (expect 50000)
[   13.783321] dwmac-sun8i 5020000.ethernet: No HW DMA feature register supported
[   13.783332] dwmac-sun8i 5020000.ethernet: RX Checksum Offload Engine supported
[   13.783334] dwmac-sun8i 5020000.ethernet: COE Type 2
[   13.783337] dwmac-sun8i 5020000.ethernet: TX Checksum insertion supported
[   13.783341] dwmac-sun8i 5020000.ethernet: Normal descriptors
[   13.783344] dwmac-sun8i 5020000.ethernet: Chain mode enabled
[   13.905576] dwmac-sun8i 5020000.ethernet: EMAC reset timeout
[   13.919028] dwmac-sun8i 5020000.ethernet eth0: stmmac_dvr_remove: removing driver
[   14.157703] dwmac-sun8i: probe of 5020000.ethernet failed with error -110
```

根据`ac200 0-0010: Can't obtain the clock!` 定位到是 [0009-allwinner-h6-support-ac200-audio-codec.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-5.17/patches.armbian/0009-allwinner-h6-support-ac200-audio-codec.patch) 这个补丁的问题

```
-	/* do a reset to put chip in a known state */
+	ac200->clk = devm_clk_get(dev, NULL);
+	if (IS_ERR(ac200->clk)) {
+	      dev_err(dev, "Can't obtain the clock!\n");
+	      return PTR_ERR(ac200->clk);
+	}
 
+	ret = clk_prepare_enable(ac200->clk);
+	if (ret)
+	      return ret;
+
+	/* do a reset to put chip in a known state */
...
struct ac200_dev {
+	struct clk                    *clk;
 	struct regmap			*regmap;
 	struct regmap_irq_chip_data	*regmap_irqc;
 };
```

多加了一个 clk 变量，所以在设备树上也有添加响应的 clk属性。

```dtd
ac200: mfd@10 {
        ...
        clocks = <&ac200_pwm_clk>;
        ...
}
```

重新编译设备树, ok 正常了

```
[    3.484054] ac200-ephy ac200-ephy: DMA mask not set
[   12.064795] dwmac-sun8i 5020000.ethernet: IRQ eth_wake_irq not found
[   12.072860] dwmac-sun8i 5020000.ethernet: IRQ eth_lpi not found
[   12.086464] dwmac-sun8i 5020000.ethernet: supply phy not found, using dummy regulator
[   12.108098] dwmac-sun8i 5020000.ethernet: supply phy-io not found, using dummy regulator
[   12.122124] dwmac-sun8i 5020000.ethernet: PTP uses main clock
[   12.128426] dwmac-sun8i 5020000.ethernet: Current syscon value is not the default 58000 (expect 50000)
[   12.147501] dwmac-sun8i 5020000.ethernet: No HW DMA feature register supported
[   12.166749] dwmac-sun8i 5020000.ethernet: RX Checksum Offload Engine supported
[   12.166762] dwmac-sun8i 5020000.ethernet: COE Type 2
[   12.166768] dwmac-sun8i 5020000.ethernet: TX Checksum insertion supported
[   12.166772] dwmac-sun8i 5020000.ethernet: Normal descriptors
[   12.177347] dwmac-sun8i 5020000.ethernet: Chain mode enabled
[   13.789228] dwmac-sun8i 5020000.ethernet eth0: PHY [stmmac-0:01] driver [AC200 EPHY] (irq=POLL)
[   13.798554] dwmac-sun8i 5020000.ethernet eth0: Register MEM_TYPE_PAGE_POOL RxQ-0
[   13.806660] dwmac-sun8i 5020000.ethernet eth0: No Safety Features support found
[   13.814041] dwmac-sun8i 5020000.ethernet eth0: No MAC Management Counters available
[   13.821748] dwmac-sun8i 5020000.ethernet eth0: PTP not supported by HW
[   13.828817] dwmac-sun8i 5020000.ethernet eth0: configuring for phy/rmii link mode
```



无法自动重启

执行`reboot` 会导致内核停在 `reboot: Restarting system`，系统并不会重启。

```
[   40.641260] shutdown[1]: All filesystems unmounted.
[   40.648538] shutdown[1]: Deactivating swaps.
[   40.655328] shutdown[1]: All swaps deactivated.
[   40.667869] shutdown[1]: Detaching loop devices.
[   40.681238] shutdown[1]: All loop devices detached.
[   40.691378] shutdown[1]: Stopping MD devices.
[   40.701221] shutdown[1]: All MD devices stopped.
[   40.710312] shutdown[1]: Detaching DM devices.
[   40.719547] shutdown[1]: All DM devices detached.
[   40.727600] shutdown[1]: All filesystems, swaps, loop devices, MD devices and DM devices detached.
[   40.744130] shutdown[1]: Syncing filesystems and block devices.
[   40.758150] shutdown[1]: Rebooting.
[   40.764166] kvm: exiting hardware virtualization
[   40.816057] reboot: Restarting system
```

比较怀疑是 PMIC(AXP-805) 的问题，查找PMIC相关的commi,找一个[arm64: dts: allwinner: h6: Use RSB for AXP805 PMIC connection](https://github.com/torvalds/linux/commit/531fdbeedeb89bd32018a35c6e137765c9cc9e97), 用[RSB](https://linux-sunxi.org/Reduced_Serial_Bus)代替I2C与PMIC进行通信，我revert这个commit, reboot就可以正常工作了！

为什么I2C就能正常重启，而RSB就不行，我在这个邮件列表[[PATCH v2 0/4] Allwinner H6 RSB support](https://groups.google.com/g/linux-sunxi/c/-4WKNWBiHyY)找到了可能的原因。

>Crust can handle either way via a config option, which currently
>defaults to I2C for H6. It must use the same selection as Linux, not
>only because of the PMIC mode, but also because of the pinctrl.
>
>TF-A is already converted to use RSB[1], and it does switch the PMIC
>back to I2C before handing off to U-Boot[2]. So new TF-A + old Linux is
>fine. However, Linux currently does not switch the PMIC back. So the
>most likely problem from this patch is that, with new Linux + old TF-A,
>TF-A will be unable to power down the board or access regulators after
>an SoC reset.
>
>I expect there will be a TF-A release between now and when 5.12 hits
>stable, but people tend not upgrade their U-Boot/TF-A very often.
>
>We could solve this by having the Linux RSB driver switch all child
>devices back to I2C in .shutdown, or by dropping this patch and only
>using RSB for new boards (which would also address Andre's concern).
>
>Cheers,
>Samuel

2023年，在更新TF-A 后，可以尝试将XP806 的I2C 改为 RSB.

### 高负载WiFi掉线问题

发现在内核版本5.x和6.x中，当系统出现高负载的时候，比如编译内核，WiFi会掉线 ，百分百浮现，查看内核日志发现相关报错

内核日志：

```bash
May 23 09:09:35 tqc-a01 kernel: brcmfmac: brcmf_fw_alloc_request: using brcm/brcmfmac43430-sdio for chip BCM43430/1
May 23 09:09:35 tqc-a01 kernel: usbcore: registered new interface driver brcmfmac
May 23 09:09:35 tqc-a01 kernel: brcmfmac: brcmf_fw_alloc_request: using brcm/brcmfmac43430-sdio for chip BCM43430/1
May 23 09:09:35 tqc-a01 kernel: brcmfmac: brcmf_c_preinit_dcmds: Firmware: BCM43430/1 wl0: Mar 30 2021 01:12:21 version 7.45.98.118 (7d96287 CY) FWID 01-32059766
May 23 09:09:35 tqc-a01 kernel: Bluetooth: hci0: BCM43430A1 'brcm/BCM43430A1.hcd' Patch
Aug 15 21:47:04 tqc-a01 kernel: ieee80211 phy0: brcmf_proto_bcdc_query_dcmd: brcmf_proto_bcdc_msg failed w/status -110
Aug 15 21:47:04 tqc-a01 kernel: ieee80211 phy0: brcmf_cfg80211_dump_station: BRCMF_C_GET_ASSOCLIST failed, err=-110
Aug 15 21:47:10 tqc-a01 kernel: ieee80211 phy0: brcmf_proto_bcdc_query_dcmd: brcmf_proto_bcdc_msg failed w/status -110
Aug 15 21:47:10 tqc-a01 kernel: ieee80211 phy0: brcmf_cfg80211_dump_station: BRCMF_C_GET_ASSOCLIST failed, err=-110
Aug 15 21:47:47 tqc-a01 kernel: ieee80211 phy0: brcmf_proto_bcdc_query_dcmd: brcmf_proto_bcdc_msg failed w/status -110
Aug 15 21:47:47 tqc-a01 kernel: ieee80211 phy0: brcmf_cfg80211_dump_station: BRCMF_C_GET_ASSOCLIST failed, err=-110
Aug 15 21:57:22 tqc-a01 kernel: ieee80211 phy0: brcmf_proto_bcdc_query_dcmd: brcmf_proto_bcdc_msg failed w/status -110
Aug 15 21:57:22 tqc-a01 kernel: ieee80211 phy0: brcmf_cfg80211_dump_station: BRCMF_C_GET_ASSOCLIST failed, err=-110
Aug 15 21:57:28 tqc-a01 kernel: ieee80211 phy0: brcmf_proto_bcdc_query_dcmd: brcmf_proto_bcdc_msg failed w/status -110
Aug 15 21:57:28 tqc-a01 kernel: ieee80211 phy0: brcmf_cfg80211_dump_station: BRCMF_C_GET_ASSOCLIST failed, err=-110
Aug 15 21:57:34 tqc-a01 kernel: ieee80211 phy0: brcmf_proto_bcdc_query_dcmd: brcmf_proto_bcdc_msg failed w/status -110
```



### HDMI在wayland下面只能输出 1024x768

测试在5.*内核下正常的。

定位到为HDMI 无法通过DDC 获取屏幕的EDID

```bash
╭─alarm@tqc-a01 ~  
╰─➤  hexdump -C  /sys/class/drm/card1-HDMI-A-1/edid 
╭─alarm@tqc-a01 ~  
╰─➤  hexdump -C  /sys/class/drm/card1-HDMI-A-1/modes 
00000000  31 30 32 34 78 37 36 38  0a 38 30 30 78 36 30 30  |1024x768.800x600|
00000010  0a 38 30 30 78 36 30 30  0a 38 34 38 78 34 38 30  |.800x600.848x480|
00000020  0a 36 34 30 78 34 38 30  0a                       |.640x480.|
00000029
╭─alarm@tqc-a01 ~  
╰─➤  hexdump -C  /sys/class/drm/card1-HDMI-A-1/status 
00000000  63 6f 6e 6e 65 63 74 65  64 0a                    |connected.|
0000000a
```

通过增加内核参数：`video=HDMI-A-1:1920x1080@60` 强制设置，会输出异常，导致无法输出视频。



查看内核代码的提交日志，在 `drivers/gpu/drm/sun4i`的历史提交中，发现[**drm/sun4i: dw-hdmi: Fix ddc-en GPIO consumer conflict**](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=920169041baa0a7497ed702aa97d6a2d628) 提到， **display-connector** 模块实现了 `DDC-EN`的初始化，会与`sun8i-drm-hdmi`里的相关ddc-en初始化冲突，所以去掉了`sun8i-drm-hdmi` 内冲突的代码。

但是HDMI获取屏幕的EDID则需要此段初始化的相关逻辑，解决的方法就是添加 `display-connector` 内核模块。

```
CONFIG_DRM_DISPLAY_CONNECTOR=m
```



### 视频硬解问题

- Hantro G2
- Sunxi Cedrus

[PINE64 wiki - Mainline Hardware Decoding](https://wiki.pine64.org/wiki/Mainline_Hardware_Decoding)

### HDMI 音频输出

参考[[PATCH 7/7] arm64: dts: sun50i-h6: Add HDMI audio to H6 DTSI](https://lwn.net/ml/linux-kernel/20200418143923.19608-8-peron.clem@gmail.com/), 添加一个 `sound_hdmi` 节点，但是在使用过程中内核会出现报错,在执行`pactl list sinks`的时候出现：

```
Aug 27 23:39:57 tqc-a01 kernel: hdmi-audio-codec hdmi-audio-codec.6.auto: Only one simultaneous stream supported!
Aug 27 23:39:57 tqc-a01 kernel: hdmi-audio-codec hdmi-audio-codec.6.auto: ASoC: error at snd_soc_dai_startup on i2s-hifi: -22
Aug 27 23:39:57 tqc-a01 kernel:  5091000.i2s-i2s-hifi: ASoC: error at __soc_pcm_open on 5091000.i2s-i2s-hifi: -22
Aug 27 23:39:57 tqc-a01 kernel: hdmi-audio-codec hdmi-audio-codec.6.auto: Not able to map channels to speakers (-22)
```

发现新的补丁[ASOC-sun9i-hdmi-audio-Initial-implementation.patch](https://github.com/armbian/build/blob/master/patch/kernel/archive/sunxi-6.1/patches.megous/ASOC-sun9i-hdmi-audio-Initial-implementation.patch), 回退之前的补丁，和`arm64-dts-allwinner-h6-Add-hdmi-sound-card.patch`补丁一起配合使用。



### 主线U-Boot 支持

完成,见AUR: [boot-tqc-a01](https://aur.archlinux.org/packages/uboot-tqc-a01)



### U-Boot ATF以及 CRUST的启动启动顺序

ATF: BL31(PSCI)

CRUST: SCP (System Control Processor)

可能的启动逻辑： U-Boot SPL -> ATF -> CRUST -> U-Boot

### 视频输出相关的内核驱动

```
“allwinner,sun50i-h6-display-engine“

“allwinner,sun50i-h6-de3-clk”

“allwinner,sun50i-h6-de3-mixer-0“

"allwinner,sun50i-h6-dw-hdmi"

“allwinner,sun50i-h6-hdmi-phy"

"allwinner,sun50i-h6-tcon-top"

“allwinner,sun50i-h6-tcon-tv”
```



### 6.4.11 的内核waring

1. pinctrl regulator

```
sun50i-h6-r-pinctrl 7022000.pinctrl: supply vcc-pl not found, using dummy regulator
sun50i-h6-pinctrl 300b000.pinctrl: supply vcc-pb not found, using dummy regulator
sun50i-h6-pinctrl 300b000.pinctrl: supply vcc-ph not found, using dummy regulator
sun50i-h6-pinctrl 300b000.pinctrl: supply vcc-pf not found, using dummy regulator
```

`drivers/pinctrl/sunxi/pinctrl-sunxi.c:857 reg = regulator_get(pctl->dev, supply);`

`drivers/regulator/core.c:2207 dev_warn(*dev*, "supply %s not found, using dummy regulator\n", *id*);`

`arch/arm64/boot/dts/allwinner/sun50i-h6-orangepi-3.dts:173 vcc-pc-supply = <&reg_bldo2>; `

对于不需要供电的PIO BANK 需要如何指定呢？

2. bluetooth hci_art_bcm

   ```
   hci_uart_bcm serial0-0: supply vbat not found, using dummy regulator
   hci_uart_bcm serial0-0: supply vddio not found, using dummy regulator
   ```

   `Documentation/devicetree/bindings/net/broadcom-bluetooth.yaml: vbat-supply:  vddio-supply:`

   `drivers/bluetooth/hci_bcm.c:1138 err = devm_regulator_bulk_get(dev->dev, BCM_NUM_SUPPLIES,dev->supplies);`

   trip: `host-wakeup-gpios` 已经弃用，使用 `host-wakeup` 中断名

   ```dtd
   interrupt-parent = <&r_pio>;
   interrupts = <1 1 IRQ_TYPE_LEVEL_LOW>; // 这里的中断触发选哪个？
   interrupt-names = "host-wakeup";
   ```

3. CPU cacheinfo

   ```
   cacheinfo: Unable to detect cache hierarchy for CPU 0q
   ```

4. ac200-ephy 

   ```
   ac200-ephy ac200-ephy: DMA mask not set
   ```

   `drivers/of/device.c:176         dev_warn(dev, "DMA mask not set\n");`

   ```
   	/*
   	 * If @dev is expected to be DMA-capable then the bus code that created
   	 * it should have initialised its dma_mask pointer by this point. For
   	 * now, we'll continue the legacy behaviour of coercing it to the
   	 * coherent mask if not, but we'll no longer do so quietly.
   	 */
   ```

5. ac200 acx00-codec

   ```
   acx00-codec: Failed to locate of_node [id: -1]
   ```

   `drivers/mfd/sunxi-ac200.c:136 ret = devm_mfd_add_devices(dev, PLATFORM_DEVID_NONE, ac200_cells,ARRAY_SIZE(ac200_cells), NULL, 0, NULL);`

   `sound/soc/codecs/acx00.c:1238 *struct* device_node *np = of_find_compatible_node(NULL, NULL, "allwinner,ac200_codec");`

6. sun8i-dw-hdmi

   ```
   sun8i-dw-hdmi 6000000.hdmi: supply hvcc not found, using dummy regulator
   ```

   `Documentation/devicetree/bindings/display/allwinner,sun8i-a83t-dw-hdmi.yaml: hvcc-supply`

9. usb_phy_generic

   ```
   usb_phy_generic usb_phy_generic.2.auto: dummy supplies not allowed for exclusive requests
   ```

   

10. sun8i-mixer

    ```
    sun8i-mixer 1100000.mixer: deferred probe timeout, ignoring dependency
    ```

    

11. sun4i-drm

    ```
    sun4i-drm display-engine: deferred probe timeout, ignoring dependency
    ```

    
