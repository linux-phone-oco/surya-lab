#!/bin/sh
# SPDX-License-Identifier: MIT OR Apache-2.0
# Proof of bin/check-device-toml.sh against a stand-in release (file://): the newest release is the one used; a
# [kernels] device.toml is refused by an older reader naming the key and release, passes the newer; a release whose
# asset is not attached yet is skipped for the one before; a wrong sha256 is refused.
set -eu
here=$(cd "$(dirname "$0")/../.." && pwd)
w=$(mktemp -d); trap 'rm -rf "$w"' EXIT
asset=lpoco-lab-x86_64-unknown-linux-gnu
release() { # VERSION: a stand-in lpoco-lab that reads [kernels] only from 0.32.0 on
  d="$w/rel/lpoco-lab-v$1"; mkdir -p "$d"
  cat >"$d/$asset" <<STUB
#!/bin/sh
f=\$4
if [ "$1" = 0.24.0 ] && grep -q '^\[kernels\]' "\$f"; then echo "\$f is not read by lpoco-lab $1: unknown field kernels" >&2; exit 1; fi
echo "\$f: read by lpoco-lab $1"
STUB
  (cd "$d" && sha256sum "$asset" >"$asset.sha256")
}
release 0.24.0; release 0.32.1
printf '[device]\ncodename = "x"\n[kernels]\ntest = ["a"]\n' >"$w/device.toml"
run() { LPOCO_TAGS="$1" LPOCO_RELEASE_BASE="file://$w/rel" DEVICE_TOML="$w/device.toml" sh "$here/bin/check-device-toml.sh" 2>&1; }

out=$(run "lpoco-lab-v0.24.0") && { echo "FAIL: 0.24.0 passed a [kernels] device.toml"; exit 1; }
echo "$out" | grep -q kernels && echo "$out" | grep -q 0.24.0 || { echo "FAIL: not naming key and release: $out"; exit 1; }
out=$(run "lpoco-v0.99.0
lpoco-lab-v0.32.1
lpoco-lab-v0.24.0") || { echo "FAIL: newest lpoco-lab (0.32.1) refused: $out"; exit 1; }
echo "$out" | grep -q "against lpoco-lab-v0.32.1" || { echo "FAIL: not the newest: $out"; exit 1; }
out=$(run "lpoco-lab-v0.99.0
lpoco-lab-v0.32.1") || { echo "FAIL: an unattached newest was not skipped: $out"; exit 1; }
echo "$out" | grep -q "against lpoco-lab-v0.32.1" || { echo "FAIL: skip not to 0.32.1: $out"; exit 1; }
out=$(run "lpoco-lab-v0.99.0") && { echo "FAIL: no asset at all passed"; exit 1; }
echo "tampered" >>"$w/rel/lpoco-lab-v0.32.1/$asset"
out=$(run "lpoco-lab-v0.32.1") && { echo "FAIL: a wrong sha256 passed"; exit 1; }
echo "$out" | grep -q sha256 || { echo "FAIL: wrong sha not said: $out"; exit 1; }
echo "check-device-toml: 6 cases pass"
