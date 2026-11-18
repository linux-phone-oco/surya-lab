#!/bin/sh
# Installs ikb, the recording command, from its pinned release (grenudi/ideal-knowledge-base): the binary
# for this machine, checked against the release's own checksums before it is installed.
set -eu
version="${IKB_VERSION:-0.6.1}"
arch=$(uname -m)
case "$arch" in x86_64 | aarch64) ;; *) echo "install-ikb: no ikb build for $arch" >&2; exit 1 ;; esac
target="$arch-unknown-linux-musl"; name="ikb-v$version-$target"
base="https://github.com/grenudi/ideal-knowledge-base/releases/download/ikb-v$version"
dest="${IKB_DEST:-$HOME/.local/bin}"; work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
curl -fsSL -o "$work/$name.tar.gz" "$base/$name.tar.gz"
curl -fsSL -o "$work/SHA256SUMS" "$base/SHA256SUMS-$target"
want=$(grep " \./$name.tar.gz\$\| $name.tar.gz\$" "$work/SHA256SUMS" | cut -d' ' -f1)
have=$(sha256sum "$work/$name.tar.gz" | cut -d' ' -f1)
[ -n "$want" ] && [ "$want" = "$have" ] || { echo "install-ikb: the download does not match the release's checksum" >&2; exit 1; }
tar -xzf "$work/$name.tar.gz" -C "$work"
mkdir -p "$dest" && install -m 755 "$work/$name/ikb" "$dest/ikb"
echo "ikb $version installed in $dest"
# completions for the shells this machine has, each asking ikb as you type (nushell: ikb completions nushell)
data="${XDG_DATA_HOME:-$HOME/.local/share}"; conf="${XDG_CONFIG_HOME:-$HOME/.config}"
if command -v bash >/dev/null 2>&1; then mkdir -p "$data/bash-completion/completions" && "$dest/ikb" completions bash > "$data/bash-completion/completions/ikb"; fi
if command -v fish >/dev/null 2>&1; then mkdir -p "$conf/fish/completions" && "$dest/ikb" completions fish > "$conf/fish/completions/ikb.fish"; fi
if command -v zsh >/dev/null 2>&1; then mkdir -p "$data/zsh/site-functions" && "$dest/ikb" completions zsh > "$data/zsh/site-functions/_ikb"; fi
echo "ikb completions written for the shells found"
