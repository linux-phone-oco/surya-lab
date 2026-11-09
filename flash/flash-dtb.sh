#!/bin/sh
# Flash a stock Nura image with ONE device tree swapped in, then see whether the phone comes up.
#
#   flash-dtb.sh IMAGE UBOOT DTB
#
# One variable at a time: IMAGE is a pristine stock image (never modified; a copy is), UBOOT the
# panel's U-Boot (Huaxing for this phone), DTB the device tree under test. Destructive on purpose:
# it overwrites the phone's userdata. Cleans up its mount and loop device even when stopped.
#
# Also makes sshd come up on first boot. The image has no /etc/machine-id, so its first boot runs
# systemd's preset-all, and Nura ships 80-pmbootstrap-install-disable-sshd.preset ("disable
# sshd.service"), which erases a plain enable-symlink. A lower-numbered preset in /etc wins.
set -e
IMG=${1:?usage: flash-dtb.sh IMAGE UBOOT DTB}; UBOOT=${2:?}; DTB=${3:?}
BOARD_DTB=dtbs/qcom/sm7150-xiaomi-surya-huaxing.dtb
PHONE=172.16.42.1
R="sudo -n lab-agent root-exec --"
W=$(mktemp -d "$HOME/.cache/flash.XXXXXX" 2>/dev/null || { mkdir -p "$HOME/.cache"; mktemp -d "$HOME/.cache/flash.XXXXXX"; })
LOOP=""
cleanup() {
  for m in esp root; do findmnt -rn -M "$W/$m" >/dev/null 2>&1 && $R umount "$W/$m"; done
  [ -n "$LOOP" ] && $R losetup -d "$LOOP"
  rm -rf "$W"
}
trap cleanup EXIT
trap 'exit 143' TERM

echo "== image: a copy, so the pristine one stays pristine =="
cp "$IMG" "$W/test.img"
LOOP=$($R losetup --show -f --sector-size 4096 -P "$W/test.img")
mkdir "$W/esp" "$W/root"
$R mount "${LOOP}p1" "$W/esp"
$R mount "${LOOP}p2" "$W/root"

echo "== device tree under test =="
D="$W/esp/$BOARD_DTB"
echo "stock:  $(stat -c %s "$D") bytes  sha256 $(sha256sum "$D" | cut -c1-16)"
$R cp -n "$D" "$D.orig-backup"
$R cp "$DTB" "$D"
echo "now:    $(stat -c %s "$D") bytes  sha256 $(sha256sum "$D" | cut -c1-16)  <- $DTB"

echo "== sshd on first boot (preset) =="
printf '# written by flash-dtb.sh: Nura disables sshd by preset; this wins by sorting first\nenable sshd.service\n' \
  | $R install -D -m 644 /dev/stdin "$W/root/etc/systemd/system-preset/10-lab.preset"
cat "$W/root/etc/systemd/system-preset/10-lab.preset" | tail -1

$R umount "$W/esp" "$W/root"
$R losetup -d "$LOOP"; LOOP=""

echo "== flash =="
fastboot devices | grep -q fastboot || { echo "the phone is not in fastboot - nothing flashed"; exit 1; }
fastboot flash boot "$UBOOT"
fastboot flash userdata "$W/test.img"
timeout 30 fastboot reboot || true
echo "rebooted at $(date +%T); waiting up to 3 minutes for the phone to answer on USB ($PHONE)"

up=""
for i in $(seq 1 45); do
  if ping -c1 -W2 $PHONE >/dev/null 2>&1; then up=$((i * 4)); break; fi
  sleep 2
done
[ -n "$up" ] || { echo "NO ANSWER in 3 minutes: the phone did not come up (hang or boot loop)"; exit 3; }
echo "the phone answers ping after ~${up}s: the kernel is up"

SSH="sshpass -p 147147 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=5 user@$PHONE"
for i in $(seq 1 30); do $SSH true 2>/dev/null && { ok=1; break; }; sleep 4; done
[ -n "$ok" ] || { echo "kernel is up but SSH never answered (a real ssh client, over USB, 2 minutes)"; exit 4; }
echo "SSH works over USB"
$SSH 'uname -r; uptime -p; echo "--- cards:"; cat /proc/asound/cards'
