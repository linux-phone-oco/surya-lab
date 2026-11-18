# A hung resume has a way back (backlog resume-stall-way-back, decision 2026-11-18-resume-stall-way):
# the stall seen after the 12:57 resume (CPU1 stuck, other CPUs alive, qcom_wdt pretimeout but no bite) is
# turned into a panic and a reboot by sysctl alone, and the panic is kept by ramoops. Reads only.
. /usr/lib/lpoco-health/lib.sh
p=$(cat /proc/sys/kernel/panic_on_rcu_stall 2>/dev/null)
check way-back-panic-on-rcu-stall sleep "$([ "$p" = 1 ] && echo true)" "kernel.panic_on_rcu_stall=${p:-unread} (must be 1: a stalled CPU1 ends in a panic, not minutes of silence)"
k=$(cat /proc/sys/kernel/panic 2>/dev/null)
check way-back-panic-reboots-soon sleep "$([ -n "$k" ] && [ "$k" -ge 1 ] && [ "$k" -le 10 ] && echo true)" "kernel.panic=${k:-unread} s (1..10: the panic reboots by itself; 120 is no way back)"
r=$(ls /sys/fs/pstore 2>/dev/null | wc -l); m=$(ls -d /sys/bus/platform/devices/*.ramoops 2>/dev/null | wc -l)
check way-back-ramoops-present sleep "$([ "$m" -ge 1 ] && echo true)" "ramoops platform device bound (the region shows in /proc/iomem only as 'reserved'): $m; pstore files now: $r"
# the fuse's node is the APSS watchdog by what it is (parent 17c10000.watchdog), never the PMIC watchdog by number
a=""; for w in /sys/class/watchdog/watchdog*; do case "$(readlink -f "$w/device" 2>/dev/null)" in */17c10000.watchdog) a=${w##*/} ;; esac; done
check way-back-apss-watchdog-by-identity sleep "$([ -n "$a" ] && [ -c "/dev/$a" ] && echo true)" "qcom_wdt (17c10000.watchdog) is /dev/${a:-none}; way-back.sh picks it by that, not by number (the PMIC watchdog may be watchdog0)"
