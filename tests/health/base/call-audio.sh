# surya's call audio path: on a modem call the audio DSP mixes the voice itself (q6voice: MVM, CVS, CVP
# over APR) and the host only starts the ports. That needs, in the kernel, the q6voice drivers and a
# hostless VoiceMMode1 link (a PCM q6voiced opens for every call), with the routing controls that put the
# call on the speaker's TERT_MI2S_RX and take the uplink from the microphones' TX_CODEC_DMA_TX_3, the
# way pulpoff/linux-surya carries calls on this phone. A pass proves the path is there, not that a
# call carries sound: that is the echo call's (call-echo). Reads only; changes nothing.
. /usr/lib/lpoco-health/lib.sh
miss=""
grep -q ': VoiceMMode1 ' /proc/asound/pcm 2>/dev/null || miss="$miss, no VoiceMMode1 PCM"
for c in 'TERT_MI2S_RX Voice Mixer VoiceMMode1' 'VoiceMMode1 Capture Mixer TX_CODEC_DMA_TX_3'; do
	amixer -c 0 cget name="$c" >/dev/null 2>&1 || miss="$miss, no control '$c'"
done
command -v q6voiced >/dev/null || miss="$miss, no q6voiced"
if [ -z "$miss" ]; then
	say call-audio-path modem-calls pass "the VoiceMMode1 PCM, its routing controls and q6voiced are there"
else
	say call-audio-path modem-calls fail "the DSP's voice path is missing (is q6voice in this kernel?)$miss"
fi
