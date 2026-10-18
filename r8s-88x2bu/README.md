# 88x2bu.ko for Samsung Galaxy S20 FE (r8s), LineageOS 23.2

Prebuilt RTL88x2BU/RTL8812BU USB WiFi driver (e.g. ASUS USB-AC53 Nano, 0b05:184c) from
[RinCat/RTL88x2BU-Linux-Driver](https://github.com/RinCat/RTL88x2BU-Linux-Driver) @ b4e4c1b.

- vermagic: `4.19.325-cip126-st10-g88a015858b05 SMP preempt mod_unload modversions aarch64`
- Kernel: LineageOS/android_kernel_samsung_universal9830 @ 88a015858b05, `exynos9830_defconfig r8s.config`
- Toolchain: clang r416183b (same as the LineageOS device tree), LTO, full kernel build for `Module.symvers`
- All 218 symbol CRCs checked against the kernel's `Module.symvers`

## Load (root)

```sh
su
insmod /sdcard/Download/88x2bu.ko
dmesg | tail
ip link        # new interface, usually wlan1
```

Unload: `rmmod 88x2bu`. Rebuild from scratch: `./build.sh`.
