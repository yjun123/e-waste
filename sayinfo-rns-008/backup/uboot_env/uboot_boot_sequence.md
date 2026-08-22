# U-Boot 启动流程展开（变量替换 + 执行顺序）

来源：`uboot_env.txt`（Rockchip PX30/RK3326，evb_px30）
本文件将环境变量中的 `${var}` 全部替换为实际值，并按启动执行顺序还原为命令，逐行注释。

---

## 1. 关键变量初始值

| 变量 | 值 | 说明 |
|---|---|---|
| `devtype` | `mmc` | 默认存储类型 |
| `devnum` | `0` | 默认设备号 |
| `scriptaddr` | `0x00500000` | 脚本/文件加载地址 |
| `kernel_addr_r` | `0x00280000` | 内核加载地址 |
| `kernel_addr_c` | `0x03e80000` | 内核压缩加载地址 |
| `fdt_addr_r` | `0x08300000` | DTB 加载地址 |
| `ramdisk_addr_r` | `0x0a200000` | ramdisk 加载地址 |
| `pxefile_addr_r` | `0x00600000` | PXE 文件地址 |
| `boot_targets` | `mmc1 mmc0 rknand0 usb0 pxe dhcp` | distro 启动目标顺序 |
| `boot_prefixes` | `/ /boot/` | 启动脚本搜索路径前缀 |
| `boot_scripts` | `boot.scr.uimg boot.scr` | U-Boot 脚本名列表 |
| `boot_script_dhcp` | `boot.scr.uimg` | DHCP 启动脚本名 |
| `bootdelay` | `0` | 无等待，直接启动 |
| `baudrate` | `1500000` | 串口波特率 |

> 注：`partitions`、`rkimg_bootdev` 两变量在 env dump 中被换行截断，以下按其真实语义拼合还原。

---

## 2. bootcmd —— 启动主入口

环境变量：`bootcmd=boot_android ${devtype} ${devnum};bootrkp;run distro_bootcmd;`

```bash
# 第一段：Android 分区启动（U-Boot 内置 Rockchip 命令，不在 env 中定义）
boot_android mmc 0;
# devtype=mmc, devnum=0 → 尝试从 eMMC 的 Android 分区(boot等)启动

# 第二段：Rockchip 专有启动（内置命令，内部会调用 rkimg_bootdev 探测启动设备）
bootrkp;

# 第三段：标准 distro 启动流程（见第 3 节）
run distro_bootcmd;
```

### bootrkp 内部逻辑（rkimg_bootdev 展开）

`rkimg_bootdev` 探测启动设备的完整逻辑（已还原截断部分）：

```bash
# 优先探测 SD 卡：mmc1 存在且含 RK 镜像标记则选用 SD 卡
if mmc dev 1 && rkimgtest mmc 1; then
    setenv devtype mmc;
    setenv devnum 1;
    echo Boot from SDcard;
# 其次 eMMC
elif mmc dev 0; then
    setenv devtype mmc;
    setenv devnum 0;
# 再次 NAND
elif rknand dev 0; then
    setenv devtype rknand;
    setenv devnum 0;
# SPI NAND
elif rksfc dev 0; then
    setenv devtype spinand;
    setenv devnum 0;
# SPI NOR
elif rksfc dev 1; then
    setenv devtype spinor;
    setenv devnum 1;
fi;
```

---

## 3. distro_bootcmd —— 遍历启动目标

环境变量：`distro_bootcmd=for target in ${boot_targets}; do run bootcmd_${target}; done`

```bash
# 按 boot_targets 顺序逐个尝试：mmc1(SD) → mmc0(eMMC) → rknand0 → usb0 → pxe → dhcp
for target in mmc1 mmc0 rknand0 usb0 pxe dhcp; do
    run bootcmd_${target};
done
```

---

## 4. 目标一：bootcmd_mmc1（SD 卡）

环境变量：`bootcmd_mmc1=setenv devnum 1; run mmc_boot`

```bash
# 切换设备号为 1（SD 卡）
setenv devnum 1;

# mmc_boot 展开（devnum=1）：
#   mmc_boot=if mmc dev ${devnum}; then setenv devtype mmc; run scan_dev_for_boot_part; fi
if mmc dev 1; then
    setenv devtype mmc;
    run scan_dev_for_boot_part;
fi
```

### 4.1 scan_dev_for_boot_part（devtype=mmc, devnum=1）

```bash
# 列出可启动分区（带 bootable 标志）
part list mmc 1 -bootable devplist;
# 若没有 bootable 分区则回退用分区 1
env exists devplist || setenv devplist 1;

for distro_bootpart in ${devplist}; do
    # 判断分区是否含文件系统
    if fstype mmc 1:${distro_bootpart} bootfstype; then
        run scan_dev_for_boot;
    fi
done
```

### 4.2 scan_dev_for_boot（devtype=mmc, devnum=1, distro_bootpart=分区号）

