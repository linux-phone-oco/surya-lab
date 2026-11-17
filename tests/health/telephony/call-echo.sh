# A call carries sound both ways: once a day the phone calls blueSIP's echo line (+49 89 721010 99701, a
# Munich landline that plays back what it hears), waits out its announcement (about 19 s), plays a 1 s tone
# on the earpiece and records the microphone through the call (devlab-call-uplink). The tone goes up, comes
# back from the echo line, plays again, is heard again: 1 to 2 s after the tone ended it is still there,
# which only the echo can make. devlab-health tone find decides (20 dB above the noise). ~30 s of a call a
# day; other runs tell that day's result again. Skipped without registration or a sound server.
. /usr/lib/devlab/health/lib.sh
num=${CALL_ECHO_NUMBER:-+498972101099701}
last=/var/lib/devlab/call-echo.last
# the telephony layer: once a day (lib.sh); on later runs that day, the day's result is told again
if ! once_a_day call-echo; then
	[ -f "$last" ] || { say call-echo modem-calls skip "ran today"; exit 0; }
	set -- $(cat "$last"); outcome=$1; shift; say call-echo modem-calls "$outcome" "today's call (one a day): $*"; exit 0
fi
[ -n "$(session_user)" ] || { say call-echo modem-calls skip "no graphical session: no sound server"; exit 0; }
state=$(mmcli -m any 2>/dev/null | awk -F': ' '/ state:/{gsub(/\033\[[0-9;]*m/,"",$2); print $2; exit}')
case $state in registered|connected) ;; *) say call-echo modem-calls skip "modem state ${state:-unknown}"; exit 0 ;; esac
card=alsa_card.platform-sound level=${TEST_TONE_DBFS:--40} volume=${TEST_VOLUME:-25%}
v=${volume%\%}; volume=$(( v * 2 > 100 ? 100 : v * 2 ))%   # the earpiece is 18 dB below the speaker
tone=$(mktemp); devlab-health tone make --raw --freq 1500 --secs 1 --level "$level" "$tone"; chmod 644 "$tone"
raw=/run/devlab/call-uplink.raw; mkdir -p /run/devlab; rm -f "$raw"; touch /run/devlab/call-uplink.want
# the voice profile before dialing: the DSP builds its voice processor at the first call with what is set then
as_user pactl set-card-profile $card "'Voice Call (Earpiece, Mic)'" 2>/dev/null
was=$(as_user pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]*%' | head -n1)
as_user pactl set-sink-volume @DEFAULT_SINK@ "$volume"
c=$(mmcli -m any --voice-create-call="number=$num" 2>/dev/null | grep -o '/Call/[0-9]*'); c=${c##*/}
detail="" t0=""
if [ -z "$c" ] || ! mmcli -o "$c" --start >/dev/null 2>&1; then
	detail="the call could not be placed"
else
	i=0; while [ $i -lt 30 ] && ! mmcli -o "$c" 2>/dev/null | grep -q "state: active"; do sleep 1; i=$((i + 1)); done
	if ! mmcli -o "$c" 2>/dev/null | grep -q "state: active"; then
		detail="the echo line did not answer within 30 s"
	else
		sleep 20
		t0=$(stat -c %s "$raw" 2>/dev/null); t0=$(awk -v b="${t0:-0}" 'BEGIN { printf "%.2f", b / 96000 }')
		as_user pacat --playback --raw --format=s16le --rate=48000 --channels=1 "$tone"
		sleep 4
	fi
	mmcli -o "$c" --hangup >/dev/null 2>&1; sleep 1; mmcli -m any --voice-delete-call="$c" >/dev/null 2>&1
fi
as_user pactl set-sink-volume @DEFAULT_SINK@ "${was:-30%}"
as_user pactl set-card-profile $card "'HiFi (Mic, Speaker)'" 2>/dev/null
rm -f /run/devlab/call-uplink.want "$tone"; mkdir -p /var/lib/devlab
if [ -z "$detail" ]; then
	direct=$(devlab-health tone find --freq 1500 --rate 48000 --from "$(awk -v t="$t0" 'BEGIN{print t + 0.2}')" --to "$(awk -v t="$t0" 'BEGIN{print t + 0.9}')" "$raw")
	echo=$(devlab-health tone find --freq 1500 --min-snr 20 --rate 48000 --from "$(awk -v t="$t0" 'BEGIN{print t + 2}')" --to "$(awk -v t="$t0" 'BEGIN{print t + 3}')" "$raw")
	found=$(json_field found "$echo")
	detail="tone played at $(json_field level_dbfs "$direct") dBFS at the mic; 1-2 s after it ended, $(json_field level_dbfs "$echo") dBFS against $(json_field noise_dbfs "$echo") dBFS of noise (the echo)"
	outcome=fail; [ "$found" = true ] && outcome=pass
else
	outcome=fail
fi
rm -f "$raw"
echo "$outcome $detail" > "$last"
say call-echo modem-calls "$outcome" "$detail"
