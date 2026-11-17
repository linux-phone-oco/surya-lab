# surya's earpiece plays: it is the top speaker (the TAS2564, left channel), which the UCM profile's Earpiece
# device drives alone, both channels mixed, at -18 dB. With the card on "HiFi (Earpiece, TopMic)", a quiet
# 1 kHz tone (TEST_TONE_DBFS, at twice TEST_VOLUME to make up the earpiece's -18 dB) is played as a mono stream, as a call would be, and the top
# microphone beside the earpiece finds it with a Goertzel filter, 20 dB above the noise at 700 and 1300 Hz.
# The author heard the top speaker as the earpiece (2026-11-17); the phone decides, nobody listens.
. /usr/lib/devlab/health/lib.sh
[ -n "$(session_user)" ] || { say earpiece-heard audio-earpiece skip "no graphical session: no sound server"; exit 0; }
card=alsa_card.platform-sound
# as_user runs its words through su -c, so a profile name is quoted once more for that shell
as_user pactl set-card-profile $card "'HiFi (Earpiece, TopMic)'" 2>/dev/null ||
	{ say earpiece-heard audio-earpiece fail "the card has no HiFi (Earpiece, TopMic) profile: the UCM profile has no Earpiece"; exit 0; }
sleep 1
level=${TEST_TONE_DBFS:--40} volume=${TEST_VOLUME:-25%}
# the Earpiece device is 18 dB below the speaker: twice the volume (about +18 dB on the sound server's cubic
# curve) makes this beep as loud as the speaker checks' - the level the author approved - from the earpiece
v=${volume%\%}; volume=$(( v * 2 > 100 ? 100 : v * 2 ))%
tone=$(mktemp)
awk -v db="$level" 'BEGIN { a = 32767 * 10 ^ (db / 20); for (i = 0; i < 48; i++) {
	v = int(a * sin(2 * 3.14159265358979 * i / 48)); if (v < 0) v += 65536
	printf "\\%03o\\%03o", v % 256, int(v / 256) } }' > "$tone.p"
period=$(cat "$tone.p"); i=0; : > "$tone"
while [ $i -lt 1000 ]; do printf "$period" >> "$tone"; i=$((i + 1)); done
chmod 644 "$tone"
sink=alsa_output.platform-sound.HiFi__Earpiece__sink
was=$(as_user pactl get-sink-volume $sink | grep -o '[0-9]*%' | head -n1)
as_user pactl set-sink-volume $sink "$volume"
rec=$(as_user mktemp)
as_user timeout 3 parecord --raw --format=s16le --rate=48000 --channels=1 --device=alsa_input.platform-sound.HiFi__TopMic__source "$rec" &
sleep 0.6
played=$(as_user pacat --playback --raw --format=s16le --rate=48000 --channels=1 --device=$sink "$tone" && echo yes || echo no)
wait
as_user pactl set-sink-volume $sink "${was:-$volume}"
as_user pactl set-card-profile $card "'HiFi (Mic, Speaker)'" 2>/dev/null
set -- $(od -An -v -td2 -w2 "$rec" | awk -v from=43200 -v to=86400 'function lv(c, s1, s2) { return 10 * log((s1*s1 + s2*s2 - c*s1*s2) * 4 / (n*n) / (32768*32768) + 1e-20) / log(10) }
	BEGIN { pi = 3.14159265358979; split("1000 700 1300", f, " "); for (k = 1; k <= 3; k++) c[k] = 2 * cos(2 * pi * f[k] / 48000) }
	# only the second while the tone sounds (0.9 s to 1.8 s): not the pop of the profile switch
	NR > from && NR <= to { x = $1; n++; for (k = 1; k <= 3; k++) { s = x + c[k] * p1[k] - p2[k]; p2[k] = p1[k]; p1[k] = s } }
	END { if (n == 0) { print "0 0 0"; exit }
		t = lv(c[1], p1[1], p2[1]); a = lv(c[2], p1[2], p2[2]); b = lv(c[3], p1[3], p2[3])
		printf "%d %.1f %.1f\n", n, t, (a > b ? a : b) }')
rm -f "$tone" "$tone.p" "$rec"
check earpiece-heard audio-earpiece "$(awk -v n="$1" -v t="$2" -v z="$3" 'BEGIN { if (n > 0 && t - z >= 20) print "true" }')" \
	"1 kHz at $level dBFS, volume $volume, mono through the Earpiece (played: $played): the top mic heard it at $2 dBFS against $3 dBFS of noise beside it, ${1:-0} samples"
