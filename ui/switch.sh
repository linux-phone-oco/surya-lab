#!/bin/sh
# Switch the phone's shell in place - no reflash, so everything else (sound fixes, settings) stays.
#
#   ui/switch.sh SHELL        SHELL: phosh | plasma-mobile | gnome-mobile | sxmo
#
# Uses postmarketOS's own UI packages: installs the shell's package (replacing the current shell's
# when they cannot coexist), points tinydm at the shell's session, reboots, and checks the shell, the audio DSP and the speaker.
# Environment: PHONE (default user@172.16.42.1), PHONE_PASS (default 147147).
set -eu
SHELL_NAME=${1:?usage: ui/switch.sh phosh|plasma-mobile|gnome-mobile|sxmo}
P=${PHONE:-user@172.16.42.1}; export SSHPASS=${PHONE_PASS:-147147}
O="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=6"
s() { sshpass -e ssh $O "$P" "export XDG_RUNTIME_DIR=/run/user/\$(id -u); $*"; }
r() { sshpass -e ssh $O "$P" "echo $SSHPASS | sudo -S -p '' sh -c '$*'"; }
case $SHELL_NAME in
  phosh)         pkg=postmarketos-ui-phosh;         session=phosh;         proc=phosh ;;
  plasma-mobile) pkg=postmarketos-ui-plasma-mobile; session=plasma-mobile; proc=plasmashell ;;
  gnome-mobile)  pkg=postmarketos-ui-gnome-mobile;  session=gnome;         proc=gnome-shell ;;
  sxmo)          pkg=postmarketos-ui-sxmo-de-sway;  session=swmo;          proc=sway ;;
  *) echo "unknown shell: $SHELL_NAME" >&2; exit 2 ;;
esac
# the installed shell that is not the target (a half-finished earlier switch may have both)
current=$(s "apk info 2>/dev/null | grep '^postmarketos-ui-' | grep -vE -- '-(openrc|systemd|extras.*|web|default-osk)\$' | grep -vx $pkg | head -1")
echo "now: $current -> $pkg"
extra=$(s "apk search -q $pkg-systemd 2>/dev/null | grep -x $pkg-systemd || true")
# postmarketOS expects one UI at a time: when the new one cannot install beside the current one
# (a conflict, or files the other UI owns), the current one is removed first. Switch back any time.
if ! r "apk add -q $pkg $extra" >/tmp/apk.out 2>&1 || grep -q '^ERROR' /tmp/apk.out; then
  if [ -n "$current" ] && [ "$current" != "$pkg" ]; then
    echo "$pkg cannot sit beside $current ($(grep -m1 '^ERROR' /tmp/apk.out | cut -c1-90)): replacing it"
    r "apk del -q $current" >/dev/null 2>&1
    r "apk fix -q $pkg $extra || apk add -q $pkg $extra" >/tmp/apk.out 2>&1 || { tail -5 /tmp/apk.out >&2; exit 1; }
  else
    tail -5 /tmp/apk.out >&2; exit 1
  fi
fi
echo "installed: $(s "apk info 2>/dev/null | grep '^postmarketos-ui-' | tr '\\n' ' '")"
# One login manager for every shell: tinydm starts the chosen session directly, the same way for
# all of them, so shells compare fairly and switching stays scriptable.
r "systemctl enable --force -q tinydm.service"
dm=$(s 'basename $(readlink /etc/systemd/system/display-manager.service)')
echo "login manager: $dm"
if [ "$dm" = tinydm.service ]; then
  f=$(s "ls /usr/share/wayland-sessions/ | grep -i '^$session' | head -1")
  [ -n "$f" ] || { echo "no session file for $session in /usr/share/wayland-sessions" >&2; exit 1; }
  r "tinydm-set-session -f -s /usr/share/wayland-sessions/$f" && echo "tinydm session: $f"
fi
r "systemd-run --on-active=2 systemctl reboot" >/dev/null; echo "rebooting"
sleep 25
for _ in $(seq 1 80); do u=$(s 'cut -d. -f1 /proc/uptime' 2>/dev/null || true); [ -n "$u" ] && [ "$u" -lt 400 ] && break; sleep 3; done
while [ "$(s 'cut -d. -f1 /proc/uptime' 2>/dev/null || echo 0)" -lt 60 ]; do sleep 3; done
echo "== $SHELL_NAME after boot =="
# a shell finishes starting a little after login: give it up to 90 s
for _ in $(seq 1 30); do s "pgrep -x $proc >/dev/null" && break; sleep 3; done
echo "shell running: $(s "pgrep -x $proc >/dev/null && echo yes || echo NO")"
echo "audio DSP crashes: $(r 'dmesg | grep -c "crash detected in adsp"'), sound card: $(s 'grep -c "POCO X3" /proc/asound/cards')"
echo "speaker: $(s 'pactl list sinks 2>/dev/null | grep -A4 "Name: alsa_output.platform-sound.HiFi__Speaker" | grep "Sample Spec" | tr -d "\t" || echo none')"
