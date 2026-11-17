#!/bin/sh
d=/var/tmp/sleep-cycle; rm -rf $d; mkdir -p $d
t=/sys/kernel/tracing
echo 0 > $t/tracing_on; echo nop > $t/current_tracer; echo > $t/trace; echo 16384 > $t/buffer_size_kb
for e in irq/irq_handler_entry power/suspend_resume power/wakeup_source_activate; do echo 1 > $t/events/$e/enable; done
printf '%s\n' pm_system_wakeup s2idle_wake pm_wakeup_pending pm_wakeup_dev_event __pm_stay_awake pm_system_irqwake irq_pm_check_wakeup s2idle_enter s2idle_loop > $t/set_ftrace_filter 2>$d/filter.err
echo function > $t/current_tracer; echo 1 > $t/options/func_stack_trace 2>/dev/null
for l in $(cat /sys/power/wake_lock); do echo $l > /sys/power/wake_unlock; done
u=/sys/class/udc/a600000.usb/soft_connect
echo disconnect > $u
echo 1 > $t/tracing_on
rtcwake -m freeze -s 60 > $d/rtcwake.out 2>&1
echo 0 > $t/tracing_on
echo connect > $u
cp $t/trace $d/trace
echo 0 > $t/options/func_stack_trace; echo nop > $t/current_tracer
for e in irq/irq_handler_entry power/suspend_resume power/wakeup_source_activate; do echo 0 > $t/events/$e/enable; done
echo > $t/set_ftrace_filter
sleep 3; echo done > $d/done
