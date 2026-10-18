# Xereox ET1020

English · [简体中文](README.zh-CN.md)

A tablet picked up from a fellow member of a QQ group; it was originally the control panel of a Xerox printer [1](https://github.com/retro98boy/rockchip-devices/tree/main/devices/xerox-et1020#%E7%A1%AC%E4%BB%B6). There is no battery 🔋, so it must be used plugged in (Type-C).

![](images/outside/Front.jpg)



## Hardware

| Specifications | Description |
| --- | --- |
| Model | ET1020 |
| Serial number | ET1020B180400580 |
| SoC | Rockchip RK3399 |
| PMIC | Rockchip RK818 |
| DRAM | 2GB DDR |
| eMMC | 16GB |
| WiFi/BT | AP6255? |
| Display | 7.08 inch 1920x1200 60hz |
| Audio codec | ALC5645? |
| Front camera | GC2145? / 2MP / 1600x1200 |
| Rear camera | OV8858? / 8MP / 3264 x 2448 |
| Accelerometer | MPU6500? |
| Gyroscope | MPU6500? |
| Hall sensor | AK8963? |
| Magnetometer |  |
| Ambient light sensor | CM3218? |



| Interfaces | Description |
| --- | --- |
| Power | Type-C |
| Headphone jack | 3.5mm * 1 |
| Micro USB | * 1 |
| Micro SD | * 1 |
| Microphone | * 2? |
| Speaker | * 2 |
| Buttons | Power, Back, Volume Up, Volume Down |



## Images

See [images](./images) for device teardown details.



## Debug UART



## Maskrom Mode





## Mainline Linux



### Device Tree

Thanks to the work done by [@retro98boy](https://github.com/retro98boy/rockchip-devices/tree/main/devices/xerox-et1020), the mainline kernel is now supported.

[rk3399-et1020.dts](https://github.com/yjun123/linux/blob/feature_xerox_et1020/arch/arm64/boot/dts/rockchip/rk3399-et1020.dts)



### Distributions



### Drivers



### Peripheral Status



## References

[Github - retro98boy/rockchip-devices - xerox-et1020](https://github.com/retro98boy/rockchip-devices/tree/main/devices/xerox-et1020)

[恩山无线论坛 - [RK3399]10.6英寸带触摸屏](https://www.right.com.cn/forum/thread-8337866-1-1.html)

[Bilibili - 当代玩物社 -【玩物】破解RK3399平板当作开发板-上](https://www.bilibili.com/video/BV1vf97B5E4c)

[Bilibili - 当代玩物社 -【玩物】破解RK3399平板当作开发板-下](https://www.bilibili.com/video/BV1EHdfBBERQ)