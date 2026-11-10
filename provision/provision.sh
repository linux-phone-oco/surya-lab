#!/bin/sh
# Provision a freshly flashed phone: the packages in provision/packages.txt over the PC's internet
# connection (the phone has none of its own until Wi-Fi is set up), then the user's Wi-Fi.
#
# The PC shares its connection only for the install: forwarding, a masquerade rule in an nftables
# table of its own, and - with ufw active - a ufw route rule from the USB link to the uplink; the
# phone uses the PC's router for names. All of it is undone on exit, also on failure.
# Wi-Fi comes from private files on this PC, never from a repo: ~/.config/surya-lab/wifi-ssid and
# ~/.config/surya-lab/wifi-password (mode 600).
set -eu
# it changes the PC's networking and the phone: never on its own, only when asked by name
[ "${1:-}" = now ] || { echo "usage: provision/provision.sh now" >&2; exit 2; }
D=$(cd "$(dirname "$0")" && pwd)
. "$D/../lib/phone.sh"
PHONE=${PHONE:-user@172.16.42.1}; export PHONE   # sharing the PC's connection needs the USB link
phone_find
R="sudo -n lab-agent root-exec --"
PKGS=$(grep -vE '^[[:space:]]*(#|$)' "$D/packages.txt" | tr '\n' ' ')
UP=$(ip route show default | awk '{print $5; exit}')
gw=$(ip route show default | awk '{print $3; exit}')
usb=$(ip -o -4 addr | awk '$4 ~ /^172\.16\.42\.2\// {print $2}')
pc=$(ip -o -4 addr | awk '$4 ~ /^172\.16\.42\.2\// {print $4}' | cut -d/ -f1)
[ -n "$UP" ] && [ -n "$pc" ] || { echo "no uplink or no USB link to the phone" >&2; exit 2; }
ufw=$($R ufw status 2>/dev/null | grep -q 'Status: active' && echo yes || true)
was=$(cat /proc/sys/net/ipv4/ip_forward)
cleanup() {
	phone_root <<CMDS || true
ip route del default via $pc 2>/dev/null
[ -f /tmp/resolv.conf.provision ] && cat /tmp/resolv.conf.provision > /etc/resolv.conf && rm /tmp/resolv.conf.provision
true
CMDS
	$R nft delete table ip surya-provision 2>/dev/null || true
	[ -z "$ufw" ] || $R ufw route delete allow in on "$usb" out on "$UP" >/dev/null 2>&1 || true
	[ "$was" = 1 ] || $R sysctl -qw net.ipv4.ip_forward=0
}
trap cleanup EXIT
$R sysctl -qw net.ipv4.ip_forward=1
[ -z "$ufw" ] || $R ufw route allow in on "$usb" out on "$UP" >/dev/null
$R nft add table ip surya-provision
$R nft add chain ip surya-provision out '{ type nat hook postrouting priority 100; }'
$R nft add rule ip surya-provision out ip saddr 172.16.42.0/24 oifname "$UP" masquerade
phone_root <<CMDS
ip route add default via $pc
cp /etc/resolv.conf /tmp/resolv.conf.provision
echo nameserver $gw > /etc/resolv.conf
ping -c1 -W3 1.1.1.1 >/dev/null || { echo "the phone cannot reach the internet through the PC" >&2; exit 1; }
CMDS
echo "installing: $PKGS"
echo "apk update -q && apk add -q $PKGS" | phone_root
echo "installed: $(echo "apk info -e $PKGS" | phone_sh | tr '\n' ' ')"
# the Sxmo device profile for this phone, until sxmo-utils ships it (linux-phone-oco/sxmo-utils,
# branch deviceprofile/xiaomi-surya); only where Sxmo is installed and the profile is missing
SXMO=$HOME/Projects/linux-phone-oco/sxmo-utils/scripts/deviceprofiles
name=$(echo 'tr -c "\\0[:alnum:].,-" "_" < /proc/device-tree/compatible | tr "\\0" "\\n" | head -n1' | phone_sh)
if [ -f "$SXMO/sxmo_deviceprofile_$name.sh" ] && echo 'command -v sxmo_init.sh' | phone_sh >/dev/null; then
	phone_put "$SXMO/sxmo_deviceprofile_$name.sh" /tmp/profile.sh
	echo "install -m 755 /tmp/profile.sh /usr/bin/sxmo_deviceprofile_$name.sh" | phone_root
	echo "sxmo profile: $name"
fi
W=$HOME/.config/surya-lab
if [ -f "$W/wifi-ssid" ] && [ -f "$W/wifi-password" ]; then
	phone_put "$W/wifi-password" /tmp/.wifi-pw
	ssid=$(cat "$W/wifi-ssid")
	phone_root <<CMDS >/dev/null 2>&1 || true
chmod 600 /tmp/.wifi-pw
nmcli dev wifi connect "$ssid" password "\$(cat /tmp/.wifi-pw)"
rm -f /tmp/.wifi-pw
CMDS
	addr=$(echo 'ip -4 addr show wlan0 | grep -o "inet [0-9.]*" | cut -d" " -f2' | phone_sh)
	[ -n "$addr" ] && { (umask 077; echo "$addr" > "$W/phone-wifi-address"); echo "wifi: $addr"; }
fi
