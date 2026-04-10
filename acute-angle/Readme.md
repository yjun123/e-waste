# Acute Angle HTPC (锐角云/三角云)

## 概述

锐角云是一款迷你HTPC设备，常被用作软路由、家庭服务器或虚拟化平台。本文档记录了该设备的硬件信息、BIOS配置、系统安装和性能优化等内容。

## 硬件信息

| Specification | Description                               |
| ------------- | ----------------------------------------- |
| CPU           | Intel Celeron N3450                       |
| iGPU          | Intel HD500                               |
| RAM           | ELPIDA FA232A2MA 2G * 4 (8G) 1666MHz DDR3 |
| eMMC          | SanDisk DF4064 64 GB EMMC TLC             |
| Hard Disk     | M.2 SATA 2242 / 硬盘接口螺丝 M1.6x3规格   |
| Ethernet      | Realtek RTL8111G                          |
| Wireless      | Intel AC3165D2W                           |
| Audio         | Realtek ALC269                            |

## 使用注意事项

### 启动相关

- **UEFI/Legacy Boot**: 锐角云原生BIOS不支持Legacy启动，只支持UEFI启动的系统
  
  *参考: [修改系统启动模式(Legacy)](#修改系统启动模式legacy)*

- **启动项选择**: 按 **F7** 进入启动项选择（包括进入BIOS设置）

### 硬件特性

- **啸声**: 电感声(?)

- **小风扇不转**: 据说是BIOS策略问题，可能需要刷BIOS才能设置(?)

- **网络唤醒**: BIOS自带网络唤醒功能，可在BIOS设置：Wake on LAN → Enable。但目前无法网络唤醒，据反馈是主板设计缺陷，关机时网卡无供电

- **BIOS电池**: 主板上有对应的插槽，接口选择T头（大扁头）

## 系统安装

### 安装 Proxmox VE

1. **下载镜像**
   
   前往 [Proxmox官网](https://www.proxmox.com/en/downloads) 下载最新镜像

2. **刻录到U盘**
   
   ```shell
   sudo dd if=Downloads/proxmox-ve_7.2-1.iso of=/dev/sdb bs=64K conv=noerror,sync status=progress
   ```

3. **启动PVE安装程序**
   
   U盘插上锐角云，开机按 F7，选择 U 盘启动。在 GRUB 界面，选择 Install Proxmox (Debug Mode)

4. **修改安装脚本**
   
   PVE Installer 不支持eMMC安装，需要修改安装脚本以支持eMMC。
   
   启动过程第一次被打断时，按 `Ctrl + D` 继续；在第二次被打断时，修改 `/usr/bin/proxinstall`，即可识别到内置的EMMC并安装。最后按 `Ctrl + D` 进行最后的安装。
   
   ```shell
   } elsif ($dev =~ m|^/dev/[^/]+/hd[a-z]$|) {
   	return "${dev}$partnum";
   } elsif ($dev =~ m|^/dev/nvme\d+n\d+$|) {
   	return "${dev}p$partnum";
   } elsif ($dev =~ m|^/dev/mmcblk\d+$|) {
   	return "${dev}p$partnum";
   } else {
   	die "unable to get device for partition $partnum on device $dev\n";
   }
   ```

## BIOS 配置

### 开启 VT-D

VT-D (Virtualization Technology for Directed I/O) 是Intel的虚拟化技术，用于设备直通。

1. **下载 setup_var.mod** 并放入 `/boot/grub/x86_64-efi/`

2. **修改 GRUB 配置**
   
   ```shell
   echo -e 'echo "insmod setup_var"\necho "setup_var_3 0x49 0x01"' >> /etc/grub.d/00_header
   ```

3. **修改 `/etc/default/grub`**
   
   ```
   GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on"
   ```

4. **生成新的 GRUB 配置**
   
   ```shell
   update-grub
   ```

5. **重启两次，检查是否成功**
   
   ```shell
   dmesg | grep DMAR
   ```
   
   成功输出示例：
   ```
   [    0.013559] ACPI: DMAR 0x0000000079AB7820 0000A8 (v01 INTEL  EDK2     00000003 BRXT 0100000D)
   [    0.058291] DMAR: IOMMU enabled
   [    2.994505] DMAR: Intel(R) Virtualization Technology for Directed I/O
   ```
   
   如果只有一行 `[    0.058291] DMAR: IOMMU enabled`，说明没有成功，可再重启一次试试。每次断电重启后需要再重启一次才能生效。

> **疑问**: 使用 efivar 找不到对应的 Setup EFI 环境变量
> 
> ```shell
> efivar -l | grep -i setup
> 8be4df61-93ca-11d2-aa0d-00e098032b8c-SetupMode
> 81c76078-bfde-4368-9790-570914c01a65-SetUpdateCountVar
> ```

### 修改系统启动模式(Legacy)

1. **修改EFI变量**
   
   设置 CSM Support 为开启，VIDEO 设置为 Legacy，调整 OS 为 Win7：
   
   ```shell
   setup_var_3 0x70 0x1
   setup_var_3 0x78 0x2
   setup_var_3 0x49E 0x2
   ```

2. **进入BIOS修改**
   
   在BIOS下改为Legacy模式（此时该选项才会生效，否则进入的仍然还是UEFI模式）

### 来电唤醒

经过论坛网友和群友测试，只需给开关并联一个 240μF 的电容即可实现来电唤醒。

## 性能优化

### 解除 CPU 性能限制

1. **安装工具**
   
   ```shell
   apt install msr-tools memtool
   ```

2. **执行命令**
   
   ```shell
   modprobe msr
   wrmsr 0x610 0x0 0x00000000
   wrmsr 0x610 0x0 0x0 0x00DD8F00
   memtool mw 0xFED170A8 16 0000
   ```

### 扩大 Aperture Size

Aperture Size 是指用于显存和系统内存之间进行数据传输的物理地址空间大小。较大的 Aperture Size 可以提高图形性能，但会占用更多的系统内存。

1. **执行命令**
   
   ```shell
   setup_var_3 0x107 0x03  # 默认256M，开到最大值512M
   ```

### 调整 DVMT 大小

DVMT (Dynamic Video Memory Technology) 是Intel开发的用于为集成显卡分配系统内存以用作显存的技术。分配的内存量可根据应用程序需求动态调整。

1. **执行命令**
   
   调整显存 DVMT Pre-Allocated 到 512M，DVMT Total Gfx Mem 到 max：
   
   ```shell
   setup_var_3 0x3A9 0x10
   setup_var_3 0x3AA 0x3
   ```

## 显卡直通

1. **获取原始 VBIOS 文件**
   
   ```shell
   lspci | grep -i vga
   # 00:02.0 VGA compatible controller: Intel Corporation HD Graphics 500 (rev 0b)
   
   cd /sys/bus/pci/devices/0000:00:02.0
   echo 1 > rom
   cat rom > /tmp/image.rom
   echo 0 > rom
   ```

2. **遇到问题**
   
   ```
   cat: rom: Input/output error
   ```
   
   **解决方案**: 修改启动模式为 CSM/Legacy
   
   尝试 GitHub issue 提到的解决方案（不起作用）：
   ```shell
   setpci -s 0000:00:02.0 COMMAND=2:2
   echo 1 > rom
   cat rom > /tmp/image.rom  # 仍然报错
   ```

## 参考资料

### 相关项目

- [Cyberpunk2177/AcuteAngle](https://github.com/Cyberpunk2177/AcuteAngle)
- [setup_var_3 模块](https://github.com/datasone/grub-mod-setup_var#setup_var_3)

### 博客与教程

- [Yadomin的博客 - 锐角云折腾记录](https://blog.yadom.in/archives/try-acute-angle-htpc.html)
- [金枪鱼之夜：家用灵车虚拟化技术指北](https://tuna.moe/event/2021/homemade-vm/)
- [梨数码 - 矿渣小主机锐角云开箱](https://lishuma.com/archives/3510)
- [Sigla - 2020上半年度最佳矿渣，锐角云！](https://post.smzdm.com/p/a3gv7x77/)
- [monster910 - 2020年最佳矿渣软路由锐角云保姆级上手教程](https://post.smzdm.com/p/akmv89k8/)
- [方舟基地 - N3450（锐角云）折腾合集](https://www.wnark.com/archives/117.html)
- [方舟基地 - N3450（锐角云）安装Proxmox VE（PVE）教程](https://www.wnark.com/archives/116.html)
- [Sora - 锐角云](https://sakura-paris.org/%E9%94%90%E8%A7%92%E4%BA%91)
- [数码玩具大BOSS - 锐角云 · 变种键盘款小主机拆解](https://post.smzdm.com/p/a25d87g7/)
- [weixin_43350568 - 锐角云hdmi直通,PVE直通核显给WIN10](https://blog.csdn.net/weixin_43350568/article/details/122915086)
- [偶尔一个博客 - 锐角云入门操作指南](https://oeone.cn/archives/491.html)
- [Bilibili - 名字超出的我 - 锐角云折腾（性能篇/便用篇）](https://www.bilibili.com/read/cv16396006)
- [十佳测评 - PVE直通核显搭建LibreELEC KODI HTPC实现HDMI输出](https://www.10bests.com/pve-libreelec-kodi-htpc/)
- [十佳测评 - PVE直通核显搭建虚拟Win10 HTPC避坑指南](https://www.10bests.com/win10-htpc-on-pve/)
- [SolaKing - 锐角云(三角云)在Linux下解锁功耗TDP限制](https://solaking.com/archives/121/)
