# surya's speakers are stereo: the UCM profile (ucm/Xiaomi/surya/HiFi.conf) gives the speaker device two
# channels, the top amplifier left and the bottom right; a sound server that opened it in mono would play
# both amplifiers the same signal (carried over from the retired tests/automatic/checks.sh)
. /usr/lib/lpoco-health/lib.sh
[ -n "$(session_user)" ] || { say speaker-stereo audio-speaker skip "no graphical session: the base alone"; exit 0; }
sink=$(as_user pactl list short sinks | awk '/HiFi__Speaker__sink/{print $2; exit}')
[ -n "$sink" ] || { say speaker-stereo audio-speaker fail "no HiFi Speaker sink: the UCM profile is not in use"; exit 0; }
spec=$(as_user pactl list sinks | awk -v s="$sink" '$1=="Name:"{n=($2==s)} n && /Sample Specification:/{sub(/.*: /,""); print; exit}')
case $spec in
	*2ch*) say speaker-stereo audio-speaker pass "$sink: $spec" ;;
	*) say speaker-stereo audio-speaker fail "$sink: ${spec:-no sample specification}" ;;
esac
