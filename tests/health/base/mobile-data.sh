# mobile data carries traffic: over the modem's own interface (not Wi-Fi), three pings to 1.1.1.1 and a
# 100 kB download. Skipped without a SIM or registration - what nobody can measure is not broken. About
# 100 kB a boot, within the 3 GB the author gave for tests.
. /usr/lib/devlab/health/lib.sh
command -v mmcli >/dev/null || { say mobile-data modem-data skip "no ModemManager"; exit 0; }
state=$(mmcli -m any 2>/dev/null | awk -F': ' '/ state:/{gsub(/\033\[[0-9;]*m/,"",$2); print $2; exit}')
case $state in
	registered|connected|connecting) ;;
	*) say mobile-data modem-data skip "modem state ${state:-unknown}: no registration to carry data"; exit 0 ;;
esac
dev=$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="gsm"{print $1; exit}')
iface=$(nmcli -g GENERAL.IP-IFACE device show "$dev" 2>/dev/null)
if [ -z "$iface" ]; then
	nmcli c up mobile >/dev/null 2>&1; sleep 3
	iface=$(nmcli -g GENERAL.IP-IFACE device show "$dev" 2>/dev/null)
fi
[ -n "$iface" ] || { say mobile-data modem-data fail "registered ($state), but no data interface: the mobile connection did not come up"; exit 0; }
got=$(ping -c3 -W3 -I "$iface" 1.1.1.1 2>/dev/null | awk '/packets received/{print $4}')
dl=$(curl -s -o /dev/null --max-time 20 --interface "$iface" -w "%{size_download} %{speed_download}" "https://speed.cloudflare.com/__down?bytes=100000")
set -- $dl
check mobile-data modem-data "$([ "${got:-0}" -ge 2 ] && [ "${1:-0}" -ge 100000 ] && echo true)" \
	"over $iface ($state): ${got:-0} of 3 pings answered, ${1:-0} bytes downloaded at ${2:-0} B/s"
