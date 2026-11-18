# A lab phone does not idle-suspend (backlog sxmo-autosleep-off-lasting): sxmo's autosuspend loop
# (sxmo_autosuspend.sh -> rtcwake -m mem) drops USB and Wi-Fi and the phone looks hung. It cannot
# suspend while the 'devlab-usb' kernel wake lock is held, and the service holding it must run.
# Reads only. 'works': the wake lock is held and its service active, or autosleep is deliberately allowed.
. /usr/lib/lpoco-health/lib.sh
if [ -e /etc/devlab-allow-autosleep ]; then
	grep -q bt_unsafe /usr/local/bin/devlab-usb-awake 2>/dev/null; check autosleep-bt-gate deep-sleep "$([ $? = 0 ] && echo true)" "devlab-usb-awake carries the bt gate"
	say autosleep-off deep-sleep skip "/etc/devlab-allow-autosleep present: idle suspend allowed on purpose"
	exit 0
fi
held=$(grep -qw devlab-usb /sys/power/wake_lock 2>/dev/null && echo true)
check autosleep-wakelock-held deep-sleep "$held" "wake lock devlab-usb in /sys/power/wake_lock: $(cat /sys/power/wake_lock 2>&1)"
act=$(systemctl is-active devlab-usb-awake.service 2>/dev/null)
check autosleep-service-active deep-sleep "$([ "$act" = active ] && echo true)" "devlab-usb-awake.service: ${act:-unknown}"
# The gate (backlog bt-suspend-gate): the awake script must hold the lock while Bluetooth is unsafe
# to suspend under, even where autosleep is allowed. Reads only: the installed script carries the gate.
grep -q bt_unsafe /usr/local/bin/devlab-usb-awake 2>/dev/null
check autosleep-bt-gate deep-sleep "$([ $? = 0 ] && echo true)" "devlab-usb-awake holds the wake lock while hci0 is not UP or an rfkill is stuck"
