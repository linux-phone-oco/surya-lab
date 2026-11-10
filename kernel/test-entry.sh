#!/bin/sh
# A test kernel beside the stock one: a second systemd-boot entry, pmos-NAME.conf, with its own
# kernel, device tree and modules (its own version, so nothing of the stock kernel is touched); the
# stock initramfs is reused - storage, filesystem and display are built in, it needs no modules to
# reach the root. The stock entry stays the default.
#
#   kernel/test-entry.sh install NAME VMLINUZ DTB MODULES.tgz   (MODULES.tgz holds lib/modules/RELEASE)
#   kernel/test-entry.sh boot-once NAME   - reboot into it once: the next boot makes stock the default again
#   kernel/test-entry.sh remove NAME
#
# boot-once uses files on the ESP only: this firmware's EFI variables are read-only, so systemd-boot's
# one-shot entry cannot be set. loader.conf is saved, the test entry made the default with a 5 s menu,
# and a service restores loader.conf at the next boot, whichever kernel gets there - so the test
# kernel boots once. If it hangs before that: hold power, pick the stock entry in the menu.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
usage() { echo "usage: kernel/test-entry.sh install NAME VMLINUZ DTB MODULES.tgz | boot-once NAME | remove NAME" >&2; exit 2; }
verb=${1:-}; name=${2:-}
[ -n "$name" ] || usage
. "$D/../lib/phone.sh"
phone_find
case $verb in
install)
	vmlinuz=${3:?}; dtb=${4:?}; mods=${5:?}
	release=$(tar tzf "$mods" | sed -n 's|^lib/modules/\([^/]*\)/$|\1|p' | head -1)
	[ -n "$release" ] || { echo "no lib/modules/RELEASE in $mods" >&2; exit 1; }
	[ "$release" != "$(echo 'uname -r' | phone_sh)" ] || { echo "$release is the running kernel's version: refusing (its modules would replace the stock ones)" >&2; exit 1; }
	phone_put "$vmlinuz" /tmp/te-vmlinuz; phone_put "$dtb" /tmp/te-dtb; phone_put "$mods" /tmp/te-mods.tgz
	dtbname=$(basename "$dtb")
	phone_root <<CMDS
set -e
install -m 644 /tmp/te-vmlinuz /boot/vmlinuz-$name
mkdir -p /boot/dtbs-$name/qcom && install -m 644 /tmp/te-dtb /boot/dtbs-$name/qcom/$dtbname
tar xzf /tmp/te-mods.tgz -C / && depmod -a $release
options=\$(sed -n 's/^options //p' /boot/loader/entries/pmos.conf)
cat > /boot/loader/entries/pmos-$name.conf <<ENTRY
title postmarketOS (test kernel: $name)
sort-key zz-test-$name
linux vmlinuz-$name
initrd initramfs
devicetree dtbs-$name/qcom/$dtbname
options \$options
ENTRY
rm -f /tmp/te-vmlinuz /tmp/te-dtb /tmp/te-mods.tgz
echo "installed: entry pmos-$name.conf, kernel $release, \$(find /lib/modules/$release -name '*.ko*' | wc -l) modules"
CMDS
	;;
boot-once)
	phone_root <<CMDS
set -e
[ -f /boot/loader/entries/pmos-$name.conf ] || { echo "no entry pmos-$name.conf: install it first" >&2; exit 1; }
L=/boot/loader/loader.conf
if [ -f \$L ]; then cp \$L \$L.before-test; else touch \$L.none-before-test; fi
printf 'default pmos-$name.conf\\ntimeout 5\\n' > \$L
cat > /usr/local/sbin/test-entry-restore <<'RESTORE'
#!/bin/sh
# after a test kernel's one boot: the stock entry the default again
L=/boot/loader/loader.conf
if [ -f \$L.before-test ]; then mv \$L.before-test \$L; elif [ -f \$L.none-before-test ]; then rm -f \$L \$L.none-before-test; fi
RESTORE
chmod 755 /usr/local/sbin/test-entry-restore
cat > /etc/systemd/system/test-entry-restore.service <<'UNIT'
[Unit]
Description=Make the stock kernel the default boot entry again after a test kernel's one boot
RequiresMountsFor=/boot
[Service]
Type=oneshot
ExecStart=/usr/local/sbin/test-entry-restore
[Install]
WantedBy=multi-user.target
UNIT
systemctl enable -q test-entry-restore.service
sync
systemd-run --on-active=2 systemctl reboot >/dev/null
echo "rebooting into pmos-$name.conf once"
CMDS
	;;
remove)
	phone_root <<CMDS
set -e
release=\$(ls /lib/modules | grep -- "-$name\$" || true)
rm -f /boot/loader/entries/pmos-$name.conf /boot/vmlinuz-$name
rm -rf /boot/dtbs-$name
[ -z "\$release" ] || rm -rf "/lib/modules/\$release"
echo "removed: pmos-$name.conf\${release:+ and the modules of \$release}"
CMDS
	;;
*) usage ;;
esac
