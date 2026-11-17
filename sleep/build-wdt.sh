#!/bin/sh
# build-wdt.sh KERNEL_DIR OUT_DIR PHONE_CONFIG - build the patched qcom_wdt module for the kernel the phone runs:
# KERNEL_DIR is a checkout of the kernel's source (not modified: the patch is applied to a temporary
# worktree), PHONE_CONFIG the phone's own /proc/config.gz unpacked (`zcat /proc/config.gz`). Writes
# OUT_DIR/qcom-wdt-keepalive.ko; its vermagic must equal `uname -r` of the phone (the module is refused otherwise).
# Run with arguments only: with none it prints this text and changes nothing.
set -eu
[ $# -eq 3 ] || { sed -n '2,/^set -eu/p' "$0" | sed '$d;s/^# \{0,1\}//'; exit 0; }
k=$1 out=$2 cfg=$3
here=$(cd "$(dirname "$0")/.." && pwd)
mkdir -p "$out/obj"; cp "$cfg" "$out/obj/.config"
git -C "$k" worktree add -q --detach "$out/src" HEAD
trap 'git -C "$k" worktree remove --force "$out/src"' EXIT
git -C "$out/src" apply "$here/patches/qcom-wdt-keep-armed-in-suspend.patch"
make -C "$out/src" LLVM=1 ARCH=arm64 O="$out/obj" olddefconfig >/dev/null
make -C "$out/src" LLVM=1 ARCH=arm64 O="$out/obj" -j"$(nproc)" modules_prepare >/dev/null
# modpost cannot see the kernel's symbols (no vmlinux here): undefined ones are warnings, the loader resolves them
KBUILD_MODPOST_WARN=1 make -C "$out/src" LLVM=1 ARCH=arm64 O="$out/obj" -j"$(nproc)" drivers/watchdog/qcom-wdt.ko >/dev/null
llvm-strip --strip-debug -o "$out/qcom-wdt-keepalive.ko" "$out/obj/drivers/watchdog/qcom-wdt.ko"
modinfo "$out/qcom-wdt-keepalive.ko" | grep -E '^(vermagic|parm)'
