#!/bin/sh
# A test kernel beside the stock one: a second systemd-boot entry, pmos-NAME.conf, with its own
# kernel, device tree and modules (its own version, so nothing of the stock kernel is touched); the
# stock initramfs is reused - storage, filesystem and display are built in, it needs no modules to
# reach the root. The stock entry stays the default.
#
#   kernel/test-entry.sh install NAME VMLINUZ DTB MODULES.tgz   (MODULES.tgz holds lib/modules/RELEASE)
#   kernel/test-entry.sh remove NAME
set -eu
D=$(cd "$(dirname "$0")" && pwd)
usage() { echo "usage: kernel/test-entry.sh install NAME VMLINUZ DTB MODULES.tgz | remove NAME" >&2; exit 2; }
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
