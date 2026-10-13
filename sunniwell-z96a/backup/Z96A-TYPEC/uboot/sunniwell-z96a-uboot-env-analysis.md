# Sunniwell Z96A U-Boot 环境变量与启动逻辑分析

> 源文件：`uboot_env.txt`（提取自 `partitions/uboot_mmcblk2p2.img`，44 个变量）
> 提取方式：`partitions/extract_uboot_env.py`（环境块位于偏移 `0xc1ed0` 与 `0x2c1ed0`，两份冗余副本）
> 平台：Rockchip RK3568，`board=evb_rk3568`

## 一、结论先行

1. 这是一份 **Rockchip RK3568 通用 EVB 的默认环境变量**（`board=evb_rk3568`、`vendor=rockchip`），**没有为 Z96A 做任何定制**——厂商直接沿用了 SDK 的 U-Boot 默认环境。
2. 启动采用 **多级回退**：`boot_android` → `boot_fit` → `bootrkp` → 标准 distro boot。前三级是 Rockchip 内置命令（本 env 中未定义），最后一级是主线风格的 distro boot——**正是这一级让 Armbian/主线 Linux 无需改 U-Boot 即可启动**。
3. 设备优先级：**SD 卡 > eMMC > MTD(NAND) > SPI-NAND/NOR > USB > PXE/DHCP 网络**。

## 二、变量分组速查

| 分组 | 变量 | 说明 |
| --- | --- | --- |
| 基础参数 | `bootcmd` `bootdelay` `baudrate` `autoload` `preboot` | 主启动命令 / 延时 / 波特率 |
| 板级标识 | `arch` `cpu` `board` `board_name` `vendor` `soc` | `evb_rk3568` 通用标识 |
| 内存地址 | `scriptaddr` `pxefile_addr_r` `fdt_addr_r` `kernel_addr_r` `kernel_addr_c` `ramdisk_addr_r` | 脚本/DTB/内核/initrd 加载地址 |
| 分区表 | `partitions` | Android GPT 分区布局 |
| 控制台 | `stdin` `stdout` `stderr` | 串口 + USB 键盘 / vidconsole |
| 设备探测 | `rkimg_bootdev` | 依次探测 SD/eMMC/MTD/rknand/rksfc，设置 `devtype`/`devnum` |
| 设备入口 | `mmc_boot` `usb_boot` `boot_net_usb_start` | 各设备类型的启动函数 |
| distro 参数 | `boot_prefixes` `boot_scripts` `boot_script_dhcp` `boot_targets` | 扫描路径 / 脚本名 / 目标列表 |
| distro 扫描 | `boot_extlinux` `scan_dev_for_extlinux` `boot_a_script` `scan_dev_for_scripts` `scan_dev_for_boot` `scan_dev_for_boot_part` | 标准 distro boot 的逐级扫描 |
| 目标入口 | `bootcmd_mmc1/0` `bootcmd_mtd2/1/0` `bootcmd_usb0` `bootcmd_pxe` `bootcmd_dhcp` | `boot_targets` 对应的执行体 |
| 分发 | `distro_bootcmd` | 遍历 `boot_targets` 逐个执行 |

## 三、启动主链路

### 1. `bootcmd` —— 一级入口

```
bootcmd = boot_android ${devtype} ${devnum}; boot_fit; bootrkp; run distro_bootcmd;
```

用 `;` 串联的**顺序回退链**：

| 顺序 | 命令 | 来源 | 作用 |
| --- | --- | --- | --- |
| ① | `boot_android ${devtype} ${devnum}` | Rockchip 内置命令 | 从 `boot` 分区加载并启动 Android（正常路径，成功则不返回） |
| ② | `boot_fit` | Rockchip 内置命令 | 启动 FIT 镜像（Android 11 的 `boot.img` 为 FIT 格式） |
| ③ | `bootrkp` | Rockchip 内置命令 | 启动 Rockchip 传统 `resource`+`kernel` 镜像 |
| ④ | `run distro_bootcmd` | env 定义 | 标准主线 distro boot（Armbian/主线 Linux 走这里） |

关键点：**只有当 ①②③ 都失败（未找到 Android 镜像）时，才会进入 ④ 的标准 distro boot**。这就是社区移植（bingo1991/kemp233 等）能够用 U-Boot 引导主线内核的基础。

