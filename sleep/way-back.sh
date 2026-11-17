#!/bin/sh
# way-back.sh VERB - surya's way back from a suspend that may not return, run ON the phone (put it there with
# `devlab phone put`, run it as a transient unit: systemd-run --unit=NAME sh /var/tmp/way-back.sh VERB ...).
# Decision 2026-11-17-deep-sleep-way-back: the way back is the SoC watchdog (qcom_wdt, 17c10000.watchdog) kept
# armed through sleep - the stock driver stops it in the late suspend phase, so a module built from the kernel's
# own source with one parameter (patches/qcom-wdt-keep-armed-in-suspend.patch, sleep/build-wdt.sh) stands in
# updates/ and acts like the stock one until `enable` - plus a log that survives (ramoops/pstore, read back by
# `collect`). The PMIC RTC cannot be set (no allow-set-time: it reads 1970, its alarms work relative to it).
#
# Verbs (no verb: this text, nothing changed):
#   check             read only: the watchdog, the RTC ticking, ramoops, pstore, the module's parameter; exit 1 if one fails
#   install KO        put the patched module KO into updates/ and depmod: the next boot loads it
#   enable            keep_armed_in_suspend=1 until the next boot (disable: 0)
#   disable
#   fuse SECONDS      (10 to 30: the qcom watchdog counts 32 s at most) arm the watchdog for SECONDS and let go of it unpetted: the phone resets in SECONDS, whatever it
#                     is doing - the dry run, nothing suspends. A marker goes to the kernel log first
#   defuse            stop an armed watchdog by the magic close
#   collect DIR       copy what pstore kept (the last boot's console and panic log) into DIR, then clear it
#   cycle SLEEP [probe]
#                     ONE s2idle cycle with Bluetooth blocked (its UART is the wake source that ended s2idle at once):
#                     fuse 30 s, rtcwake -m freeze -s SLEEP (5 to 15: the fuse is the watchdog's longest), defuse and
#                     unblock on return; refuses unless `check` passes and the patched parameter is there. With `probe`
#                     Bluetooth stays on (s2idle ends in 2 s) and the fuse is NOT defused: the phone must reset 30 s
#                     after arming - the proof that the watchdog lives through a real suspend entry
set -eu
wd=/dev/watchdog0
param=/sys/module/qcom_wdt/parameters/keep_armed_in_suspend
say() { printf '%s\n' "$*"; }
usage() { sed -n '2,/^set -eu/p' "$0" | sed '$d;s/^# \{0,1\}//'; }
need() { [ "$1" -ge "$2" ] 2>/dev/null || { say "way-back: $3" >&2; exit 2; }; }

do_check() {
	bad=0
	[ -c "$wd" ] && say "ok   watchdog $wd" || { say "FAIL no $wd"; bad=1; }
	a=$(cat /sys/class/rtc/rtc0/since_epoch 2>/dev/null || echo 0); sleep 2; b=$(cat /sys/class/rtc/rtc0/since_epoch 2>/dev/null || echo 0)
	[ "$b" -gt "$a" ] && say "ok   RTC ticks ($(cat /sys/class/rtc/rtc0/date), reads from 1970: it cannot be set)" || { say "FAIL RTC does not tick"; bad=1; }
	[ -d /sys/module/ramoops ] && say "ok   ramoops $(cat /sys/module/ramoops/parameters/mem_size) bytes at $(cat /sys/module/ramoops/parameters/mem_address)" || { say "FAIL no ramoops"; bad=1; }
	[ -d /sys/fs/pstore ] && say "ok   pstore mounted: $(ls /sys/fs/pstore | wc -l) record(s) from before" || { say "FAIL no /sys/fs/pstore"; bad=1; }
	if [ -f "$param" ]; then say "ok   patched qcom_wdt: keep_armed_in_suspend=$(cat $param)"; else say "note qcom_wdt is the stock module: it stops the watchdog in suspend (install KO, reboot)"; fi
	command -v rtcwake >/dev/null && command -v watchdog >/dev/null || { say "FAIL rtcwake or watchdog missing"; bad=1; }
	[ "$bad" = 0 ]
}
# BusyBox's watchdog sets the timeout and is then killed hard: no magic close, so the device stays armed unpetted
arm_and_release() {
	watchdog -F -T "$1" -t 2 "$wd" &
	p=$!; sleep 3; kill -9 "$p"; wait "$p" 2>/dev/null || true
}

case ${1:-} in
	check) do_check ;;
	install) [ -f "${2:-}" ] || { say "way-back: install needs the module file" >&2; exit 2; }
		d=/lib/modules/$(uname -r)/updates; mkdir -p "$d"; cp "$2" "$d/qcom-wdt.ko"; depmod
		say "installed: $(modinfo -n qcom_wdt) (the next boot loads it)" ;;
	enable) [ -f "$param" ] || { say "way-back: the stock module: no parameter (install KO, reboot)" >&2; exit 1; }
		echo 1 > "$param"; say "keep_armed_in_suspend=$(cat $param)" ;;
	disable) echo 0 > "$param"; say "keep_armed_in_suspend=$(cat $param)" ;;
	fuse) need "${2:-0}" 10 "fuse needs SECONDS >= 10" ; need 30 "${2:-0}" "fuse needs SECONDS <= 30 (the watchdog counts 32 s at most)"
		say "way-back: marker before the fuse of $2 s" > /dev/kmsg; sync
		arm_and_release "$2"; say "armed: the phone resets in about $2 s unless defused" ;;
	defuse) printf V > "$wd"; say "watchdog stopped" ;;
	collect) [ -n "${2:-}" ] || { say "way-back: collect needs a directory" >&2; exit 2; }
		mkdir -p "$2"; n=0; for f in /sys/fs/pstore/*; do [ -f "$f" ] || continue; cp "$f" "$2/"; rm -f "$f"; n=$((n + 1)); done
		say "collected $n pstore record(s) into $2" ;;
	cycle) need "${2:-0}" 5 "cycle needs SLEEP >= 5"; need 15 "${2:-0}" "cycle needs SLEEP <= 15 (the fuse is 30 s)"
		do_check >/dev/null || { do_check || true; say "way-back: the way back is not in place" >&2; exit 1; }
		[ -f "$param" ] || { say "way-back: the stock qcom_wdt stops the watchdog in suspend: install the patched module first" >&2; exit 1; }
		echo 1 > "$param"; sync
		[ "${3:-}" = probe ] || rfkill block bluetooth
		say "way-back: cycle: sleep $2 s, fuse 30 s${3:+, $3}" > /dev/kmsg; sync
		arm_and_release 30
		u=/sys/class/udc/a600000.usb/soft_connect   # as in the first cycles: the gadget let go, then back
		[ -w "$u" ] && echo disconnect > "$u"
		rtcwake -m freeze -s "$2" || say "rtcwake returned $?"
		[ -w "$u" ] && echo connect > "$u"
		if [ "${3:-}" = probe ]; then say "back from the suspend; the fuse stays lit: the phone resets about 30 s after arming"; else
			printf V > "$wd"; echo 0 > "$param"; rfkill unblock bluetooth; say "back: watchdog stopped; RTC $(cat /sys/class/rtc/rtc0/since_epoch)"; fi ;;
	*) usage ;;
esac
