# Bluetooth survives suspend (backlog bt-suspend-proof): after any s2idle the QCA controller on
# serial@88c000 (hci0) is up and was never rescued - no irq 157 storm, no controller crash (SSR), no
# qca_suspend timeout, no rfkill stuck on the misc_open mutex. Reads only; the cycles that make it
# meaningful are way-back.sh cycle 15 bt-on (the keeper's), and the wakeup switch left ON.
. /usr/lib/lpoco-health/lib.sh
log="$(dmesg 2>/dev/null)"
n=$(printf '%s\n' "$log" | grep -c "irq 157: nobody cared")
check bt-no-irq-storm bluetooth "$([ "$n" = 0 ] && echo true)" "irq 157 'nobody cared' $n time(s) since boot"
n=$(printf '%s\n' "$log" | grep -cE "SSR or FW download time out|qca_suspend|hci0: .*(timeout|crash)|Frame reassembly failed|Bluetooth: hci0: command .* tx timeout")
check bt-no-controller-crash bluetooth "$([ "$n" = 0 ] && echo true)" "controller crash or qca_suspend timeout lines: $n"
check bt-hci0-up bluetooth "$(hciconfig hci0 2>/dev/null | grep -q 'UP RUNNING' && echo true)" "$(hciconfig hci0 2>&1 | sed -n 2p)"
d=$(ps -eo stat,comm | awk '$1 ~ /^D/ && $2 == "rfkill"' | wc -l)
check bt-rfkill-not-stuck bluetooth "$([ "$d" = 0 ] && echo true)" "rfkill processes in D state: $d"
w=$(cat /sys/bus/platform/devices/88c000.serial/power/wakeup 2>/dev/null)
check bt-serial-wakeup-on bluetooth "$([ "$w" = enabled ] && echo true)" "88c000.serial power/wakeup: ${w:-unread} (the way-back test switch must not be left off)"
