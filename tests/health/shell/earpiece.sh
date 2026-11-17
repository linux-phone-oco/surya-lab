# surya's earpiece plays: it is the top speaker (the TAS2564, left channel), which the UCM profile's Earpiece
# device drives alone, both channels mixed, at -18 dB. With the card on "HiFi (Earpiece, TopMic)", a quiet
# 1 kHz tone (TEST_TONE_DBFS, at twice TEST_VOLUME to make up the earpiece's -18 dB) is played as a mono stream, as a call would be, and the top
# microphone beside the earpiece finds it with devlab-health tone find, 20 dB above the noise beside it.
# The author heard the top speaker as the earpiece (2026-11-17); the phone decides, nobody listens.
. /usr/lib/lpoco-health/lib.sh
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
devlab-health tone make --raw --freq 1000 --secs 1 --level "$level" "$tone"
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
# only the second while the tone sounds (0.9 s to 1.8 s): not the pop of the profile switch
said=$(devlab-health tone find --freq 1000 --min-snr 20 --rate 48000 --from 0.9 --to 1.8 "$rec")
rm -f "$tone" "$rec"
n=$(json_field samples "$said") t=$(json_field level_dbfs "$said") z=$(json_field noise_dbfs "$said")
check earpiece-heard audio-earpiece "$(json_field found "$said")" \
	"1 kHz at $level dBFS, volume $volume, mono through the Earpiece (played: $played): the top mic heard it at $t dBFS against $z dBFS of noise beside it, ${n:-0} samples"
