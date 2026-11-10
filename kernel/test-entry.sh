#!/bin/sh
# A test kernel beside the stock one, tried once, never stranding the phone.
#
#   kernel/test-entry.sh install NAME VMLINUZ DTB MODULES.tgz   (MODULES.tgz holds lib/modules/RELEASE)
#   kernel/test-entry.sh try NAME       - reboot into it once; any later boot is stock
#   kernel/test-entry.sh log NAME       - what a timed-out try left on the boot partition
#   kernel/test-entry.sh remove NAME
#
# How it stays safe, with no EFI variables (this firmware's are read-only):
# - boot counting: the entry is pmos-NAME+1-0.conf, sorted ahead of stock. systemd-boot counts the
#   try down on the ESP before booting it; an entry with no tries left sorts last, so the next boot
#   is stock. The test kernel's own command line masks systemd-bless-boot, so even a good boot is
#   not blessed: it runs once.
# - a boot timeout: a second initramfs adds a hook (run early in the initramfs) that, if the real
#   system is not up in 5 minutes, saves the initramfs log and kernel messages to the ESP and reboots.
#   It tests for the real system with shell builtins only, so it cannot misfire after switch_root.
# - the test kernel's own copies of the modules the stock initramfs carries (stock ones cannot load).
# Own kernel, device tree and modules: its own version, refused if it is the running kernel's.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
usage() { echo "usage: kernel/test-entry.sh install NAME VMLINUZ DTB MODULES.tgz | try NAME | log NAME | remove NAME" >&2; exit 2; }
verb=${1:-}; name=${2:-}
[ -n "$name" ] || usage
. "$D/../lib/phone.sh"
phone_find
case $verb in
install)
	vmlinuz=${3:?}; dtb=${4:?}; mods=${5:?}
	release=$(tar tzf "$mods" | sed -n 's|^lib/modules/\([^/]*\)/$|\1|p' | head -1)
	[ -n "$release" ] || { echo "no lib/modules/RELEASE in $mods" >&2; exit 1; }
	[ "$release" != "$(echo 'uname -r' | phone_sh)" ] || { echo "$release is the running kernel's version: refusing" >&2; exit 1; }
	W=$(mktemp -d); trap 'rm -rf "$W"' EXIT
	# the second initramfs: the timeout hook, and this kernel's copies of the stock initramfs's modules
	mkdir -p "$W/mods" "$W/rd/hooks"
	tar xzf "$mods" -C "$W/mods"
	echo 'cat /boot/initramfs' | phone_root > "$W/stock.cpio.gz"
	(cd "$W/mods" && zcat "$W/stock.cpio.gz" | cpio -it --quiet 2>/dev/null | sed -n 's|^\(usr/\)\{0,1\}lib/modules/[^/]*/\(.*\.ko[^/]*\)$|\2|p') > "$W/names"
	# staged in a tree of its own for depmod, then carried as usr/lib/modules only: in the initramfs
	# lib is a link to usr/lib, which a real lib/ directory in this archive would unpack over
	S=$W/stage/lib/modules/$release
	while read -r m; do
		[ -f "$W/mods/lib/modules/$release/$m" ] || continue
		mkdir -p "$S/$(dirname "$m")"
		cp "$W/mods/lib/modules/$release/$m" "$S/$m"
	done < "$W/names"
	[ -d "$S" ] || { echo "none of the stock initramfs's modules found for $release" >&2; exit 1; }
	cp "$W/mods/lib/modules/$release"/modules.order "$W/mods/lib/modules/$release"/modules.builtin* "$S/" 2>/dev/null || true
	depmod -b "$W/stage" "$release"
	mkdir -p "$W/rd/usr/lib/modules" && cp -a "$S" "$W/rd/usr/lib/modules/"
	cat > "$W/rd/hooks/00-test-boot-timeout.sh" <<'HOOK'
