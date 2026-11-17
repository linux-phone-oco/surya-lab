#!/bin/sh
# standby-run.sh RUNID [SETTLE_S [MEASURE_S]] - the standby-current run, ON the phone, off USB (decision
# 2026-11-17-standby-drain-test): short way-back.sh bt-on suspend cycles (the watchdog allows 15 s of sleep per cycle)
# in a loop, one sample line per cycle in /var/tmp/standby-RUNID/samples.tsv, ending by itself after SETTLE_S (default
# 600, samples marked settle) plus MEASURE_S (default 3600, marked measure). Start it as a transient unit:
#   systemd-run --unit=standby-RUNID sh /var/tmp/standby-run.sh RUNID
# Wi-Fi and Bluetooth stay on, screen off, SIM out. The fuel gauge (qcom_qg) has NO charge_counter: capacity is whole
# percent (1 % = 52 mAh, too coarse for 60 min at ~10 mA), so the figure is current_now/current_avg (cross-checked
# against voltage_ocv): charge_counter is logged as 'na'. Samples with the charger online are to be discarded.
# Armed first: with USB power present it waits (file ARMED), never cycles or scores; phase "usb" samples are never scored.
set -u
id=${1:?run id}; settle=${2:-600}; measure=${3:-4500}
d=/var/tmp/standby-$id; mkdir -p "$d"; t=$d/samples.tsv; c=$d/cycles.log
b=/sys/class/power_supply/qcom_qg; ch=/sys/class/power_supply/pm8150b-charger
rd() { cat "$1" 2>/dev/null || echo na; }
mono() { cut -d' ' -f1 /proc/uptime; }
{ echo "run $id started $(date -u +%FT%TZ) settle ${settle}s measure ${measure}s kernel $(uname -r)"
  echo "wifi: $(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | grep '^yes' | head -1); rfkill: $(rfkill list | tr '\n' ' ' | tr -s '\t ' ' ')"
  echo "modem: $(mmcli -m 0 2>&1 | grep -E 'state|failed reason|power state' | tr -s ' |' ' ' | tr '\n' ';')"
  echo "screen: $(cat /sys/class/backlight/*/brightness 2>/dev/null | tr '\n' ' ')"; } > "$d/header.txt"
