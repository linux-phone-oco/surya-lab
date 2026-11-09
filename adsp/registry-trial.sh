#!/bin/sh
# Put the phone's ADSP sensor-registry setup into one named state, then count ADSP crashes.
#
#   registry-trial.sh STATE [SECONDS]      (runs on the lab machine; the phone over USB SSH)
#
#   packaged  the registry exactly as Nura ships it, no -R drop-in, no version marker: the baseline
#   real      the phone's own registry from its persist partition, readable by the daemon
#             (root:root, files 0644), served with -R, plus the persist version marker
#
# Background: the ADSP's sensor process asks hexagonrpcd for its registry; when that fails it
# asserts (SNS_REG_INIT) and takes the whole ADSP - and audio - down with it, every 13-65 s.
#
# Finding (2026-11-09): no registry state fixes it - not the packaged one, not the phone's own from
# persist (readable, with the version marker). The firmware rebuilds the registry from its configs
# and needs writes hexagonrpcd refuses. Not starting the sensors service stops the crashes
# (sensors do not work either way); see linux-phone-oco/docs backlog adsp-sensor-crash-loop.
# Each state is applied from scratch, so trials do not depend on each other.
set -e
STATE=${1:?usage: registry-trial.sh packaged|real [SECONDS]}; WINDOW=${2:-150}
PHONE=user@172.16.42.1; export SSHPASS=147147
O="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=8"
ssh_() { sshpass -e ssh $O "$PHONE" "$@"; }
root() { ssh_ "echo 147147 | sudo -S -p '' $*"; }

T=$(mktemp); trap 'rm -f $T' EXIT
cat > "$T" <<'ROOT'
set -e
S=/usr/share/qcom/sm7150/Xiaomi/surya/sensors; D=/etc/systemd/system
[ -d $S/registry.packaged ] || cp -a $S/registry $S/registry.packaged
rm -rf $S/registry; cp -a $S/registry.packaged $S/registry
rm -f $S/sns_reg_version; rm -rf $D/hexagonrpcd-adsp-sensorspd.service.d $D/hexagonrpcd-adsp-rootpd.service.d
if [ "$1" = real ]; then
  mkdir -p /tmp/persist; mount -o ro "$(readlink -f /dev/disk/by-partlabel/persist)" /tmp/persist
  rm -rf $S/registry; mkdir $S/registry
  cp /tmp/persist/sensors/registry/registry/* $S/registry/          # contents only: not owner or mode
  cp /tmp/persist/sensors/registry/sns_reg_version $S/sns_reg_version
  umount /tmp/persist
  for u in sensorspd rootpd; do
    mkdir -p $D/hexagonrpcd-adsp-$u.service.d; X=""; [ $u = sensorspd ] && X="-s"
    printf '[Service]\nExecStart=\nExecStart=/usr/bin/hexagonrpcd -f /dev/fastrpc-adsp -d adsp %s -R /usr/share/qcom/sm7150/Xiaomi/surya\n' "$X" > $D/hexagonrpcd-adsp-$u.service.d/10-root.conf
  done
fi
chown -R root:root $S; find $S -type d -exec chmod 755 {} +; find $S -type f -exec chmod 644 {} +
systemctl daemon-reload; systemctl restart hexagonrpcd-adsp-rootpd hexagonrpcd-adsp-sensorspd
echo "state $1: $(ls $S/registry | wc -l) registry files, owner $(stat -c %U:%G $S/registry/sns_reg_config) mode $(stat -c %a $S/registry/sns_reg_config), marker: $([ -e $S/sns_reg_version ] && echo yes || echo no), -R: $([ -d $D/hexagonrpcd-adsp-sensorspd.service.d ] && echo yes || echo no)"
ROOT
sshpass -e scp $O "$T" "$PHONE:/tmp/registry-state.sh"
root "sh /tmp/registry-state.sh $STATE"
t0=$(ssh_ 'cut -d. -f1 /proc/uptime')
echo "watching ${WINDOW}s from uptime ${t0}s ..."
sleep "$WINDOW"
# count by timestamp, not by total: the kernel's ring buffer rotates and old lines fall out
n=$(root "dmesg" | awk -v t="$t0" -F'[][]' '$2+0 > t' | grep -c 'crash detected in adsp')
echo "RESULT $STATE: $n ADSP crash(es) in ${WINDOW}s"
root "dmesg" | awk -v t="$t0" -F'[][]' '$2+0 > t' | grep -E 'crash detected in adsp' | sed 's/^\[ *\([0-9.]*\)\].*/  crash at \1s/' | head -6
echo "what hexagonrpcd said in the window (most frequent first):"
root "journalctl -u hexagonrpcd-adsp-sensorspd --since -${WINDOW}s --no-pager" | sed 's/.*hexagonrpcd\[[0-9]*\]: //' | grep -v '^--' | cut -c1-110 | sort | uniq -c | sort -rn | head -5
