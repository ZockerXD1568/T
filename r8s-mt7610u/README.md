# MediaTek MT7610U firmware for Samsung Galaxy S20 FE (r8s), LineageOS 23.2

The ALFA "AWUS036ACHM" unit here is actually a **MediaTek MT7610U** (USB 0e8d:7610),
not a Realtek. The kernel driver `mt76x0u` is already loaded (Stryker: "driver bound"),
it only needs the firmware file `mediatek/mt7610u.bin`, which was missing.

- File: `mediatek/mt7610u.bin` (80288 bytes), from upstream linux-firmware.
- No kernel module needs to be compiled: the driver matches 0e8d:7610 and just wants firmware.

The r8s kernel searches firmware under `/lib/firmware...` plus a settable path at
`/sys/module/firmware_class/parameters/path` (CONFIG_FW_LOADER=y). Since Android has no
`/lib/firmware`, point that path at a directory that contains `mediatek/mt7610u.bin`.

## Install (root, in the Stryker terminal)

```sh
su
# 1) put the firmware where the kernel can read it (real Android fs, not only the chroot)
mkdir -p /data/local/tmp/firmware/mediatek
cp /sdcard/Download/mt7610u.bin /data/local/tmp/firmware/mediatek/mt7610u.bin
chmod 644 /data/local/tmp/firmware/mediatek/mt7610u.bin

# 2) tell the kernel firmware loader to also look there
echo /data/local/tmp/firmware > /sys/module/firmware_class/parameters/path

# 3) re-probe: unplug + replug the adapter, or hit "Re-scan" in Stryker
dmesg | grep -i -E "mt76|mt7610|firmware" | tail -20
ip link            # a new interface (e.g. wlan2) should now come up
```

If Stryker uses its own chroot firmware dir, copying the file to
`<chroot>/lib/firmware/mediatek/mt7610u.bin` works too; the `firmware_class` path knob
above is the reliable method.

Reboots reset the path knob and /data/local/tmp, so repeat steps 1-2 after a reboot
(or use a KernelSU service.d script to re-apply them on boot).

## Magisk module (persistent, recommended)

`mt7610u-firmware-magisk.zip` is a Magisk module. Install it in Magisk →
Modules → "Install from storage", then reboot. On every boot it:
- ships `mediatek/mt7610u.bin` and points `/sys/module/firmware_class/parameters/path`
  at itself, so the kernel's `request_firmware("mediatek/mt7610u.bin")` resolves;
- also overlays `/vendor/firmware/mediatek/mt7610u.bin` as a fallback.

After reboot, replug the adapter (or "Re-scan" in Stryker). No kernel module is
compiled — the `mt76x0u` driver is already loaded; only firmware was missing.