### 2. `rkimg_bootdev` —— 启动介质探测

```
rkimg_bootdev = if mmc dev 1 && rkimgtest mmc 1; then setenv devtype mmc; setenv devnum 1; echo Boot from SDcard;
                elif mmc dev 0; then setenv devtype mmc; setenv devnum 0;
                elif mtd_blk dev 0; ... elif rknand dev 0; ... elif rksfc dev 0; ... elif rksfc dev 1; ...
                else setenv devtype ramdisk; setenv devnum 0; fi;
```

按顺序探测：`mmc 1`(SD) → `mmc 0`(eMMC) → `mtd_blk 0/1/2`(NAND) → `rknand` → `rksfc 0`(SPI-NAND) → `rksfc 1`(SPI-NOR)，成功后设置 `devtype`/`devnum`。**SD 卡优先级高于 eMMC**，这是 Rockchip 的一贯策略（便于卡刷/调试）。

### 3. `distro_bootcmd` —— 标准 distro boot 分发

```
distro_bootcmd = for target in ${boot_targets}; do run bootcmd_${target}; done
boot_targets   = mmc1 mmc0 mtd2 mtd1 mtd0 usb0 pxe dhcp
```

遍历 8 个目标，逐个执行 `bootcmd_<target>`。每个目标入口只是「设 `devnum` + 调用对应设备启动函数」：

| 入口 | 内容 | 目标设备 |
| --- | --- | --- |
| `bootcmd_mmc1` | `setenv devnum 1; run mmc_boot` | SD 卡 |
| `bootcmd_mmc0` | `setenv devnum 0; run mmc_boot` | eMMC |
| `bootcmd_mtd2/1/0` | `setenv devnum N; run mtd_boot` | NAND（`mtd_boot` 为内置命令） |
| `bootcmd_usb0` | `setenv devnum 0; run usb_boot` | USB |
| `bootcmd_pxe` | `run boot_net_usb_start; dhcp; if pxe get; then pxe boot; fi` | 网络 PXE |
| `bootcmd_dhcp` | `run boot_net_usb_start; if dhcp ${scriptaddr} ${boot_script_dhcp}; then source ${scriptaddr}; fi` | 网络 DHCP |

### 4. 单设备扫描：`mmc_boot` → `scan_dev_for_boot_part` → `scan_dev_for_boot`

```
mmc_boot              = if mmc dev ${devnum}; then setenv devtype mmc; run scan_dev_for_boot_part; fi
scan_dev_for_boot_part= part list ${devtype} ${devnum} -bootable devplist;
                        env exists devplist || setenv devplist 1;
                        for distro_bootpart in ${devplist}; do
                          if fstype ${devtype} ${devnum}:${distro_bootpart} bootfstype; then
                            run scan_dev_for_boot; fi; done
scan_dev_for_boot     = for prefix in ${boot_prefixes}; do run scan_dev_for_extlinux; run scan_dev_for_scripts; done;
boot_prefixes         = / /boot/
```

逻辑：列出**标记为 bootable 的分区**，对每个分区识别文件系统类型，然后在 `/` 与 `/boot/` 两个前缀下依次尝试 **extlinux** 与 **U-Boot 脚本**。

### 5. 两种引导方式：extlinux vs 脚本

**extlinux**（主线/发行版默认）：

```
scan_dev_for_extlinux = if test -e .../${prefix}extlinux/extlinux.conf; then
                          echo Found extlinux.conf; run boot_extlinux; ...; fi
boot_extlinux         = sysboot ${devtype} ${devnum}:${distro_bootpart} any ${scriptaddr} ${prefix}extlinux/extlinux.conf
```

**U-Boot 脚本**（`boot.scr` / `boot.scr.uimg`）：

```
boot_scripts       = boot.scr.uimg boot.scr
scan_dev_for_scripts = for script in ${boot_scripts}; do if test -e ...; then run boot_a_script; fi; done
boot_a_script      = load ... ${scriptaddr} ${prefix}${script}; source ${scriptaddr}
```

## 四、关键变量详解

### 内存加载地址（RK3568 标准布局）

