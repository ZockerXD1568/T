# MT7610U WiFi driver + firmware for Samsung Galaxy S20 FE (r8s)

Kernel `4.19.325-cip126-st10-g88a015858b05` (LineageOS 23.2).

The ALFA "AWUS036ACHM" here is a **MediaTek MT7610U** (USB 0e8d:7610). The stock
r8s kernel has NO mt76 driver and NO mac80211 built in, so the adapter only ever
bound a stub ("driver bound, no interface"). This package adds the real driver.

## Modules (all built against the exact kernel, vermagic + all symbol CRCs verified)
- `ccm.ko`       - AES-CCM crypto (needed by mac80211 for WPA2, not in stock kernel)
- `mac80211.ko`  - soft-MAC 802.11 stack (not in stock kernel)
- `mt76.ko`      - MediaTek mt76 core
- `mt76x0.ko`    - MT7610U USB driver (binds 0e8d:7610), requests mediatek/mt7610u.bin

Build notes: ThinLTO kernel config (matches device, module_layout 0x2f7e1fab).
mt76/mt76x0 compiled with -fno-lto to work around a clang-ThinLTO compiletime_assert
elimination bug; mac80211/ccm built normally. vermagic kept clean (no -dirty).

## Install (no terminal needed)
Flash `mt7610u-wifi-driver-magisk-v3.zip` in Magisk -> Modules -> Install from storage,
reboot, then plug the adapter (or Re-scan in Stryker). At boot the module loads
ccm -> mac80211 -> mt76 -> mt76x0 in order, places the firmware, and re-triggers the
adapter. A log is written to /sdcard/mt7610u-module.log.

Load order if doing it by hand: insmod ccm.ko; insmod mac80211.ko; insmod mt76.ko; insmod mt76x0.ko
