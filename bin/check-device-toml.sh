#!/bin/sh
# SPDX-License-Identifier: MIT OR Apache-2.0
# Checks device.toml with the newest lpoco-lab release (decision 2026-11-19-host-follows-releases (c)), so a file the
# host cannot read cannot land: downloads that release's lpoco-lab asset, checks its sha256, and runs
# `lpoco-lab manifest check --device device.toml`. The host follows each release within minutes and
# `lpoco-attended check --host` covers the lag at run time, so no pin is read (lab.toml is private).
#   LPOCO_TAGS          the lpoco-lab release tags, newest first, one per line (else `gh release list`, needs GH_TOKEN)
#   LPOCO_RELEASE_BASE  where releases are (default: github.com/linux-phone-oco/lab-tools/releases/download)
#   DEVICE_TOML         the file to check (default: device.toml)
set -eu
device="${DEVICE_TOML:-device.toml}"
base="${LPOCO_RELEASE_BASE:-https://github.com/linux-phone-oco/lab-tools/releases/download}"
asset="lpoco-lab-x86_64-unknown-linux-gnu"
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
fail() { echo "check-device-toml: $*" >&2; exit 1; }

if [ -n "${LPOCO_TAGS:-}" ]; then
  printf '%s\n' "$LPOCO_TAGS" >"$work/tags"
else
  gh release list -R linux-phone-oco/lab-tools --limit 40 --json tagName,isDraft,isPrerelease \
    -q '.[] | select(.isDraft | not) | select(.isPrerelease | not) | .tagName' >"$work/tags" ||
    fail "the releases of linux-phone-oco/lab-tools could not be listed"
fi
# the newest lpoco-lab release whose asset is already attached (a release's assets arrive a minute after it)
tag=""
for t in $(grep '^lpoco-lab-v' "$work/tags" | head -5); do
  if curl -fsSL -o "$work/lpoco-lab" "$base/$t/$asset" && curl -fsSL -o "$work/sha256" "$base/$t/$asset.sha256"; then tag=$t; break; fi
done
[ -n "$tag" ] || fail "none of the newest lpoco-lab releases has its $asset and .sha256 attached"
want=$(cut -d' ' -f1 "$work/sha256")
have=$(sha256sum "$work/lpoco-lab" | cut -d' ' -f1)
[ -n "$want" ] && [ "$want" = "$have" ] || fail "the $tag download does not match its .sha256"
chmod +x "$work/lpoco-lab"

echo "check-device-toml: $device against $tag"
"$work/lpoco-lab" manifest check --device "$device" || {
  echo "check-device-toml: $tag does not read $device (above)" >&2
  exit 1
}