| 变量 | 地址 | 用途 |
| --- | --- | --- |
| `scriptaddr` | `0x00c00000` | U-Boot 脚本加载地址 |
| `pxefile_addr_r` | `0x00e00000` | PXE 文件加载地址 |
| `kernel_addr_r` | `0x00280000` | 内核加载地址 |
| `kernel_addr_c` | `0x04080000` | 压缩内核加载地址（Rockchip 扩展） |
| `fdt_addr_r` | `0x0a100000` | 设备树加载地址 |
| `ramdisk_addr_r` | `0x0a200000` | initrd 加载地址 |

> `fdt_addr_r=0x0a100000` 与 DTS 分析文档中 chosen 节点预留的内存段 `0x0a100000` 一致，相互印证。

### `partitions` —— GPT 分区表定义

这是 Rockchip Android 的标准分区布局（`size=-` 表示占用剩余空间）：

| 分区 | 大小 | UUID 变量 | 用途 |
| --- | --- | --- | --- |
| `uboot` | 4MB（start=8MB） | `${uuid_gpt_loader2}` | U-Boot 本体 |
| `trust` | 4MB | `${uuid_gpt_atf}` | ATF/可信固件 |
| `misc` | 4MB | `${uuid_gpt_misc}` | 恢复/杂项标记 |
| `resource` | 16MB | `${uuid_gpt_resource}` | Rockchip 资源镜像 |
| `kernel` | 32MB | `${uuid_gpt_kernel}` | 内核 |
| `boot` | 32MB（bootable） | `${uuid_gpt_boot}` | Android boot 镜像 |
| `recovery` | 32MB | `${uuid_gpt_recovery}` | 恢复系统 |
| `backup` | 112MB | `${uuid_gpt_backup}` | 备份 |
| `cache` | 512MB | `${uuid_gpt_cache}` | 缓存 |
| `system` | 2048MB | `${uuid_gpt_system}` | Android 系统 |
| `metadata` | 16MB | `${uuid_gpt_metadata}` | 元数据 |
| `vendor` | 32MB | `${uuid_gpt_vendor}` | 厂商分区 |
| `oem` | 32MB | `${uuid_gpt_oem}` | OEM 分区 |
| `frp` | 512KB | `${uuid_gpt_frp}` | Factory Reset Protection |
| `security` | 2MB | `${uuid_gpt_security}` | 安全相关 |
| `userdata` | 剩余（`-`） | `${uuid_gpt_userdata}` | 用户数据 |

### 控制台

```
stdin  = serial,usbkbd
stdout = serial,vidconsole
stderr = serial,vidconsole
```

输入来自串口 + USB 键盘，输出到串口 + 视频控制台（与 `baudrate=1500000` 的调试串口一致）。

## 五、与 Z96A 适配的关系

- `board=evb_rk3568` / `board_name=evb_rk3568`：**用的是 RK3568 通用 EVB 板级配置**，未改成 Z96A 专属名称。说明厂商的 U-Boot 直接取自 Rockchip SDK 默认值，量产时未做板级标识定制。
- 这也意味着：**U-Boot 本身不依赖 Z96A 的特定外设**（不涉及 PD 充电、SC8886、HUSB311 等），那些差异化都在内核/设备树层处理，U-Boot 只管「从哪块介质、按什么顺序启动」。
- `bootcmd` 里保留完整的 `distro_bootcmd` 标准链路，是社区（Armbian/主线）能直接在 Z96A 上跑起来的前置条件。

## 六、总结

| 维度 | 结论 |
| --- | --- |
| 启动主路径 | `boot_android` 启动 Android 云桌面系统 |
| 回退链 | Android → FIT → rkp → 标准 distro boot |
| 介质优先级 | SD > eMMC > NAND > SPI > USB > 网络 |
| 引导方式 | extlinux.conf 或 boot.scr（U-Boot 脚本） |
| 定制程度 | 无（通用 `evb_rk3568` 默认环境） |
| 对移植的意义 | 保留 distro boot 使主线 Linux 可直接引导 |

## 七、直接跳转到 `distro_bootcmd` 的方法

### 1. 提示符下直接运行（最简单）

```
run distro_bootcmd
```