```bash
echo Scanning mmc 1:${distro_bootpart}...;

# 遍历前缀：/ 与 /boot/
for prefix in / /boot/; do
    run scan_dev_for_extlinux;
    run scan_dev_for_scripts;
done
```

### 4.3 前缀 `/` 下的 extlinux 检测

```bash
# scan_dev_for_extlinux：查找 extlinux/extlinux.conf
if test -e mmc 1:${distro_bootpart} /extlinux/extlinux.conf; then
    echo Found /extlinux/extlinux.conf;
    # boot_extlinux 展开（scriptaddr=0x00500000）
    sysboot mmc 1:${distro_bootpart} any 0x00500000 /extlinux/extlinux.conf;
    echo SCRIPT FAILED: continuing...;
fi
```

### 4.4 前缀 `/` 下的脚本检测

```bash
# scan_dev_for_scripts：依次查找 boot.scr.uimg、boot.scr
for script in boot.scr.uimg boot.scr; do
    if test -e mmc 1:${distro_bootpart} /${script}; then
        echo Found U-Boot script /${script};
        # boot_a_script 展开：加载脚本到 scriptaddr 并执行
        load mmc 1:${distro_bootpart} 0x00500000 /${script};
        source 0x00500000;
        echo SCRIPT FAILED: continuing...;
    fi
done
```

### 4.5 前缀 `/boot/` 下的 extlinux 检测

```bash
# scan_dev_for_extlinux：查找 boot/extlinux/extlinux.conf
if test -e mmc 1:${distro_bootpart} /boot/extlinux/extlinux.conf; then
    echo Found /boot/extlinux/extlinux.conf;
    sysboot mmc 1:${distro_bootpart} any 0x00500000 /boot/extlinux/extlinux.conf;
    echo SCRIPT FAILED: continuing...;
fi
```

### 4.6 前缀 `/boot/` 下的脚本检测

```bash
# scan_dev_for_scripts：依次查找 boot/boot.scr.uimg、boot/boot.scr
for script in boot.scr.uimg boot.scr; do
    if test -e mmc 1:${distro_bootpart} /boot/${script}; then
        echo Found U-Boot script /boot/${script};
        load mmc 1:${distro_bootpart} 0x00500000 /boot/${script};
        source 0x00500000;
        echo SCRIPT FAILED: continuing...;
    fi
done
```

---

## 5. 目标二：bootcmd_mmc0（eMMC）

环境变量：`bootcmd_mmc0=setenv devnum 0; run mmc_boot`

```bash
# 切换设备号为 0（eMMC）
setenv devnum 0;

if mmc dev 0; then
    setenv devtype mmc;
    run scan_dev_for_boot_part;
fi
```

### 5.1 scan_dev_for_boot_part（devtype=mmc, devnum=0）

```bash
part list mmc 0 -bootable devplist;
env exists devplist || setenv devplist 1;

for distro_bootpart in ${devplist}; do
    if fstype mmc 0:${distro_bootpart} bootfstype; then
        run scan_dev_for_boot;
    fi
done
```

### 5.2 scan_dev_for_boot（devtype=mmc, devnum=0）

```bash
echo Scanning mmc 0:${distro_bootpart}...;

for prefix in / /boot/; do
    run scan_dev_for_extlinux;
    run scan_dev_for_scripts;
done
```

### 5.3 前缀 `/` 下的 extlinux 检测

```bash
if test -e mmc 0:${distro_bootpart} /extlinux/extlinux.conf; then
    echo Found /extlinux/extlinux.conf;
    sysboot mmc 0:${distro_bootpart} any 0x00500000 /extlinux/extlinux.conf;
    echo SCRIPT FAILED: continuing...;
fi
```

### 5.4 前缀 `/` 下的脚本检测

```bash
for script in boot.scr.uimg boot.scr; do
    if test -e mmc 0:${distro_bootpart} /${script}; then
        echo Found U-Boot script /${script};
        load mmc 0:${distro_bootpart} 0x00500000 /${script};
        source 0x00500000;
        echo SCRIPT FAILED: continuing...;
    fi
done
```

### 5.5 前缀 `/boot/` 下的 extlinux 检测

```bash
if test -e mmc 0:${distro_bootpart} /boot/extlinux/extlinux.conf; then
    echo Found /boot/extlinux/extlinux.conf;
    sysboot mmc 0:${distro_bootpart} any 0x00500000 /boot/extlinux/extlinux.conf;
    echo SCRIPT FAILED: continuing...;
fi
```

### 5.6 前缀 `/boot/` 下的脚本检测

```bash
for script in boot.scr.uimg boot.scr; do
    if test -e mmc 0:${distro_bootpart} /boot/${script}; then
        echo Found U-Boot script /boot/${script};
        load mmc 0:${distro_bootpart} 0x00500000 /boot/${script};
        source 0x00500000;
        echo SCRIPT FAILED: continuing...;
    fi
done
```

