#!/bin/sh
# Switch the phone's shell in place - no reflash, so everything else (sound fixes, settings) stays.
#
#   ui/switch.sh SHELL        SHELL: phosh | plasma-mobile | gnome-mobile | sxmo
#
# Uses postmarketOS's own UI packages: installs the shell's package (removing the other shell's if
# apk says they conflict), lets the package bring its login manager if it has one, else points
# tinydm at the shell's session, reboots, and checks the shell, the audio DSP and the speaker.
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
current=$(s "apk info 2>/dev/null | grep '^postmarketos-ui-' | grep -vE -- '-(openrc|systemd|extras.*|web|default-osk)\$' | head -1")
echo "now: $current -> $pkg"
extra=$(s "apk search -q $pkg-systemd 2>/dev/null | grep -x $pkg-systemd || true")
if ! r "apk add -q $pkg $extra" 2>/tmp/apk.err; then
  grep -q -i conflict /tmp/apk.err && [ -n "$current" ] && [ "$current" != "$pkg" ] || { cat /tmp/apk.err >&2; exit 1; }
  echo "conflicts with $current: replacing it"
  r "apk del -q $current $current-systemd 2>/dev/null; apk add -q $pkg $extra"
fi
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
echo "shell running: $(s "pgrep -x $proc >/dev/null && echo yes || echo NO")"
echo "audio DSP crashes: $(r 'dmesg | grep -c "crash detected in adsp"'), sound card: $(s 'grep -c "POCO X3" /proc/asound/cards')"
echo "speaker: $(s 'pactl list sinks 2>/dev/null | grep -A4 "Name: alsa_output.platform-sound.HiFi__Speaker" | grep "Sample Spec" | tr -d "\t" || echo none')"
