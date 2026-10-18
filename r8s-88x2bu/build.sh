#!/bin/bash
# Reproducible build of 88x2bu.ko for Samsung Galaxy S20 FE (r8s), LineageOS 23.2,
# kernel 4.19.325-cip126-st10-g88a015858b05.
set -euo pipefail
W=${W:-$PWD/work}
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$W" && cd "$W"

KCOMMIT=88a015858b05079fa97bae02238a73d82fc1198f
[ -d kernel ] || git clone --filter=blob:none --no-checkout -b lineage-23.2 \
	https://github.com/LineageOS/android_kernel_samsung_universal9830 kernel
git -C kernel checkout -q $KCOMMIT

# Same toolchain as device/samsung/universal9830-common (TARGET_KERNEL_CLANG_VERSION := r416183b)
[ -d clang ] || git clone --depth 1 -b lineage-20.0 \
	https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b clang

[ -d driver ] || { git clone https://github.com/RinCat/RTL88x2BU-Linux-Driver driver &&
	git -C driver apply "$HERE/0001-Makefile-add-r8s-android-arm64-platform.patch"; }

export PATH=$W/clang/bin:$PATH
KMAKE=(make -C "$W/kernel" O="$W/out" ARCH=arm64 LLVM=1 LLVM_IAS=1 CC=clang LD=ld.lld
	CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu- HOSTCC=clang HOSTCXX=clang++)

"${KMAKE[@]}" exynos9830_defconfig r8s.config
test "$("${KMAKE[@]}" -s kernelrelease)" = 4.19.325-cip126-st10-g88a015858b05
# Full build is required: CONFIG_MODVERSIONS=y needs Module.symvers with the real CRCs
"${KMAKE[@]}" -j"$(nproc)"
"${KMAKE[@]}" M="$W/driver" -j"$(nproc)" modules
llvm-strip --strip-debug "$W/driver/88x2bu.ko"
modinfo "$W/driver/88x2bu.ko" 2>/dev/null | grep vermagic || strings "$W/driver/88x2bu.ko" | grep vermagic=
