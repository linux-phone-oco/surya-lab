# SMS goes out and comes in: the phone texts its own number (kept privately on the phone in
# /etc/devlab/private/own-number, never in a repository) a unique token, and finds it among the received
# messages within 90 s (or in Sxmo's own log, if the shell took it first); both copies and the pop-up are cleared.
# One SMS a day at most: other runs that day skip ("ran today"). Skipped without the number or a registration.
. /usr/lib/lpoco-health/lib.sh
num=$(cat /etc/devlab/private/own-number 2>/dev/null)
[ -n "$num" ] || { say sms-loopback modem-sms skip "no own number on the phone (/etc/devlab/private/own-number)"; exit 0; }
no_sim && { say sms-loopback modem-sms skip "no SIM card"; exit 0; }
state=$(mmcli -m any 2>/dev/null | awk -F': ' '/ state:/{gsub(/\033\[[0-9;]*m/,"",$2); print $2; exit}')
case $state in registered|connected|connecting) ;; *) say sms-loopback modem-sms skip "modem state ${state:-unknown}"; exit 0 ;; esac
# the telephony layer: once a day (lib.sh); other runs that day measure nothing and say so
once_a_day sms-loopback || { say sms-loopback modem-sms skip "ran today"; exit 0; }
token="devlab-$(date +%Y%m%d%H%M%S)-$$"
sent=$(mmcli -m any --messaging-create-sms="text='$token',number='$num'" 2>/dev/null | grep -o '/SMS/[0-9]*' | head -n1)
[ -n "$sent" ] || { say sms-loopback modem-sms fail "the SMS could not be created"; exit 0; }
start=$(date +%s)
if ! mmcli -s "${sent##*/}" --send >/dev/null 2>&1; then
	mmcli -m any --messaging-delete-sms="${sent##*/}" >/dev/null 2>&1
say sms-loopback modem-sms fail "the SMS could not be sent"; exit 0
fi
got=""; i=0
while [ $i -lt 45 ] && [ -z "$got" ]; do
	sleep 2; i=$((i + 1))
	for p in $(mmcli -m any --messaging-list-sms 2>/dev/null | awk '/received/{print $1}' | grep -o '[0-9]*$'); do
		mmcli -s "$p" 2>/dev/null | grep -q "$token" && got=$p
	done
	# a shell may take the message first: Sxmo files it in its own log and deletes it from ModemManager
	[ -z "$got" ] && grep -qs "$token" /home/*/.local/share/sxmo/modem/*/sms.txt && got=sxmo
done
took=$(( $(date +%s) - start ))
mmcli -m any --messaging-delete-sms="${sent##*/}" >/dev/null 2>&1
[ -n "$got" ] && [ "$got" != sxmo ] && mmcli -m any --messaging-delete-sms="$got" >/dev/null 2>&1
# the shell's pop-up for the test message is cleared: a test is not news
for n in $(grep -ls "$token" /home/*/.local/share/sxmo/notifications/* 2>/dev/null); do rm -f "$n"; done
mkdir -p /var/lib/devlab
if [ -n "$got" ]; then
say sms-loopback modem-sms pass "sent to itself and received in ${took} s"
else
say sms-loopback modem-sms fail "sent, not received within ${took} s"
fi
