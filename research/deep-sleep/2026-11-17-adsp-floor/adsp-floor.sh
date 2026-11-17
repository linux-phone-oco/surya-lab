#!/bin/sh
# adsp-floor.sh OUTDIR [stop] - ON the phone, as a systemd-run unit (never the debug shell): one measured cycle,
# with the audio DSP's remoteproc stopped for it when `stop` is given (the floor test: do cxsd/aosd move at all
# without the DSP?); `stopall` stops adsp, cdsp and modem (is anything remote the blocker?). Writes summaries before (awake, USB gadget connected), the cycle's own output, summaries
# after, and starts the DSP again. The watchdog fuse (30 s) covers the stop step.
set -u
out=${1:?outdir}; mode=${2:-keep}; D=/sys/kernel/debug; rp=/sys/class/remoteproc/remoteproc0
mkdir -p "$out"
snap() { # name
	{ for s in cxsd aosd ddr adsp cdsp modem; do echo "$s $(tr '\n' ' ' < $D/qcom_stats/$s)"; done; } > "$out/$1.stats"
	cat $D/pm_genpd/pm_genpd_summary > "$out/$1.genpd"; cat $D/interconnect/interconnect_summary > "$out/$1.icc"
	cat $D/regulator/regulator_summary > "$out/$1.reg"; awk 'NR<=3||$2>0' $D/clk/clk_summary > "$out/$1.clk"
	cat $rp/state > "$out/$1.rproc"
}
snap before
if [ "$mode" = stop ] || [ "$mode" = stopall ]; then
	sh /var/tmp/way-back.sh fuse 30 > "$out/fuse.txt" 2>&1
	echo "adsp-floor: stopping adsp" > /dev/kmsg
	for n in 0 $( [ "$mode" = stopall ] && echo 1 2 ); do timeout 20 sh -c "echo stop > /sys/class/remoteproc/remoteproc$n/state"; echo "stop rproc$n rc $? $(cat /sys/class/remoteproc/remoteproc$n/state)" >> "$out/fuse.txt"; done
	sleep 2
	sh /var/tmp/way-back.sh defuse >> "$out/fuse.txt" 2>&1
	snap stopped
fi
sh /var/tmp/way-back.sh enable > /dev/null 2>&1
sh /var/tmp/way-back.sh cycle 15 bt-on > "$out/cycle.txt" 2>&1
snap after
if [ "$mode" != keep ]; then
	for n in 0 1 2; do echo start > /sys/class/remoteproc/remoteproc$n/state; done; sleep 8; cat /sys/class/remoteproc/remoteproc*/state > "$out/restarted.rproc"
fi
dmesg | tail -150 > "$out/dmesg-tail.txt"
echo done > "$out/DONE"
