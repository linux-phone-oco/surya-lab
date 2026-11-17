#!/bin/sh
# build-hexagonrpcd-sns.sh [OUTDIR] - the patched hexagonrpcd (hexagonrpc PR #27 at 40e5041 plus
# patches/hexagonrpcd-sns-reg-version.patch), static aarch64, on the lab machine (no meson needed).
# Prints the path of the stripped binary. Decision 2026-11-17-sensors-registry-kept-current.
set -eu
here=$(cd "$(dirname "$0")/.." && pwd)
out=${1:-${TMPDIR:-/tmp}/hexagonrpcd-sns-build}
rm -rf "$out"; mkdir -p "$out"
git clone -q https://github.com/linux-msm/hexagonrpc.git "$out/src"
git -C "$out/src" fetch -q origin pull/27/head:pr27
git -C "$out/src" checkout -q 40e5041
git -C "$out/src" apply "$here/patches/hexagonrpcd-sns-reg-version.patch"
cd "$out/src"
aarch64-linux-gnu-gcc -static -O2 -D_GNU_SOURCE -Iinclude -Ihexagonrpcd -o "$out/hexagonrpcd-sns" \
	hexagonrpcd/apps_mem.c hexagonrpcd/apps_std.c hexagonrpcd/interface/*.c hexagonrpcd/hexagonfs*.c \
	hexagonrpcd/iobuffer.c hexagonrpcd/listener.c hexagonrpcd/localctl.c hexagonrpcd/rpcd.c \
	hexagonrpcd/rpcd_builder.c libhexagonrpc/error.c libhexagonrpc/handle.c libhexagonrpc/hexagonrpc.c \
	libhexagonrpc/interface/remotectl.c libhexagonrpc/session.c
aarch64-linux-gnu-strip "$out/hexagonrpcd-sns"
echo "$out/hexagonrpcd-sns"
