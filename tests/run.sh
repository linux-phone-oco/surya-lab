#!/bin/sh
# Run the automatic checks on the phone and keep the results: tests/results/DATE-TIME.jsonl, each
# line a check plus the run (device, time, kernel, shell). Read-only on the phone.
#   tests/run.sh            environment: PHONE (user@172.16.42.1), PHONE_PASS (147147)
set -eu
P=${PHONE:-user@172.16.42.1}; export SSHPASS=${PHONE_PASS:-147147}
O="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=6"
D=$(cd "$(dirname "$0")" && pwd)
sshpass -e ssh $O "$P" true 2>/dev/null || { echo "the phone does not answer over SSH - nothing tested" >&2; exit 2; }
sshpass -e scp $O "$D/automatic/checks.sh" "$P:/tmp/surya-checks.sh"
at=$(date -u +%Y-%m-%dT%H:%M:%SZ); id=$(date -u +%Y%m%d-%H%M)
kernel=$(sshpass -e ssh $O "$P" uname -r)
shell=$(sshpass -e ssh $O "$P" 'basename $(readlink /var/lib/tinydm/default-session.desktop 2>/dev/null) .desktop 2>/dev/null || true; systemctl is-active -q plasma-mobile 2>/dev/null && echo plasma-mobile' | grep -v '^$' | head -1)
mkdir -p "$D/results"; out="$D/results/$id.jsonl"
sshpass -e ssh $O "$P" "echo $SSHPASS | sudo -S -p '' sh /tmp/surya-checks.sh" \
  | sed "s/^{/{\"run\":\"$id\",\"device\":\"xiaomi-surya\",\"at\":\"$at\",\"kernel\":\"$kernel\",\"shell\":\"${shell:-unknown}\",/" > "$out"
echo "$(grep -c '"pass"' "$out") pass, $(grep -c '"fail"' "$out") fail, $(grep -c '"skip"' "$out") skip -> $out"
