#!/bin/sh
# Run the automatic checks on the phone and keep the results: tests/results/DATE-TIME.jsonl, each
# line a check plus the run (device, time, kernel, shell). Read-only on the phone; finds it over USB
# or Wi-Fi (lib/phone.sh).
set -eu
D=$(cd "$(dirname "$0")" && pwd)
. "$D/../lib/phone.sh"
phone_find || { echo "nothing tested" >&2; exit 2; }
at=$(date -u +%Y-%m-%dT%H:%M:%SZ); id=$(date -u +%Y%m%d-%H%M%S)   # per second: two runs in a minute keep both
kernel=$(echo 'uname -r' | phone_sh)
shell=$(phone_sh <<'CMDS'
basename "$(readlink /var/lib/tinydm/default-session.desktop 2>/dev/null)" .desktop 2>/dev/null
systemctl is-active -q plasma-mobile 2>/dev/null && echo plasma-mobile
true   # a shell that is not running is an answer, not a failure
CMDS
)
shell=$(echo "$shell" | grep -v '^$' | head -1)
mkdir -p "$D/results"; out="$D/results/$id.jsonl"
phone_root < "$D/automatic/checks.sh" \
	| sed "s/^{/{\"run\":\"$id\",\"device\":\"xiaomi-surya\",\"at\":\"$at\",\"kernel\":\"$kernel\",\"shell\":\"${shell:-unknown}\",/" > "$out"
echo "$(grep -c '"pass"' "$out") pass, $(grep -c '"fail"' "$out") fail, $(grep -c '"skip"' "$out") skip -> $out"
