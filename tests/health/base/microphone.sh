# surya's main microphone: an analog mic on the WCD9375 codec (ADC1), reached over the TX SoundWire bus,
# the LPASS TX macro (DEC0) and the DSP's TX_CODEC_DMA_TX_3 into the MultiMedia2 PCM. Two seconds are
# recorded; anything but digital silence in its last half second proves samples come back from the
# microphone (a real ADC is never exactly 0).
# This is the bottom mic (AMIC1); the top mic (AMIC3 on ADC2) is heard by mic-top-hears-speaker. surya has
# no digital mics: the TX DMIC routes in Xiaomi's tree are its QRD reference board's (research-microphones).
# The route is set for the recording only and the mixer is put back as it was.
. /usr/lib/lpoco-health/lib.sh
amixer -c 0 cget name='TX DEC0 MUX' >/dev/null 2>&1 ||
	{ say mic-records audio-mic fail "no microphone route: the codec's TX controls (TX DEC0 MUX) are missing"; exit 0; }
pcm=$(grep -m1 ': MultiMedia2 ' /proc/asound/pcm | cut -d: -f1)
[ -n "$pcm" ] || { say mic-records audio-mic fail "no MultiMedia2 PCM to record from"; exit 0; }
saved=$(mktemp) rec=$(mktemp)
alsactl -f "$saved" store 0 2>/dev/null
route() {
	amixer -c 0 cset name='TX DEC0 MUX' "$1" &&
		amixer -c 0 cset name='TX SMIC MUX0' "$2" &&
		amixer -c 0 cset name='TX_AIF1_CAP Mixer DEC0' "$3" &&
		amixer -c 0 cset name='ADC1_MIXER Switch' "$3" &&
		amixer -c 0 cset name='ADC1 Switch' "$3" &&
		amixer -c 0 cset name='MultiMedia2 Mixer TX_CODEC_DMA_TX_3' "$3"
} >/dev/null 2>&1
if ! route SWR_MIC ADC0 1; then
	detail="the microphone route could not be set"
elif ! err=$(arecord -q -D "hw:0,${pcm#00-}" -f S16_LE -r 48000 -c 1 -d 2 -t raw "$rec" 2>&1); then
	detail="recording failed: $(printf '%s' "$err" | tail -n1)"
fi
alsactl -f "$saved" restore 0 >/dev/null 2>&1
if [ -n "${detail:-}" ]; then
	say mic-records audio-mic fail "$detail; kernel: $(klog | grep -iE 'soundwire|swrm|wcd' | tail -n1 | cut -c1-160)"
else
	# peak to peak of the last half second: the decimation filter rings for a few hundred ms after start
	# even when no sample comes from the ADC (2026-11-17: -1774 settling to exact 0), so the start proves nothing
	stats=$(od -An -v -td2 -w2 -j 144000 "$rec" | awk 'NR==1{lo=$1;hi=$1} {if($1<lo)lo=$1; if($1>hi)hi=$1; n++} END{printf "%d %d %d", n, lo, hi}')
	set -- $stats
	check mic-records audio-mic "$([ "${1:-0}" -gt 0 ] && [ $(($3 - $2)) -gt 4 ] && echo true)" \
		"${1:-0} samples of the last 0.5 s from $pcm, from $2 to $3 (digital silence: 0 to 0)"
fi
rm -f "$saved" "$rec"
