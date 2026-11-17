# surya's two microphones hear its own speaker, through the sound server as any application records: a 1 kHz
# tone played quietly through the speakers at the manifest's level (TEST_TONE_DBFS, TEST_VOLUME - the author
# heard -6 dBFS at 20% as a soft beep) is recorded from the default source - the UCM profile's Mic (bottom,
# WCD9375 ADC1) - and again from its TopMic (ADC2 at INP3), and found in each recording by devlab-health tone find
# (lab-tools' tone crate: a Goertzel at 1 kHz against six frequencies beside it). PulseAudio makes the two conflicting UCM devices two
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
# a second of tone, raw s16le mono as pacat plays it: made by devlab-health from lab-tools' tone crate
tone=$(mktemp)
devlab-health tone make --raw --freq 1000 --secs 1 --level "$level" "$tone"
chmod 644 "$tone"
was=$(as_user pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]*%' | head -n1)
as_user pactl set-sink-volume @DEFAULT_SINK@ "$volume"
# record the source while the tone plays; print whether it played and devlab-health's finding (one JSON line)
listen() {
	rec=$(as_user mktemp)
	as_user timeout 3 parecord --raw --format=s16le --rate=48000 --channels=1 --device="$1" "$rec" &
	sleep 0.6
	played=$(as_user pacat --playback --raw --format=s16le --rate=48000 --channels=1 "$tone" && echo yes || echo no)
	wait
	printf '%s %s\n' "$played" "$(devlab-health tone find --freq 1000 --min-snr 20 --rate 48000 "$rec")"
	rm -f "$rec"
}
verdict() { # TEST MIC "PLAYED JSON"
	played=${3%% *} said=${3#* }
	n=$(json_field samples "$said") t=$(json_field level_dbfs "$said") z=$(json_field noise_dbfs "$said")
	check "$1" audio-mic "$(json_field found "$said")" \
		"$2 mic through the sound server; 1 kHz at $level dBFS, volume $volume (played: ${played:-no}): heard at $t dBFS against $z dBFS of noise beside it, ${n:-0} samples"
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
rm -f "$tone"
