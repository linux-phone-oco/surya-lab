#!/bin/sh
# Provision a freshly flashed phone: install provision/packages.txt over the PC's internet connection
# (the phone has none of its own until Wi-Fi is set up). The PC shares it only for the install:
# forwarding, a masquerade rule in a table of its own, and - with ufw active - a ufw route rule from
# the USB link to the uplink; all undone on exit, also on failure.
#   provision/provision.sh            environment: PHONE (user@172.16.42.1), PHONE_PASS (147147)
set -eu
P=${PHONE:-user@172.16.42.1}; export SSHPASS=${PHONE_PASS:-147147}
O="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=6"
s() { sshpass -e ssh $O "$P" "echo $SSHPASS | sudo -S -p '' sh -c '$*'"; }
R="sudo -n lab-agent root-exec --"
D=$(cd "$(dirname "$0")" && pwd)
PKGS=$(grep -vE '^[[:space:]]*(#|$)' "$D/packages.txt" | tr '\n' ' ')
UP=$(ip route show default | awk '{print $5; exit}')
gw=$(ip route show default | awk '{print $3; exit}')   # the PC's router answers DNS on a home network
usb=$(ip -o -4 addr | awk '$4 ~ /^172\.16\.42\.2\// {print $2}')
pc=$(ip -o -4 addr | awk '$4 ~ /^172\.16\.42\.2\// {print $4}' | cut -d/ -f1)
# ufw drops forwarded traffic by default: a route rule for the install, deleted on exit
ufw=$($R ufw status 2>/dev/null | grep -q 'Status: active' && echo yes || true)
[ -n "$UP" ] && [ -n "$pc" ] || { echo "no uplink or no USB link to the phone" >&2; exit 2; }
was=$(cat /proc/sys/net/ipv4/ip_forward)
cleanup() {
  s "ip route del default via $pc 2>/dev/null; [ -f /tmp/resolv.conf.provision ] && cat /tmp/resolv.conf.provision > /etc/resolv.conf; true" || true
  $R nft delete table ip surya-provision 2>/dev/null || true
  [ "$was" = 1 ] || $R sysctl -qw net.ipv4.ip_forward=0
  [ -z "$ufw" ] || $R ufw route delete allow in on "$usb" out on "$UP" >/dev/null 2>&1 || true
}
trap cleanup EXIT
$R sysctl -qw net.ipv4.ip_forward=1
[ -z "$ufw" ] || $R ufw route allow in on "$usb" out on "$UP" >/dev/null
$R nft add table ip surya-provision
$R nft add chain ip surya-provision out '{ type nat hook postrouting priority 100; }'
$R nft add rule ip surya-provision out ip saddr 172.16.42.0/24 oifname "$UP" masquerade
s "ip route add default via $pc"
# names through the PC's router for the install: the phone's own servers may not be reachable from here
s "cp /etc/resolv.conf /tmp/resolv.conf.provision; echo nameserver $gw > /etc/resolv.conf"
s "ping -c1 -W3 1.1.1.1 >/dev/null" || { echo "the phone cannot reach the internet through the PC" >&2; exit 1; }
echo "installing: $PKGS"
s "apk update -q && apk add -q $PKGS"   # a fresh image has no package index yet
echo "installed: $(sshpass -e ssh $O "$P" "apk info -e $PKGS" | tr '\n' ' ')"
