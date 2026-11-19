# Read-only: can the PMIC's power-on reason be read on this kernel? Mainline qcom-pon exposes no reason attribute;
# a reason would show as a sysfs attribute of the pon device, a bootreason on the command line, or a pstore record.
# A skip says "nothing readable"; a pass only when a reason is found. Nothing is changed.
. /usr/lib/lpoco-health/lib.sh
found=""
for f in /sys/devices/platform/soc@0/*.spmi/spmi-0/0-00/*pon@*/*reason* /sys/devices/platform/soc@0/*.spmi/spmi-0/0-00/*pon@*/*poff*; do [ -e "$f" ] && found="$found $f"; done
br=$(tr ' ' '\n' < /proc/cmdline | grep -i -E "bootreason|reset_reason|reboot_reason" | tr '\n' ' ')
if [ -n "$found" ] || [ -n "$br" ]; then
	say pon-reason-read power-pon pass "reason source:${found} ${br}"
else
	say pon-reason-read power-pon skip "no PON reason attribute, no bootreason on the command line: mainline qcom-pon does not expose it (reboot mode: $(cat /sys/kernel/reboot/mode 2>/dev/null)); needs a driver change or SDAM read"
fi
