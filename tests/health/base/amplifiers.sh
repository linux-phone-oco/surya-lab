# surya's speaker amplifiers (two TAS2562 on i2c bus 9, 0x4c left and 0x4d right): each fed its own
# channel, and not muted at the chip - the amp volume bug left the digital volume at -110 dB
. /usr/lib/lpoco-health/lib.sh
sel="$(amixer -c 0 sget 'Left ASI1 Sel' 2>/dev/null | grep -o "Item0: '[A-Za-z0-9 ]*'") / $(amixer -c 0 sget 'Right ASI1 Sel' 2>/dev/null | grep -o "Item0: '[A-Za-z0-9 ]*'")"
case "$sel" in *Left*/*Right*) say amp-channels audio-speaker pass "$sel" ;; *) say amp-channels audio-speaker fail "$sel" ;; esac
command -v i2cget >/dev/null || { say amp-volume audio-speaker skip "no i2c-tools on the phone"; exit 0; }
for a in 0x4c 0x4d; do
	v=$(i2cset -f -y 9 $a 0x00 0x02 && i2cget -f -y 9 $a 0x0c; i2cset -f -y 9 $a 0x00 0x00)
	check amp-volume-$a audio-speaker "$([ -n "$v" ] && [ "$v" != 0x00 ] && echo true)" "chip $a digital volume high byte ${v:-unread} (0x00: -110 dB, silent)"
done
