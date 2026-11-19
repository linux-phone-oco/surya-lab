# Read-only checks of three more steps of daily-usable-phone: the buttons are input devices that can report keys,
# the RTC reads a sane time and offers an alarm, the SIM state is read. Nothing is changed.
# Each pass proves "present and answering" only: no key was pressed, no alarm was set, no wake was proven.
. /usr/lib/lpoco-health/lib.sh
have=""; miss=""
for n in pm8941_pwrkey pm8941_resin gpio-keys; do
	d=$(grep -l -x "$n" /sys/class/input/input*/name 2>/dev/null | head -1)
	if [ -n "$d" ] && [ -s "$(dirname "$d")/capabilities/key" ] && [ "$(tr -d '0 \n' < "$(dirname "$d")/capabilities/key")" != "" ]; then have="$have $n"; else miss="$miss $n"; fi
done
check buttons-report input "$([ -z "$miss" ] && echo true)" "key-capable input devices:${have:- none}; missing:${miss:- none} (no key pressed: the report of a press is not proven here)"
rtc=/sys/class/rtc/rtc0; y=$(date -d "@$(cat $rtc/since_epoch 2>/dev/null)" +%Y 2>/dev/null)
check rtc-alarm-present sleep "$([ -r $rtc/wakealarm ] && [ -n "$y" ] && echo true)" "$(cat $rtc/name 2>/dev/null): RTC date year ${y:-unreadable} (the time is kept by the shell, not by this RTC), wakealarm $([ -r $rtc/wakealarm ] && echo present || echo absent) (no alarm set; power-on by alarm is not proven)"
if no_sim || mmcli -m any 2>/dev/null | grep -q "sim-missing"; then say sim-ready modem-sim skip "no SIM card"; else
	s=$(mmcli -m any 2>/dev/null | awk -F': ' '/ state:/{gsub(/\033\[[0-9;]*m/,"",$2); print $2; exit}')
	check sim-ready modem-sim "$(case $s in registered|connected|connecting|enabled|searching) echo true ;; esac)" "modem state ${s:-unknown} with a SIM present"
fi