---

## 6. 目标三：bootcmd_rknand0（NAND）

环境变量：`bootcmd_rknand0=setenv devnum 0; run rknand_boot`

```bash
setenv devnum 0;

# rknand_boot 为 U-Boot 内置 Rockchip 命令，env 文件中未定义，
# 功能与 mmc_boot 类似：初始化 NAND 并扫描可启动分区
run rknand_boot;
```

---

## 7. 目标四：bootcmd_usb0（USB）

环境变量：`bootcmd_usb0=setenv devnum 0; run usb_boot`

```bash
setenv devnum 0;

# usb_boot 展开：
#   usb_boot=usb start; if usb dev ${devnum}; then setenv devtype usb; run scan_dev_for_boot_part; fi
usb start;
if usb dev 0; then
    setenv devtype usb;
    run scan_dev_for_boot_part;
fi
```

### 7.1 scan_dev_for_boot_part（devtype=usb, devnum=0）

```bash
part list usb 0 -bootable devplist;
env exists devplist || setenv devplist 1;

for distro_bootpart in ${devplist}; do
    if fstype usb 0:${distro_bootpart} bootfstype; then
        run scan_dev_for_boot;
    fi
done
```

### 7.2 scan_dev_for_boot（devtype=usb, devnum=0）

```bash
echo Scanning usb 0:${distro_bootpart}...;

for prefix in / /boot/; do
    run scan_dev_for_extlinux;
    run scan_dev_for_scripts;
done
```

### 7.3 前缀 `/` 下的 extlinux 检测

```bash
if test -e usb 0:${distro_bootpart} /extlinux/extlinux.conf; then
    echo Found /extlinux/extlinux.conf;
    sysboot usb 0:${distro_bootpart} any 0x00500000 /extlinux/extlinux.conf;
    echo SCRIPT FAILED: continuing...;
fi
```

### 7.4 前缀 `/` 下的脚本检测

```bash
for script in boot.scr.uimg boot.scr; do
    if test -e usb 0:${distro_bootpart} /${script}; then
        echo Found U-Boot script /${script};
        load usb 0:${distro_bootpart} 0x00500000 /${script};
        source 0x00500000;
        echo SCRIPT FAILED: continuing...;
    fi
done
```

### 7.5 前缀 `/boot/` 下的 extlinux 检测

```bash
if test -e usb 0:${distro_bootpart} /boot/extlinux/extlinux.conf; then
    echo Found /boot/extlinux/extlinux.conf;
    sysboot usb 0:${distro_bootpart} any 0x00500000 /boot/extlinux/extlinux.conf;
    echo SCRIPT FAILED: continuing...;
fi
```

### 7.6 前缀 `/boot/` 下的脚本检测

```bash
for script in boot.scr.uimg boot.scr; do
    if test -e usb 0:${distro_bootpart} /boot/${script}; then
        echo Found U-Boot script /boot/${script};
        load usb 0:${distro_bootpart} 0x00500000 /boot/${script};
        source 0x00500000;
        echo SCRIPT FAILED: continuing...;
    fi
done
```

---

## 8. 目标五：bootcmd_pxe（PXE 网络启动）

环境变量：`bootcmd_pxe=run boot_net_usb_start; dhcp; if pxe get; then pxe boot; fi`

```bash
# boot_net_usb_start 展开
usb start;

# 通过 DHCP 获取网络配置
dhcp;

# 获取 PXE 启动配置并执行
if pxe get; then
    pxe boot;
fi
```

---

## 9. 目标六：bootcmd_dhcp（DHCP 脚本启动）

环境变量：`bootcmd_dhcp=run boot_net_usb_start; if dhcp ${scriptaddr} ${boot_script_dhcp}; then source ${scriptaddr}; fi`

```bash
# boot_net_usb_start 展开
usb start;

# 从 DHCP 服务器下载 boot.scr.uimg 到 scriptaddr
if dhcp 0x00500000 boot.scr.uimg; then
    source 0x00500000;
fi
```

---

## 10. 附注

1. `boot_android`、`bootrkp`、`rknand_boot` 均为 U-Boot 内置 Rockchip 命令，**不在 env 文件定义中**，本文件按内置语义展开/标注。
2. `rkimg_bootdev` 中 `bootargs` 参数 `storagemedia=emmc androidboot.mode=normal androidboot.dtbo_idx=0` 为 Rockchip 内核识别存储介质与 DTBO 索引使用。
3. env dump 中 `partitions`、`rkimg_bootdev` 存在换行截断，已按其实际语义还原拼合。
4. 磁盘实际 GPT 为 Android 经典 17 分区布局（见 `rk3326_gpt_partition_table.txt`），与 env 中 `partitions` 的旧版 5 分区默认值不一致，但实际以磁盘 GPT 为准。
