# Read-only: the PMIC's last reset reason, raw and named, so a power cycle, a bite and a PS_HOLD reset tell apart.
# Mainline qcom-pon exposes no reason attribute, so the registers are read from the debugfs regmap of the PMIC
# (pon@800: PON_REASON1 0x808, WARM_RESET_REASON1 0x80a, POFF_REASON1 0x80c, SOFT_RESET_REASON1 0x80e).
# A pass names the reason; a skip says why it cannot be read (no debugfs, no regmap). Nothing is changed.
# PON_REGMAP_REGISTERS names another registers file (the check is tested on a copy of one).
. /usr/lib/lpoco-health/lib.sh
regs="${PON_REGMAP_REGISTERS:-$(ls /sys/kernel/debug/regmap/*0-00*/registers 2>/dev/null | head -1)}"
if [ -z "$regs" ] || [ ! -r "$regs" ]; then
	say pon-reason-read power-pon skip "no PMIC regmap in debugfs (mount -t debugfs, CONFIG_REGMAP_DEBUGFS)"
	exit 0
fi
reg() { sed -n "s/^0*$1: \([0-9a-fA-F][0-9a-fA-F]\).*/\1/p" "$regs" | head -1; }
# names the set bits of a byte: name_bits HEX name0 name1 ... name7
name_bits() {
	v=$((0x$1)); shift; n=""; i=0
	for b in "$@"; do [ $((v >> i & 1)) -eq 1 ] && n="$n $b"; i=$((i + 1)); done
	echo "${n:- none}"
}
pon=$(reg 808); poff=$(reg 80c); warm=$(reg 80a); soft=$(reg 80e)
if [ -z "$pon" ] && [ -z "$poff" ]; then
	say pon-reason-read power-pon skip "the regmap ($regs) has no 0x808/0x80c: not a gen1/2 PON block"
	exit 0
fi
msg="PON_REASON1=0x${pon:-??} (power on by:$(name_bits "${pon:-0}" HARD_RESET SMPL RTC DC_CHG USB_CHG PON1 CBLPWR KPDPWR))"
msg="$msg POFF_REASON1=0x${poff:-??} (last power off by:$(name_bits "${poff:-0}" SOFT PS_HOLD PMIC_WD GP1 GP2 KPDPWR_AND_RESIN RESIN_N KPDPWR_N))"
msg="$msg WARM_RESET_REASON1=0x${warm:-??} SOFT_RESET_REASON1=0x${soft:-??}"
say pon-reason-read power-pon pass "$msg"
