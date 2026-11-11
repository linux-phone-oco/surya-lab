#!/bin/sh
# Automatic checks, run ON the phone as root - read-only, nothing to hear or touch. One JSON line
# per check: {"test", "component" (a linux-phone-oco/docs component id), "outcome" pass|fail|skip,
# "detail"}. A pass proves what a machine can: that a part is there and set up, not that a person
# hears or sees it - those are witnessed tests.
# The kernel log of this boot, complete: dmesg is a ring that verbose drivers overwrite within
# minutes (its oldest line was at 1525 s once); the journal keeps all of it.
klog() { journalctl -k -b 0 --no-pager -o short-monotonic 2>/dev/null || dmesg; }

u=$(id -u user 2>/dev/null || echo 10000)
as_user() { su user -c "XDG_RUNTIME_DIR=/run/user/$u $*" 2>/dev/null; }
say() { printf '{"test":"%s","component":"%s","outcome":"%s","detail":"%s"}\n' "$1" "$2" "$3" "$(printf '%s' "$4" | tr '"\n' "' ")"; }
check() { if [ "$3" = true ]; then say "$1" "$2" pass "$4"; else say "$1" "$2" fail "$4"; fi; }

# audio
# crashes, and how many came with a suspend: between "PM: suspend entry" and 2 s after "PM: suspend
# exit" (the crash can be logged just before the exit line). In awk alone: the phone's sed is
# BusyBox's, which has no \| - the earlier pattern matched nothing and always counted 0.
crashes=$(klog | grep -c 'crash detected in adsp' || true)
after_resume=$(klog | awk '
	function at(line) { sub(/^\[ */, "", line); sub(/\].*/, "", line); return line + 0 }
	/PM: suspend entry/ { asleep = 1 }
	/PM: suspend exit/ { woke = at($0); asleep = 0 }
	/crash detected in adsp/ { if (asleep || (woke != "" && at($0) - woke < 2)) n++ }
	END { print n + 0 }')
check adsp-stable audio-speaker "$([ "$crashes" = 0 ] && echo true)" "$crashes audio DSP crashes since boot, $after_resume right after a resume"
card=$(grep -c 'POCO X3' /proc/asound/cards); check sound-card audio-speaker "$([ "$card" -ge 1 ] && echo true)" "sound card present: $card"
spec=$(as_user "pactl list sinks" | grep -A4 'HiFi__Speaker' | grep 'Sample Spec' | sed 's/.*: //')
case "$spec" in *2ch*) say speaker-stereo audio-speaker pass "speaker sink: $spec";; "") say speaker-stereo audio-speaker skip "no PipeWire session to ask";; *) say speaker-stereo audio-speaker fail "speaker sink: $spec";; esac
sel="$(amixer -c 0 sget 'Left ASI1 Sel' 2>/dev/null | grep -o "Item0: '[A-Za-z0-9 ]*'") / $(amixer -c 0 sget 'Right ASI1 Sel' 2>/dev/null | grep -o "Item0: '[A-Za-z0-9 ]*'")"
case "$sel" in *Left*/*Right*) say amp-channels audio-speaker pass "$sel";; *) say amp-channels audio-speaker fail "$sel";; esac
if command -v i2cget >/dev/null; then
  for a in 0x4c 0x4d; do
    v=$(i2cset -f -y 9 $a 0x00 0x02 && i2cget -f -y 9 $a 0x0c; i2cset -f -y 9 $a 0x00 0x00)
    check amp-volume-$a audio-speaker "$([ "$v" != 0x00 ] && echo true)" "chip $a digital volume high byte $v (0x00: -110 dB, silent)"
  done
else say amp-volume audio-speaker skip "no i2c-tools on the phone"; fi
# display and input
conn=$(cat /sys/class/drm/card*-DSI*/status 2>/dev/null | head -1); check panel-connected display-panel "$([ "$conn" = connected ] && echo true)" "DSI: ${conn:-none}"
b=$(cat /sys/class/backlight/*/brightness 2>/dev/null | head -1); check backlight display-panel "$([ "${b:-0}" -gt 0 ] && echo true)" "brightness ${b:-none}"
t=$(grep -iE '^N: Name=.*(touch|ts|fts|nvt|goodix)' /proc/bus/input/devices | head -1 | sed 's/N: Name=//'); check touch-device touchscreen "$([ -n "$t" ] && echo true)" "${t:-no touch input device}"
# a vibration motor is an input device with force feedback: read each device as a whole block
v=$(awk -v RS= '/\nB: FF=/' /proc/bus/input/devices | sed -n 's/^N: Name=//p' | head -1)
check vibrator haptics "$([ -n "$v" ] && echo true)" "${v:-no force-feedback input device}"
# connectivity
w=$(ls /sys/class/net | grep -E '^wl' | head -1); hb=$(cat /sys/class/rfkill/*/hard 2>/dev/null | sort -u | tr '\n' ' ')
check wifi-interface wifi "$([ -n "$w" ] && echo true)" "interface ${w:-none}; rfkill hard: ${hb:-none}"
check bt-controller bluetooth "$([ -e /sys/class/bluetooth/hci0 ] && echo true)" "$(ls /sys/class/bluetooth 2>/dev/null | tr '\n' ' ')"
check nfc-device nfc "$([ -n "$(ls /sys/class/nfc 2>/dev/null)" ] && echo true)" "$(ls /sys/class/nfc 2>/dev/null | tr '\n' ' ')"
m=$(mmcli -L 2>/dev/null | grep -o '/Modem/[0-9]*' | head -1)
for c in modem-data modem-calls modem-sms; do check modem-seen $c "$([ -n "$m" ] && echo true)" "ModemManager: ${m:-no modem}"; done
# sensors and usb
i=$(ls /sys/bus/iio/devices 2>/dev/null | grep -c iio:device); check iio-sensors sensors "$([ "$i" -gt 0 ] && echo true)" "$i IIO devices (the ADSP sensors service is off on purpose)"
r=$(ls /sys/class/usb_role 2>/dev/null | head -1); check usb-role usb-otg "$([ -n "$r" ] && echo true)" "${r:-no USB role switch}"

