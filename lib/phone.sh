# Talking to the phone, for every surya-lab script: source it, then use the functions.
#
#   . "$(dirname "$0")/../lib/phone.sh"
#   phone_find                 pick the address that answers (USB first, then Wi-Fi) or fail
#   phone_sh   <<'CMDS' ...    run commands as the user (with the session's XDG_RUNTIME_DIR)
#   phone_root <<'CMDS' ...    run commands as root
#   phone_put LOCAL REMOTE     copy a file to the phone
#   phone_reboot               reboot, then wait until it answers again with a fresh uptime
#
# Commands travel as a script on standard input (sh -s), never inside quotes on a command line, so
# quotes, pipes and $ in them need no escaping. Environment: PHONE (user@address), PHONE_PASS.
# The Wi-Fi address, when known, is kept in ~/.config/surya-lab/phone-wifi-address.

PHONE_PASS=${PHONE_PASS:-147147}
PHONE_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=5"
export SSHPASS="$PHONE_PASS"

phone_find() {
	[ -n "${PHONE:-}" ] && sshpass -e ssh $PHONE_OPTS "$PHONE" true 2>/dev/null && return 0
	for addr in 172.16.42.1 $(cat "$HOME/.config/surya-lab/phone-wifi-address" 2>/dev/null); do
		if sshpass -e ssh $PHONE_OPTS "user@$addr" true 2>/dev/null; then PHONE="user@$addr"; export PHONE; return 0; fi
	done
	echo "the phone does not answer over USB or Wi-Fi" >&2; return 1
}

phone_sh() { sshpass -e ssh $PHONE_OPTS "$PHONE" 'export XDG_RUNTIME_DIR=/run/user/$(id -u); sh -s'; }

# sudo -S reads exactly one line - the password - and the shell it starts reads the rest
phone_root() { { printf '%s\n' "$PHONE_PASS"; cat; } | sshpass -e ssh $PHONE_OPTS "$PHONE" "sudo -S -p '' sh -s"; }

phone_put() { sshpass -e scp $PHONE_OPTS "$1" "$PHONE:$2"; }

phone_uptime() { echo 'cut -d. -f1 /proc/uptime' | phone_sh 2>/dev/null || true; }

phone_reboot() {
	echo 'systemd-run --on-active=2 systemctl reboot >/dev/null' | phone_root || true
	sleep 20
	for _ in $(seq 1 90); do
		u=$(phone_uptime); [ -n "$u" ] && [ "$u" -lt 300 ] && return 0
		sleep 4; phone_find 2>/dev/null || true
	done
	echo "the phone did not come back" >&2; return 1
}
