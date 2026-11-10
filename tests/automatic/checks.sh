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
# crashes, and how many came right after a resume (within 2 s of "PM: suspend exit"); the kernel
# pads its timestamps with spaces, so they are read from inside the brackets
crashes=$(klog | grep -c 'crash detected in adsp' || true)
after_resume=$(klog | sed -n 's/^\[ *\([0-9.]*\)\] .*\(PM: suspend exit\|crash detected in adsp\).*/\1 \2/p' \
	| awk '$2 == "PM:" {r = $1} $2 == "crash" && r != "" && $1 - r < 2 {n++} END {print n + 0}')
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

