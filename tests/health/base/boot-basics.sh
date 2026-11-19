# Read-only checks of the first steps of daily-usable-phone: the kernel runs, the console is active, the USB
# gadget is enumerated by the host, the PMIC is bound, storage reads. Nothing is changed.
# Each pass proves "present and answering" only, not that the part works end to end.
. /usr/lib/lpoco-health/lib.sh
k=$(uname -r); up=$(cut -d. -f1 /proc/uptime)
check linux-runs kernel "$([ -n "$k" ] && [ "${up:-0}" -gt 0 ] && echo true)" "kernel $k, up ${up:-?} s (this check runs in it)"
con=$(cat /sys/class/tty/console/active 2>/dev/null)
check shell-on-console console "$(case " $con " in *" ttyMSM0 "*) [ -c /dev/ttyMSM0 ] && echo true ;; esac)" "kernel console '${con:-none}', /dev/ttyMSM0 present (a login getty is its own step)"
udc=$(ls /sys/class/udc 2>/dev/null | head -1); st=$(cat /sys/class/udc/$udc/state 2>/dev/null)
check gadget-enumerates usb "$(case "$st" in configured|suspended) echo true ;; esac)" "UDC ${udc:-none} state ${st:-unread} (configured or suspended: the host enumerated the gadget; not_attached means no cable)"
n=$(ls /sys/bus/spmi/devices 2>/dev/null | wc -l)
b=$(for x in /sys/bus/spmi/devices/*; do [ -e "$x/driver" ] && echo y; done | wc -l)
u=$(for x in /sys/bus/spmi/devices/*; do [ -e "$x/driver" ] || echo "${x##*/}"; done | tr '\n' ' ')
check pmic-bound power "$([ "$n" -gt 0 ] && [ "$b" -gt 0 ] && echo true)" "$n SPMI devices, $b with a driver bound; unbound: ${u:-none}"
r=$(awk '$2=="/" && $1 ~ /^\/dev\//{print $1" "$4; exit}' /proc/mounts)
src=${r%% *}; sz=$(blockdev --getsz "$src" 2>/dev/null); mid=$(( ${sz:-0} / 16 ))
rd=$([ "$mid" -gt 0 ] && dd if="$src" of=/dev/null bs=4k skip=$mid count=16 iflag=direct 2>/dev/null && echo true)
check storage-readonly storage "$rd" "root ${r:-unknown} (a loop image, not the physical flash): 64 KiB read from its middle, direct, nothing written"