#!/bin/sh
# A test kernel's boot timeout: no real system after 5 minutes -> save the log to the ESP, reboot.
(
	sleep 300
	read -r pid1 < /proc/1/comm
	[ "$pid1" = systemd ] && exit 0
	echo "test boot timeout: saving the log to the ESP and rebooting" > /dev/kmsg
	uuid=$(sed -n 's/.*pmos_boot_uuid=\([^ ]*\).*/\1/p' /proc/cmdline)
	mkdir -p /tmp/esp
	if mount -t vfat "$(findfs "UUID=$uuid")" /tmp/esp; then
		cp /pmOS_init.log /tmp/esp/test-boot.log 2>/dev/null
		dmesg > /tmp/esp/test-boot.dmesg
		umount /tmp/esp
	fi
	sync
	reboot -f
) &
HOOK
	chmod 755 "$W/rd/hooks/00-test-boot-timeout.sh"
	(cd "$W/rd" && find . | cpio -o -H newc -R root:root --quiet | gzip -9) > "$W/initramfs-$name"
	echo "second initramfs: $(find "$W/rd" -name '*.ko*' | wc -l) modules + the timeout hook"
	phone_put "$vmlinuz" /tmp/te-vmlinuz; phone_put "$dtb" /tmp/te-dtb; phone_put "$mods" /tmp/te-mods.tgz; phone_put "$W/initramfs-$name" /tmp/te-initramfs
	dtbname=$(basename "$dtb")
	phone_root <<CMDS
set -e
rm -f /boot/loader/entries/pmos-$name.conf /boot/loader/entries/pmos-$name+*.conf
install -m 644 /tmp/te-vmlinuz /boot/vmlinuz-$name
install -m 644 /tmp/te-initramfs /boot/initramfs-$name
mkdir -p /boot/dtbs-$name/qcom && install -m 644 /tmp/te-dtb /boot/dtbs-$name/qcom/$dtbname
tar xzf /tmp/te-mods.tgz -C / && depmod -a $release
options=\$(sed -n 's/^options //p' /boot/loader/entries/pmos.conf)
cat > "/boot/loader/entries/pmos-$name+1-0.conf" <<ENTRY
title postmarketOS (test kernel: $name)
sort-key 0-test-$name
linux vmlinuz-$name
initrd initramfs
initrd initramfs-$name
devicetree dtbs-$name/qcom/$dtbname
options \$options systemd.mask=systemd-bless-boot.service
ENTRY
rm -f /tmp/te-vmlinuz /tmp/te-dtb /tmp/te-mods.tgz /tmp/te-initramfs
echo "installed: pmos-$name+1-0.conf (one try), kernel $release, \$(find /lib/modules/$release -name '*.ko*' | wc -l) modules"
CMDS
	;;
try)
	phone_root <<CMDS
set -e
ls /boot/loader/entries/ | grep -q "^pmos-$name+[1-9]" || { echo "pmos-$name has no try left: install it again" >&2; exit 1; }
rm -f /boot/test-boot.log /boot/test-boot.dmesg
sync; systemd-run --on-active=2 systemctl reboot >/dev/null; echo "trying pmos-$name once"
CMDS
	;;
log)
	echo 'for f in /boot/test-boot.log /boot/test-boot.dmesg; do [ -f $f ] && { echo "== $f"; tail -60 $f; }; done; true' | phone_root
	;;
remove)
	phone_root <<CMDS
set -e
release=\$(ls /lib/modules | grep -- "-$name\$" || true)
rm -f /boot/loader/entries/pmos-$name.conf /boot/loader/entries/pmos-$name+*.conf /boot/vmlinuz-$name /boot/initramfs-$name /boot/test-boot.log /boot/test-boot.dmesg
rm -rf /boot/dtbs-$name
[ -z "\$release" ] || rm -rf "/lib/modules/\$release"
echo "removed: pmos-$name\${release:+ and the modules of \$release}"
CMDS
	;;
*) usage ;;
esac
