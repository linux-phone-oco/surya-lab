#!/bin/sh
# Who arms irq 157 for wake? ftrace of irq_set_irq_wake with call stacks across ONE short s2idle cycle,
# Bluetooth left ON, the watchdog fused 30 s and defused on return (way-back.sh does the arming).
# Run on the phone as a transient unit: systemd-run --unit=NAME sh /var/tmp/arm-trace.sh
d=/var/tmp/sleep-cycle; rm -rf $d; mkdir -p $d
t=/sys/kernel/tracing; wb="sh /var/tmp/way-back.sh"
echo 0 > $t/tracing_on; echo nop > $t/current_tracer; echo > $t/trace; echo 8192 > $t/buffer_size_kb
printf "%s\n" irq_set_irq_wake pm_system_wakeup s2idle_wake pm_wakeup_pending pm_system_irq_wakeup irq_pm_check_wakeup irq_pm_handle_wakeup s2idle_enter > $t/set_ftrace_filter 2>$d/filter.err
for e in irq/irq_handler_entry power/suspend_resume power/wakeup_source_activate; do echo 1 > $t/events/$e/enable; done
echo 'p:wkirq pm_system_irq_wakeup irq=%x0:u32' > $t/kprobe_events; echo 1 > $t/events/kprobes/wkirq/enable
cp /proc/interrupts $d/irq-before
echo function > $t/current_tracer; echo 1 > $t/options/func_stack_trace
echo 1 > /sys/module/qcom_wdt/parameters/keep_armed_in_suspend
watchdog -F -T 30 -t 2 /dev/watchdog0 & p=$!; sleep 3; kill -9 $p; wait $p 2>/dev/null
u=/sys/class/udc/a600000.usb/soft_connect; [ -w $u ] && echo disconnect > $u
echo 1 > $t/tracing_on
rtcwake -m freeze -s 8 > $d/rtcwake.out 2>&1
echo 0 > $t/tracing_on
printf V > /dev/watchdog0; echo 0 > /sys/module/qcom_wdt/parameters/keep_armed_in_suspend
[ -w $u ] && echo connect > $u
cp $t/trace $d/trace; cp /proc/interrupts $d/irq-after; echo 0 > $t/events/kprobes/wkirq/enable; echo > $t/kprobe_events
echo 0 > $t/options/func_stack_trace; echo nop > $t/current_tracer; echo > $t/set_ftrace_filter
for e in irq/irq_handler_entry power/suspend_resume power/wakeup_source_activate; do echo 0 > $t/events/$e/enable; done
dmesg | tail -60 > $d/dmesg-tail
echo done > $d/done
