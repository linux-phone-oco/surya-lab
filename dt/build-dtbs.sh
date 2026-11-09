#!/bin/sh
# Build one board's DTB at a kernel commit and at its parent, to compare what a patch changes.
#
#   build-dtbs.sh KERNEL_DIR [DTB] [OUT_DIR]
#
# DTB defaults to qcom/sm7150-xiaomi-surya-huaxing.dtb. NOTE the target is relative to
# arch/arm64/boot/dts/: passing the full path doubles it and make finds no rule.
# Leaves OUT_DIR/patch.dtb, OUT_DIR/base.dtb and the kernel's own dtc at /tmp/o-patch/scripts/dtc/dtc.
set -e
K=${1:?usage: build-dtbs.sh KERNEL_DIR [DTB] [OUT_DIR]}
DTB=${2:-qcom/sm7150-xiaomi-surya-huaxing.dtb}
OUT=${3:-.}
cd "$K"
start=$(git symbolic-ref -q --short HEAD || git rev-parse HEAD)
build() {  # build NAME REV
  # resolve first: HEAD~1 means something else once HEAD has moved (and a shallow clone has no parent of it)
  rev=$(git rev-parse "$2")
  git checkout -q "$rev"
  o=/tmp/o-$1; rm -rf "$o"
  make -s ARCH=arm64 O="$o" defconfig >/dev/null
  make -j"$(nproc)" ARCH=arm64 O="$o" "$DTB" >"$o.log" 2>&1 || { tail -20 "$o.log"; exit 1; }
  cp "$o/arch/arm64/boot/dts/$DTB" "$OUT/$1.dtb"
  echo "$1: $OUT/$1.dtb ($(git rev-parse --short "$rev"))"
}
build patch HEAD
build base HEAD~1
git checkout -q "$start"