自包含——`boot_targets` 里的每个 `bootcmd_*` 都会自行 `setenv devnum`/`devtype`，无需先设任何变量。

### 2. 如何进入提示符（`bootdelay=0`）

这份 env 里 `bootdelay=0`，不等待按键，需在串口上抢：

- 接调试串口（UART2，**1500000 8N1**）。
- 上电瞬间连续按 `Ctrl+C`（或狂按任意键）。Rockchip 控制台很早就可用，即使 `bootdelay=0` 多数也能在 `boot_android` 执行前打断。

更省心的做法是临时调出延时窗口（本次会话有效）：

```
setenv bootdelay 3
```

### 3. 改 `bootcmd` 直接指向（推荐，绕过 Android 回退链）

```
setenv bootcmd 'run distro_bootcmd'
boot
```

- 不加 `saveenv` 为**一次性**（重启恢复原样），适合测试。
- 持久化需额外：

  ```
  setenv bootdelay 3
  saveenv
  ```

  ⚠️ 本机 env 保存在 `uboot` 分区的非标准偏移处（dump 中默认 env 在 `0xc1ed0`，标准 sector `0x3F0000/0x3F8000` 全为 0、从未写入）。`saveenv` 能否落盘取决于编译时的 `CONFIG_ENV_OFFSET`，不确定时先用「一次性」方式验证。

### 4. 只跑某个设备，跳过网络（避免 PXE/DHCP 挂起）

`distro_bootcmd` 走到最后会尝试 `pxe`/`dhcp`，无网络时会挂起等 DHCP。指定设备可跳过：

```
# SD 卡
setenv devtype mmc; setenv devnum 1; run scan_dev_for_boot_part

# eMMC
setenv devtype mmc; setenv devnum 0; run scan_dev_for_boot_part
```

### 前提

目标分区必须是 **bootable 分区**，且存在 `/extlinux/extlinux.conf` 或 `/boot/extlinux/extlinux.conf`，或 `boot.scr`/`boot.scr.uimg`；否则 `scan_dev_for_boot` 找不到引导项，会一路空转到网络。

> 补充：`bootcmd` 的最后一级本来就是 `run distro_bootcmd`，只要 `boot_android`/`boot_fit`/`bootrkp` 失败（如刷了主线 Linux、无合法 Android 镜像），会**自动**落到 distro boot。「直接跳」的意义在于 Android 镜像还在时也能强制走 SD 卡上的主线系统。

### 5. USB 启动示例

对应 env 里的链路：

```
boot_net_usb_start = usb start
usb_boot           = usb start; if usb dev ${devnum}; then setenv devtype usb; run scan_dev_for_boot_part; fi
bootcmd_usb0       = setenv devnum 0; run usb_boot
```

**方式一：直接跑 distro boot 的 USB 目标（一条命令）**

```
run bootcmd_usb0
```

**方式二：手动分步（推荐，能看清每一步输出）**

```
usb start                        # 初始化 USB 控制器
usb dev 0                        # 选择第 0 个 USB 存储设备
setenv devtype usb
setenv devnum 0
run scan_dev_for_boot_part       # 扫描 bootable 分区上的 extlinux.conf / boot.scr
```

排查用的辅助命令：

```
usb tree                         # 列出 USB 总线/设备树
usb storage                      # 列出已识别的 USB 存储设备
```

注意事项：

- **插哪个口**：插 **USB-A 口**（对应 `usbhost_dwc3`，`dr_mode="host"` 的那个 USB3 host 控制器）。Type-C OTG 口是 DRP（`try-power-role=source`），设计上是供电/设备口，不建议用它引导。
- **介质准备**：U 盘需 MBR/GPT，含标记为 **bootable** 的分区，且根目录或 `/boot/` 下有 `/extlinux/extlinux.conf` 或 `boot.scr`/`boot.scr.uimg`。
- **优先级**：`boot_targets` 里 `usb0` 排在 `mmc1 mmc0 mtd*` 之后，所以**插着 SD/eMMC 可引导系统时 USB 不会被优先选**。要强制 USB 引导，用上面的直接运行方式，或 `setenv bootcmd 'run bootcmd_usb0'`。
- 若 `usb dev 0` 报错找不到设备，先 `usb reset` 再 `usb start` 重扫。
