#!/bin/sh
# standby-run.sh RUNID [SETTLE_S [MEASURE_S]] - the standby-current run, ON the phone, off USB (decision
# 2026-11-17-standby-drain-test): short way-back.sh bt-on suspend cycles (the watchdog allows 15 s of sleep per cycle)
# in a loop, one sample line per cycle in /var/tmp/standby-RUNID/samples.tsv, ending by itself after SETTLE_S (default
# 600, samples marked settle) plus MEASURE_S (default 3600, marked measure). Start it as a transient unit:
#   systemd-run --unit=standby-RUNID sh /var/tmp/standby-run.sh RUNID
# Wi-Fi and Bluetooth stay on, screen off, SIM out. The fuel gauge (qcom_qg) has NO charge_counter: capacity is whole
# percent (1 % = 52 mAh, too coarse for 60 min at ~10 mA), so the figure is current_now/current_avg (cross-checked
# against voltage_ocv): charge_counter is logged as 'na'. Samples with the charger online are to be discarded.
set -u
id=${1:?run id}; settle=${2:-600}; measure=${3:-3600}
d=/var/tmp/standby-$id; mkdir -p "$d"; t=$d/samples.tsv; c=$d/cycles.log
b=/sys/class/power_supply/qcom_qg; ch=/sys/class/power_supply/pm8150b-charger
rd() { cat "$1" 2>/dev/null || echo na; }
mono() { cut -d' ' -f1 /proc/uptime; }
{ echo "run $id started $(date -u +%FT%TZ) settle ${settle}s measure ${measure}s kernel $(uname -r)"
  echo "wifi: $(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | grep '^yes' | head -1); rfkill: $(rfkill list | tr '\n' ' ' | tr -s '\t ' ' ')"
  echo "modem: $(mmcli -m 0 2>&1 | grep -E 'state|failed reason|power state' | tr -s ' |' ' ' | tr '\n' ';')"
  echo "screen: $(cat /sys/class/backlight/*/brightness 2>/dev/null | tr '\n' ' ')"; } > "$d/header.txt"
printf 'mono_s\tphase\tbat_status\tcharger_online\tcurrent_now_uA\tcurrent_avg_uA\tcharge_counter\tcapacity\tvoltage_now_uV\tvoltage_ocv_uV\ttemp\tsuspends\tsuspended_s_cum\twake_events\n' > "$t"
t0=$(mono); asleep=0; fails=0
while :; do
	now=$(mono); el=$(awk -v a="$now" -v b="$t0" 'BEGIN{printf "%d", a-b}')
	[ "$el" -ge $((settle + measure)) ] && break
	ph=settle; [ "$el" -ge "$settle" ] && ph=measure
	printf '%s\t%s\t%s\t%s\t%s\t%s\tna\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$now" "$ph" "$(rd $b/status)" "$(rd $ch/online)" "$(rd $b/current_now)" "$(rd $b/current_avg)" \
		"$(rd $b/capacity)" "$(rd $b/voltage_now)" "$(rd $b/voltage_ocv)" "$(rd $b/temp)" "$(rd /sys/power/suspend_stats/success)" "$asleep" \
		"$(awk 'NR>1{s+=$3}END{print s+0}' /sys/kernel/debug/wakeup_sources 2>/dev/null)" >> "$t"
	out=$(sh /var/tmp/way-back.sh cycle 15 bt-on 2>&1); rc=$?
	{ echo "== $now rc=$rc"; echo "$out"; } >> "$c"
	s=$(echo "$out" | sed -n 's/.*asleep (RTC) \([0-9]*\) s.*/\1/p'); asleep=$((asleep + ${s:-0}))
	if [ "$rc" != 0 ]; then fails=$((fails + 1)); sleep 5; [ "$fails" -ge 10 ] && { echo "stopped: 10 failed cycles" > "$d/STOPPED"; break; }; fi
	sleep 2
done
printf V > /dev/watchdog0 2>/dev/null; echo 0 > /sys/module/qcom_wdt/parameters/keep_armed_in_suspend 2>/dev/null
rfkill unblock bluetooth
echo "ended $(date -u +%FT%TZ) after $(awk -v a="$(mono)" -v b="$t0" 'BEGIN{printf "%d", a-b}') s, asleep (RTC) ${asleep} s, failed cycles ${fails}" > "$d/DONE"