# -- kernel: boot warnings - known ones pass (each with its reason), a new one fails, named
#   rpmh-rsc.c:451  a TCS completion with no request: the bootloader's leftover traffic
#   clk.c:1188/1048 dsi0_phy_pll_out_dsiclk already disabled/unprepared: the display clock the
#                   bootloader left running, released while the DSI PHY re-parents it
known="drivers/soc/qcom/rpmh-rsc.c:451 drivers/clk/clk.c:1188 drivers/clk/clk.c:1048"
new=""
for w in $(klog | sed -n 's/.*WARNING: \([^ ]*\) at .*/\1/p'); do
	case " $known " in *" $w "*) ;; *) new="$new $w" ;; esac
done
total=$(klog | grep -c "WARNING: " || true)
check boot-warnings kernel "$([ -z "$new" ] && echo true)" "$total warnings, ${new:+new:$new}${new:-all known}"

# -- audio: the default output is a real sound card, not a loopback or dummy (once, Sxmo's loopback
#    card became the default at boot and nothing was heard)
u=$(stat -c %U /run/user/* 2>/dev/null | grep -v '^root$' | head -1)
sink=$([ -n "$u" ] && su "$u" -c 'XDG_RUNTIME_DIR=/run/user/$(id -u) pactl get-default-sink' 2>/dev/null)
case $sink in
	"") say default-output audio-speaker skip "no sound server to ask" ;;
	*aloop*|*dummy*|*null*) check default-output audio-speaker "" "the default output is $sink" ;;
	*) check default-output audio-speaker true "$sink" ;;
esac

# storage: the system fills its partition - the first boot can grow the partition and leave the
# filesystem at the image's size (2 GB on a 104 GB partition, once)
src=$(findmnt -no SOURCE /); fs=$(df -B1 --output=size / | tail -n1 | tr -d ' '); dev=$(blockdev --getsize64 "$src" 2>/dev/null || echo 0)
check root-fills-its-partition kernel "$([ "$dev" -gt 0 ] && [ $((fs * 100 / dev)) -ge 90 ] && echo true)" "the system is $((fs >> 30)) GB on a partition of $((dev >> 30)) GB"

# usb: connected to a host, the phone holds a wake lock - else every suspend attempt aborts and drops
# the link, and the host sees the phone reconnect without end
state=$(cat /sys/class/udc/*/state 2>/dev/null | head -n1)
if [ "$state" = configured ]; then
  check usb-awake usb-otg "$(grep -q devlab-usb /sys/power/wake_lock 2>/dev/null && echo true)" "on USB to a host; wake locks held: $(cat /sys/power/wake_lock 2>/dev/null)"
