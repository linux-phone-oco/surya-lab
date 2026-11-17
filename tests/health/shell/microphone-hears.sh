# surya's two microphones hear its own speaker, through the sound server as any application records: a 1 kHz
# tone played quietly through the speakers at the manifest's level (TEST_TONE_DBFS, TEST_VOLUME - the author
# heard -6 dBFS at 20% as a soft beep) is recorded from the default source - the UCM profile's Mic (bottom,
# WCD9375 ADC1) - and again from its TopMic (ADC2 at INP3), and found in each recording by a Goertzel
# filter at 1 kHz against the noise at 700 and 1300 Hz. PulseAudio makes the two conflicting UCM devices two
# card profiles, so the top mic is reached by switching the card to "HiFi (Speaker, TopMic)" and back. No mixer is set by hand: a pass proves the
# microphone and its UCM capture profile work (20 dB above the noise). The phone decides; nobody listens.
. /usr/lib/devlab/health/lib.sh
[ -n "$(session_user)" ] || { say mic-hears-speaker audio-mic skip "no graphical session: no sound server"; exit 0; }
src=$(as_user pactl get-default-source)
case $src in
	*HiFi__Mic__source*) ;;
	*) say mic-hears-speaker audio-mic fail "the default source is ${src:-none}, not the UCM profile's Mic"; exit 0 ;;
esac
level=${TEST_TONE_DBFS:--40} volume=${TEST_VOLUME:-25%}
tone=$(mktemp)
# one period of 1 kHz at 48 kHz is 48 samples; a second of tone is that period a thousand times
awk -v db="$level" 'BEGIN { a = 32767 * 10 ^ (db / 20); for (i = 0; i < 48; i++) {
	v = int(a * sin(2 * 3.14159265358979 * i / 48)); if (v < 0) v += 65536
	printf "\\%03o\\%03o", v % 256, int(v / 256) } }' > "$tone.p"
period=$(cat "$tone.p"); i=0; : > "$tone"
while [ $i -lt 1000 ]; do printf "$period" >> "$tone"; i=$((i + 1)); done
chmod 644 "$tone"
was=$(as_user pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]*%' | head -n1)
as_user pactl set-sink-volume @DEFAULT_SINK@ "$volume"
# record the default source while the tone plays; print n, the tone's level and the louder neighbour's
listen() {
	rec=$(as_user mktemp)
	as_user timeout 3 parecord --raw --format=s16le --rate=48000 --channels=1 --device="$1" "$rec" &
	sleep 0.6
	played=$(as_user pacat --playback --raw --format=s16le --rate=48000 --channels=1 "$tone" && echo yes || echo no)
	wait
	printf "%s " "$played"
	od -An -v -td2 -w2 "$rec" | awk 'function lv(c, s1, s2) { return 10 * log((s1*s1 + s2*s2 - c*s1*s2) * 4 / (n*n) / (32768*32768) + 1e-20) / log(10) }
		BEGIN { pi = 3.14159265358979; split("1000 700 1300", f, " "); for (k = 1; k <= 3; k++) c[k] = 2 * cos(2 * pi * f[k] / 48000) }
		{ x = $1; n++; for (k = 1; k <= 3; k++) { s = x + c[k] * p1[k] - p2[k]; p2[k] = p1[k]; p1[k] = s } }
		END { if (n == 0) { print "0 0 0"; exit }
			t = lv(c[1], p1[1], p2[1]); a = lv(c[2], p1[2], p2[2]); b = lv(c[3], p1[3], p2[3])
			printf "%d %.1f %.1f\n", n, t, (a > b ? a : b) }'
	rm -f "$rec"
}
verdict() { # TEST MIC "PLAYED N TONE NOISE"
	set -- "$1" "$2" $3
	played=$3; t=$1 m=$2; shift 3; set -- "$t" "$m" "$@"
	check "$1" audio-mic "$(awk -v n="$3" -v t="$4" -v z="$5" 'BEGIN { if (n > 0 && t - z >= 20) print "true" }')" \
		"$2 mic through the sound server; 1 kHz at $level dBFS, volume $volume (played: ${played:-no}): heard at $4 dBFS against $5 dBFS of noise beside it, ${3:-0} samples"
}
bottom=$(listen "$src"); verdict mic-hears-speaker bottom "$bottom"
card=alsa_card.platform-sound
# as_user runs its words through su -c, so a profile name is quoted once more for that shell
if as_user pactl set-card-profile $card "'HiFi (Speaker, TopMic)'" 2>/dev/null; then
	sleep 1
	top=$(listen alsa_input.platform-sound.HiFi__TopMic__source); verdict mic-top-hears-speaker top "$top"
	as_user pactl set-card-profile $card "'HiFi (Mic, Speaker)'" 2>/dev/null
else
	say mic-top-hears-speaker audio-mic fail "the card has no HiFi (Speaker, TopMic) profile"
fi
as_user pactl set-sink-volume @DEFAULT_SINK@ "${was:-$volume}"
rm -f "$tone" "$tone.p"
