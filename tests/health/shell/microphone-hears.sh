# surya's bottom microphone hears its own speaker: a 1 kHz tone, played quietly through the speakers at the
# manifest's level (TEST_TONE_DBFS, TEST_VOLUME - the author heard -6 dBFS at 20% as a soft beep), is
# recorded through the WCD9375's ADC1 and found by a Goertzel filter at 1 kHz, against the noise at 700 Hz
# and 1300 Hz. A pass proves the microphone works; the phone decides, nobody listens to the recording.
. /usr/lib/devlab/health/lib.sh
[ -n "$(session_user)" ] || { say mic-hears-speaker audio-mic skip "no graphical session: no sound server to play through"; exit 0; }
amixer -c 0 cget name='TX DEC0 MUX' >/dev/null 2>&1 ||
	{ say mic-hears-speaker audio-mic fail "no microphone route: the codec's TX controls are missing"; exit 0; }
pcm=$(grep -m1 ': MultiMedia2 ' /proc/asound/pcm | cut -d: -f1)
level=${TEST_TONE_DBFS:--40} volume=${TEST_VOLUME:-25%}
tone=$(mktemp) rec=$(mktemp) saved=$(mktemp)
# one period of 1 kHz at 48 kHz is 48 samples; a second of tone is that period a thousand times
awk -v db="$level" 'BEGIN { a = 32767 * 10 ^ (db / 20); for (i = 0; i < 48; i++) {
	v = int(a * sin(2 * 3.14159265358979 * i / 48)); if (v < 0) v += 65536
	printf "\\%03o\\%03o", v % 256, int(v / 256) } }' > "$tone.p"
period=$(cat "$tone.p"); i=0; : > "$tone"
while [ $i -lt 1000 ]; do printf "$period" >> "$tone"; i=$((i + 1)); done
chmod 644 "$tone"   # played by the session user
alsactl -f "$saved" store 0 2>/dev/null
{ amixer -c 0 cset name='TX DEC0 MUX' SWR_MIC && amixer -c 0 cset name='TX SMIC MUX0' ADC0 &&
	amixer -c 0 cset name='TX_AIF1_CAP Mixer DEC0' 1 && amixer -c 0 cset name='ADC1_MIXER Switch' 1 &&
	amixer -c 0 cset name='ADC1 Switch' 1 && amixer -c 0 cset name='ADC1 Volume' 18 &&
	amixer -c 0 cset name='TX_DEC0 Volume' 104 &&
	amixer -c 0 cset name='MultiMedia2 Mixer TX_CODEC_DMA_TX_3' 1; } >/dev/null 2>&1
was=$(as_user pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]*%' | head -n1)
as_user pactl set-sink-volume @DEFAULT_SINK@ "$volume"
arecord -q -D "hw:0,${pcm#00-}" -f S16_LE -r 48000 -c 1 -d 2 -t raw "$rec" 2>/dev/null &
sleep 0.5
played=$(as_user pacat --playback --raw --format=s16le --rate=48000 --channels=1 "$tone" && echo yes)
wait
as_user pactl set-sink-volume @DEFAULT_SINK@ "${was:-$volume}"
alsactl -f "$saved" restore 0 >/dev/null 2>&1
# Goertzel power at f over the whole recording, as a level in dBFS
result=$(od -An -v -td2 -w2 "$rec" | awk 'function lv(c, s1, s2) { return 10 * log((s1*s1 + s2*s2 - c*s1*s2) * 4 / (n*n) / (32768*32768) + 1e-20) / log(10) }
	BEGIN { pi = 3.14159265358979; split("1000 700 1300", f, " "); for (k = 1; k <= 3; k++) c[k] = 2 * cos(2 * pi * f[k] / 48000) }
	{ x = $1; n++; for (k = 1; k <= 3; k++) { s = x + c[k] * p1[k] - p2[k]; p2[k] = p1[k]; p1[k] = s } }
	END { if (n == 0) { print "0 0 0"; exit }
		t = lv(c[1], p1[1], p2[1]); a = lv(c[2], p1[2], p2[2]); b = lv(c[3], p1[3], p2[3])
		printf "%d %.1f %.1f\n", n, t, (a > b ? a : b) }')
rm -f "$tone" "$tone.p" "$rec" "$saved"
set -- $result
check mic-hears-speaker audio-mic "$(awk -v n="$1" -v t="$2" -v z="$3" 'BEGIN { if (n > 0 && t - z >= 20) print "true" }')" \
	"1 kHz at $level dBFS, volume $volume (played: ${played:-no}): heard at $2 dBFS against $3 dBFS of noise beside it, ${1:-0} samples"