printf 'mono_s\tphase\tbat_status\tcharger_online\tcurrent_now_uA\tcurrent_avg_uA\tcharge_counter\tcapacity\tvoltage_now_uV\tvoltage_ocv_uV\ttemp\tsuspends\tsuspended_s_cum\twake_events\n' > "$t"
# USB guard (r1 was invalid: the cable stayed in). While any USB source is online the run REFUSES to start
# scoring: it only waits ("ARMED" file, no suspend cycles, no samples) until the cable is out for 60 s (12 polls),
# at most ARM_S (default 1800) seconds, then ends with REFUSED. Samples with the charger online are marked phase
# 'usb' and are never scored (a re-plugged cable mid-run shows up so, not as standby).
usb_in() { for p in /sys/class/power_supply/*; do [ "$(rd $p/type)" = USB ] && [ "$(rd $p/online)" = 1 ] && return 0; done; return 1; }
arm=${ARM_S:-1800}
if usb_in; then
	echo "USB power is present since $(date -u +%FT%TZ): NOT scoring; waiting for the cable to be pulled (up to ${arm}s)" > "$d/ARMED"
	echo "REFUSED-TO-SCORE: USB power present at start $(date -u +%FT%TZ); scoring only after 60 s without it" >> "$d/header.txt"
	echo "standby-run $id: USB power present, refusing to score until it is pulled" | systemd-cat -p warning -t standby-run 2>/dev/null
	a0=$(mono); gone=0
	while [ "$gone" -lt 12 ]; do
		usb_in && gone=0 || gone=$((gone + 1))
		[ "$(awk -v a="$(mono)" -v b="$a0" 'BEGIN{printf "%d", a-b}')" -ge "$arm" ] && { echo "REFUSED: never unplugged - USB power still present after ${arm}s, nothing scored" > "$d/REFUSED"; exit 1; }
		sleep 5
	done
	echo "USB power gone at $(date -u +%FT%TZ): scoring starts" >> "$d/ARMED"
fi
bt_bad() { dmesg 2>/dev/null | grep -cE "Injecting HCI hardware error|Retry BT power ON|irq 157: nobody cared|tasks refusing to freeze"; }
bt0=$(bt_bad); zero=0
t0=$(mono); asleep=0; fails=0
while :; do
	now=$(mono); el=$(awk -v a="$now" -v b="$t0" 'BEGIN{printf "%d", a-b}')
	[ "$el" -ge $((settle + measure)) ] && break
	ph=settle; [ "$el" -ge "$settle" ] && ph=measure
	usb_in && ph=usb
	# r2 (2026-11-17) was reset by its own 30 s fuse when Bluetooth (UART irq 157 disabled, QCA retry loop of ~70 s) stalled a cycle:
	# never start a cycle after Bluetooth has failed, nor after 4 cycles in a row that did not sleep; end honestly, unscored.
	[ "$(bt_bad)" -gt "$bt0" ] && { echo "stopped: Bluetooth failed (hci hardware error / irq 157 / freeze refused) at $(date -u +%FT%TZ), no more cycles: aborted, partial: samples before it count (charger_online 0 only)" > "$d/STOPPED"; break; }
	[ "$zero" -ge 4 ] && { echo "stopped: 4 cycles in a row did not sleep at $(date -u +%FT%TZ): aborted, partial: samples before it count (charger_online 0 only)" > "$d/STOPPED"; break; }
	printf '%s\t%s\t%s\t%s\t%s\t%s\tna\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$now" "$ph" "$(rd $b/status)" "$(rd $ch/online)" "$(rd $b/current_now)" "$(rd $b/current_avg)" \
		"$(rd $b/capacity)" "$(rd $b/voltage_now)" "$(rd $b/voltage_ocv)" "$(rd $b/temp)" "$(rd /sys/power/suspend_stats/success)" "$asleep" \
		"$(awk 'NR>1{s+=$3}END{print s+0}' /sys/kernel/debug/wakeup_sources 2>/dev/null)" >> "$t"
	out=$(sh /var/tmp/way-back.sh cycle 15 bt-on 2>&1); rc=$?
	{ echo "== $now rc=$rc"; echo "$out"; } >> "$c"
	s=$(echo "$out" | sed -n 's/.*asleep (RTC) \([0-9]*\) s.*/\1/p'); asleep=$((asleep + ${s:-0}))
	[ "${s:-0}" -gt 0 ] && zero=0 || zero=$((zero + 1))
	if [ "$rc" != 0 ]; then fails=$((fails + 1)); sleep 5; [ "$fails" -ge 10 ] && { echo "stopped: 10 failed cycles" > "$d/STOPPED"; break; }; fi
	sleep 2
done
printf V > /dev/watchdog0 2>/dev/null; echo 0 > /sys/module/qcom_wdt/parameters/keep_armed_in_suspend 2>/dev/null
if grep -q "Bluetooth failed" "$d/STOPPED" 2>/dev/null; then
	# decision 2026-11-17-r4-quiets-irq-157-and-stops-bluetooth-retries: no QCA retry loop left behind
	systemctl stop bluetooth.service 2>/dev/null; rfkill block bluetooth; echo "bluetooth stopped and blocked at $(date -u +%FT%TZ)" >> "$d/STOPPED"
else rfkill unblock bluetooth; fi
echo "ended $(date -u +%FT%TZ) after $(awk -v a="$(mono)" -v b="$t0" 'BEGIN{printf "%d", a-b}') s, asleep (RTC) ${asleep} s, failed cycles ${fails}" > "$d/DONE"