else
  say usb-awake usb-otg skip "not connected to a host by USB (port state: ${state:-none})"
fi

# more of the phone, measured (2026-11-11) - each still read-only
# Wi-Fi: not only an interface - joined to a network, with an address, and the gateway answers
st=$(cat /sys/class/net/wlan0/operstate 2>/dev/null); ad=$(ip -4 addr show wlan0 2>/dev/null | awk '/inet /{print $2; exit}')
check wifi-connected wifi "$([ "$st" = up ] && [ -n "$ad" ] && echo true)" "wlan0 ${st:-absent}, address ${ad:-none}"
gw=$(ip route 2>/dev/null | awk '/^default/ && /wlan0/ {print $3; exit}')
if [ -n "$gw" ]; then check wifi-reaches-gateway wifi "$(ping -c 1 -W 2 "$gw" >/dev/null 2>&1 && echo true)" "gateway $gw"; else say wifi-reaches-gateway wifi skip "no route through wlan0"; fi
# Bluetooth: powered, and the radio hears something (nobody nearby is not a failure)
pw=$(bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2; exit}')
check bt-powered bluetooth "$([ "$pw" = yes ] && echo true)" "adapter powered: ${pw:-no adapter}"
if [ "$pw" = yes ]; then
  timeout 9 bluetoothctl --timeout 6 scan on >/dev/null 2>&1
  nd=$(bluetoothctl devices 2>/dev/null | grep -c '^Device')
  if [ "$nd" -gt 0 ]; then say bt-sees-devices bluetooth pass "$nd devices seen"; else say bt-sees-devices bluetooth skip "no device answered a 6 s scan"; fi
else say bt-sees-devices bluetooth skip "adapter not powered"; fi
# the modem and its SIM: without a SIM nothing about calls, messages or data can be shown
if [ -n "$m" ]; then
  mst=$(mmcli -m "${m##*/}" 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | awk -F': ' '/ state:/ && !/power/ {print $2; exit}')
  sim=$(mmcli -m "${m##*/}" 2>/dev/null | grep -c '/SIM/')
  for c in modem-data modem-calls modem-sms; do
    if [ "$sim" -gt 0 ]; then check modem-ready $c "$(case "$mst" in registered|connected|enabled) echo true;; esac)" "modem state: ${mst:-unknown}"; else say modem-ready $c skip "no SIM card in the phone (modem state: ${mst:-unknown})"; fi
  done
fi
# parts the kernel does or does not expose
jk=$(grep -c 'Headset Jack' /proc/bus/input/devices 2>/dev/null); check jack-detector audio-headphone "$([ "$jk" -ge 1 ] && echo true)" "headset jack detector: $jk (sound through it is a witnessed test)"
fp=$(ls /dev /sys/bus/platform/devices 2>/dev/null | grep -ciE 'goodix|fingerprint|fpc1|_fp$'); check reader-exposed fingerprint "$([ "$fp" -ge 1 ] && echo true)" "fingerprint reader devices exposed by the kernel: $fp"
sn=0; for d in /sys/bus/iio/devices/iio:device*; do [ -e "$d/name" ] || continue; case "$(cat "$d/name")" in *adc*) ;; *) sn=$((sn+1));; esac; done
check motion-and-light sensors "$([ "$sn" -ge 1 ] && echo true)" "motion, light or proximity sensors exposed: $sn (voltage meters not counted)"
vf=$(ls /sys/class/video4linux 2>/dev/null | grep -c '^video'); is=0
for d in /sys/class/video4linux/v4l-subdev*; do [ -e "$d/name" ] || continue; case "$(cat "$d/name")" in msm_*) ;; *) is=$((is+1));; esac; done
for c in camera-rear camera-front; do check image-sensor $c "$([ "$is" -ge 1 ] && echo true)" "camera pipeline nodes: $vf; image sensors bound: $is"; done
