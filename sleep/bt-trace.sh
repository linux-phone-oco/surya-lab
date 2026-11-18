#!/bin/sh
# bt-trace.sh N SLEEP - STOPGAP PROBE, TO REMOVE once lpoco-health suspend cycle has a trace hook (backlog item
# lpoco-health-suspend-trace-hook, needs=build). Run ON the phone (devlab phone put, then as root).
# Decision 2026-11-18-bt-suspend-way step 1: N bt-on s2idle cycles of SLEEP s through way-back.sh (fuse, sensorspd
# stopped), with hci_qca/hci_ll dyndbg and irq trace of irq 157 (qcom_geni_serial_uart0) on, one log per cycle in
# /var/tmp/bt-trace/: read which comes first, the irq 157 storm or the controller crash.
set -u
n=${1:?N}; s=${2:-15}
t=/sys/kernel/tracing; d=/var/tmp/bt-trace; mkdir -p "$d"
dd=/sys/kernel/debug/dynamic_debug/control
echo 0 > $t/tracing_on; : > $t/trace
echo 'irq == 157' > $t/events/irq/irq_handler_entry/filter
echo 1 > $t/events/irq/irq_handler_entry/enable
echo "file drivers/bluetooth/hci_qca.c +p" > $dd; echo "file drivers/tty/serial/qcom_geni_serial.c +p" > $dd
systemctl stop sxmo_autosleep 2>/dev/null
i=1
while [ "$i" -le "$n" ]; do
	: > $t/trace; echo 1 > $t/tracing_on
	sh /var/tmp/way-back.sh cycle "$s" bt-on stop-sensors > "$d/cycle-$i.out" 2>&1; rc=$?
	echo 0 > $t/tracing_on
	cp $t/trace "$d/cycle-$i.trace"; dmesg | tail -150 > "$d/cycle-$i.dmesg"
	echo "cycle $i rc=$rc irq157 events=$(grep -c irq_handler "$d/cycle-$i.trace") hci0=$([ -e /sys/class/bluetooth/hci0 ] && echo up || echo GONE)"
	[ "$rc" = 0 ] && [ -e /sys/class/bluetooth/hci0 ] || { echo "stopping: cycle $i went wrong"; break; }
	i=$((i + 1)); sleep 5
done
echo 0 > $t/events/irq/irq_handler_entry/enable; echo > $t/events/irq/irq_handler_entry/filter
for f in drivers/bluetooth/hci_qca.c drivers/tty/serial/qcom_geni_serial.c; do echo "file $f -p" > $dd; done
