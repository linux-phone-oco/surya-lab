#!/bin/sh
# sensors-install.sh - ON the phone, as root: make the sensors helper lasting (backlog sensors-without-crash).
# Expects the patched daemon at /tmp/hexagonrpcd-sns (lab/build-hexagonrpcd-sns.sh, then devlab phone put).
# The ADSP crashed the audio DSP when its sensors service could not write the registry; the patched daemon serves
# a writable copy (the state root) of the package tree. Idempotent; the stock units stay as the package has them.
set -eu
P=/usr/share/qcom/sm7150/Xiaomi/surya; S=/var/lib/hexagonrpcd-sensors; U=hexagonrpcd-adsp-sensorspd.service
[ -x /tmp/hexagonrpcd-sns ] || { echo "no /tmp/hexagonrpcd-sns" >&2; exit 1; }
install -m 755 /tmp/hexagonrpcd-sns /usr/local/bin/hexagonrpcd-sns
if [ ! -d $S ]; then
	mkdir -p $S; cp -a $P/. $S/
	mkdir -p $S/sensors/persist/registry; cp -a $S/sensors/registry $S/sensors/persist/registry/registry
	chown -R fastrpc:fastrpc $S
fi
mkdir -p /etc/systemd/system/$U.d
printf '[Service]\nExecStart=\nExecStart=/usr/local/bin/hexagonrpcd-sns -f /dev/fastrpc-adsp -d adsp -s -R %s\n' $S \
	> /etc/systemd/system/$U.d/10-state-root.conf
[ -L /etc/systemd/system/$U ] && rm /etc/systemd/system/$U       # unmask (rootpd stays masked)
systemctl daemon-reload
echo "installed: $(ls $S | tr '\n' ' ')"
