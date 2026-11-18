# Read-only checks of running things on daily-usable-phone's steps: the battery gauge reads, the thermal
# zones give sane temperatures, a charger supply is there.
# Nothing is changed. Each pass proves "present and answering" only, not that the part works end to end.
. /usr/lib/lpoco-health/lib.sh
ps=/sys/class/power_supply
bat=$(for d in $ps/*; do [ "$(cat $d/type 2>/dev/null)" = Battery ] && echo "$d" && break; done)
cap=$(cat "$bat/capacity" 2>/dev/null)
check battery-gauge power "$([ -n "$cap" ] && [ "$cap" -ge 0 ] && [ "$cap" -le 100 ] && echo true)" \
	"${bat##*/}: capacity ${cap:-unreadable} % (0..100), status $(cat "$bat/status" 2>/dev/null)"
chg=$(for d in $ps/*; do [ "$(cat $d/type 2>/dev/null)" = USB ] && [ -r "$d/online" ] && echo "${d##*/}=$(cat $d/online)"; done | tr '\n' ' ')
check charger-online power "$([ -n "$chg" ] && echo true)" "USB supplies with an online flag (online is 1 when plugged in): ${chg:-none}"
bad=$(for z in /sys/class/thermal/thermal_zone*; do t=$(cat $z/temp 2>/dev/null); { [ -n "$t" ] && [ "$t" -gt -20000 ] && [ "$t" -lt 100000 ]; } || echo "$(cat $z/type):${t:-unreadable}"; done)
n=$(ls -d /sys/class/thermal/thermal_zone* 2>/dev/null | wc -l)
check thermal-zones power "$([ "$n" -gt 0 ] && [ -z "$bad" ] && echo true)" "$n zones, each -20..100 C; outside or unreadable: ${bad:-none}"
