#!/bin/sh
# one controlled s2idle cycle, results to /var/tmp/sleep-cycle/
d=/var/tmp/sleep-cycle; rm -rf $d; mkdir -p $d
snap() { o=$d/$1
 { echo "== qcom_stats"; for f in /sys/kernel/debug/qcom_stats/*; do printf '%s ' "$(basename $f)"; awk '/^Count:/{print $2; exit}' $f; done
   echo "== suspend_stats"; for f in /sys/power/suspend_stats/*; do [ -f $f ] && printf '%s=%s\n' "$(basename $f)" "$(cat $f 2>/dev/null)"; done
   echo "== wake_lock"; cat /sys/power/wake_lock
   echo "== wakeup_sources"; awk 'NR>1{print $1,$2,$4}' /sys/kernel/debug/wakeup_sources 2>/dev/null
   echo "== genpd"; grep -H . /sys/kernel/debug/pm_genpd/*cluster*/idle_states /sys/kernel/debug/pm_genpd/*cluster*/current_state 2>/dev/null
 } > $o 2>&1; }
echo 1 > /sys/power/pm_debug_messages; cp /proc/interrupts $d/irq-before; cat /sys/class/rtc/rtc0/since_epoch > $d/rtc0
cp /sys/kernel/debug/wakeup_sources $d/ws-before; snap before
for l in $(cat /sys/power/wake_lock); do echo $l > /sys/power/wake_unlock; done
u=/sys/class/udc/a600000.usb/soft_connect
echo disconnect > $u
date +%s > $d/t0
rtcwake -m freeze -s 60 > $d/rtcwake.out 2>&1
date +%s > $d/t1
echo connect > $u
sleep 5
cat /sys/class/rtc/rtc0/since_epoch > $d/rtc1; cp /proc/interrupts $d/irq-after; dmesg | tail -60 > $d/dmesg-tail; echo 0 > /sys/power/pm_debug_messages
cp /sys/kernel/debug/wakeup_sources $d/ws-after; snap after
echo done > $d/done
