# Host-side proof for tests/health/base/pon-reason.sh: on a copy of the PMIC's registers (a bite: POFF_REASON1 PMIC_WD)
# the check passes and names it; with no regmap it skips. Run: sh tests/host/pon-reason-test.sh
set -eu
here=$(cd "$(dirname "$0")/../.." && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
echo 'say() { echo "$1 $2 $3 $4"; }' > "$tmp/lib.sh"
sed "s#/usr/lib/lpoco-health/lib.sh#$tmp/lib.sh#" "$here/tests/health/base/pon-reason.sh" > "$tmp/check.sh"
printf '0808: 80\n080a: 00\n080c: 04\n080e: 00\n' > "$tmp/registers"
out=$(PON_REGMAP_REGISTERS="$tmp/registers" sh "$tmp/check.sh")
case "$out" in *" pass "*"PMIC_WD"*) ;; *) echo "FAIL a bite is not named: $out"; exit 1 ;; esac
out=$(PON_REGMAP_REGISTERS="$tmp/none" sh "$tmp/check.sh")
case "$out" in *" skip "*) ;; *) echo "FAIL no regmap is not a skip: $out"; exit 1 ;; esac
printf '0808: 00\n' > "$tmp/partial"
out=$(PON_REGMAP_REGISTERS="$tmp/partial" sh "$tmp/check.sh")
case "$out" in *"POFF_REASON1=0x?? (unread)"*) ;; *) echo "FAIL unread register not shown as unread: $out"; exit 1 ;; esac
printf '0100: 12\n' > "$tmp/other"
out=$(PON_REGMAP_REGISTERS="$tmp/other" sh "$tmp/check.sh")
case "$out" in *" skip "*) ;; *) echo "FAIL a non-PON regmap is not a skip: $out"; exit 1 ;; esac
echo ok
