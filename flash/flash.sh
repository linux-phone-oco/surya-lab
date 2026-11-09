#!/bin/sh
# Flash a Nura/postmarketOS image to the phone with everything it needs for surya built in.
#
#   flash/flash.sh IMAGE UBOOT [DTB]
#
# IMAGE a raw image (decompressed), UBOOT the panel's U-Boot (Huaxing for this phone), DTB an
# optional device tree under test. Destructive on purpose: it overwrites the phone's userdata.
# Works on a copy of IMAGE, cleans up its mounts and loop device even when stopped.
#
# Built in, so the phone comes up the way we left the last one:
#  - sound: the stereo speaker profile (ucm/) and, when the image runs the kernel it was built for,
#    the fixed tas2562 amplifier module (MODULE, default ~/Projects/surya-audio/kernel-rc3/...)
#  - stability: the ADSP sensors service masked (its crash loop takes audio down)
#  - access: sshd on first boot. Nura's 80-...-disable-sshd.preset erases a plain enable-symlink
#    on the first boot's preset-all; a lower-numbered preset in /etc wins.
set -eu
IMG=${1:?usage: flash.sh IMAGE UBOOT [DTB]}; UBOOT=${2:?}; DTB=${3:-}
LAB=$(cd "$(dirname "$0")/.." && pwd)
MODULE=${MODULE:-$HOME/Projects/surya-audio/kernel-rc3/snd-soc-tas2562.ko.zst}
MODULE_KERNEL=7.1.0-rc3-sm7150
FIXES=${FIXES:-1}   # FIXES=0: flash the image as it is (sshd only), to tell an image fault from ours
BOARD_DTB=dtbs/qcom/sm7150-xiaomi-surya-huaxing.dtb
R="sudo -n lab-agent root-exec --"
W=$(mktemp -d); LOOP=""
cleanup() {
  for m in esp root; do findmnt -rn -M "$W/$m" >/dev/null 2>&1 && $R umount "$W/$m"; done
  [ -n "$LOOP" ] && $R losetup -d "$LOOP"
  rm -rf "$W"
}
trap cleanup EXIT
trap 'exit 143' TERM
cp --sparse=always "$IMG" "$W/test.img"
mkdir -p "$W/esp" "$W/root"
LOOP=$($R losetup --show -f --sector-size 4096 -P "$W/test.img")
$R mount "${LOOP}p1" "$W/esp"
$R mount "${LOOP}p2" "$W/root"
ROOT="$W/root"
if [ -n "$DTB" ]; then
  $R cp "$DTB" "$W/esp/$BOARD_DTB"; echo "device tree: $(sha256sum "$DTB" | cut -c1-16) <- $DTB"
fi
if [ "$FIXES" = 1 ]; then
echo "== sound: stereo speaker profile =="
$R install -D -m 644 "$LAB/ucm/Xiaomi/surya/HiFi.conf" "$ROOT/usr/share/alsa/ucm2/Xiaomi/surya/HiFi.conf" && echo "installed"
echo "== sound: the fixed amplifier driver =="
kernels=$(ls "$ROOT/lib/modules" | tr '\n' ' ')
if [ -d "$ROOT/lib/modules/$MODULE_KERNEL" ] && [ -f "$MODULE" ]; then
  # Same name, same dependencies and aliases as the packaged module, so the image's own module
  # index already covers it: no depmod. Re-indexing from the PC with -b made the phone boot-loop
  # (2026-11-09: the image booted unmodified, and with the fixes applied on the phone).
  $R install -m 644 "$MODULE" "$ROOT/lib/modules/$MODULE_KERNEL/kernel/sound/soc/codecs/snd-soc-tas2562.ko.zst"
  echo "installed for $MODULE_KERNEL"
else
  echo "NOT installed: the image runs $kernels, the module is for $MODULE_KERNEL (or no module at $MODULE) - speaker will be mono"
fi
echo "== stability: ADSP sensors service masked =="
$R ln -sf /dev/null "$ROOT/etc/systemd/system/hexagonrpcd-adsp-sensorspd.service" && echo "masked"
else
  echo "== FIXES=0: the image as it is, nothing but sshd =="
fi
echo "== access: sshd on first boot =="
printf '# written by surya-lab flash.sh: Nura disables sshd by preset; this wins by sorting first\nenable sshd.service\n' \
  | $R install -D -m 644 /dev/stdin "$ROOT/etc/systemd/system-preset/10-lab.preset" && echo "enabled"
$R umount "$W/esp" "$W/root"
$R losetup -d "$LOOP"; LOOP=""
echo "== flashing =="
fastboot devices | grep -q fastboot || { echo "the phone is not in fastboot - nothing flashed"; exit 1; }
fastboot flash boot "$UBOOT"
fastboot flash userdata "$W/test.img"
timeout 30 fastboot reboot || true
