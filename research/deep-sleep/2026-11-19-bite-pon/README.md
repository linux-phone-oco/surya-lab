# Why the attended run's reset read PON 0x03 and came back on calls+ (desk work, 2026-11-19, no phone)

## 1. Which reset was it
- The fuse (sleep/way-back.sh `fuse`) arms the APSS watchdog (qcom_wdt, 17c10000.watchdog): pick_wd refuses any node
  whose identity says PM8916. The PMIC watchdog (pm8916_wdt, PON_PMIC_WD_RESET_S2_CTL 0x56) was never armed.
  The attended step is named "arm the apss fuse and let the pmic watchdog bite": the name is wrong, the bite was APSS's.
  So the run could not have proven a PMIC bite whatever the PON read.
- The check `pon_reason` (procedures/steps checks.rs bite_seen) passes on "S2_CTL=0x07", "watchdog" or "reset_type=hard"; the
  script tests/health/base/pon-reason.sh prints none of these (it prints PON_REASON1/POFF_REASON1 names), so the check
  can only fail or match by luck: it does not read the PMIC bite.

## 2. The bit table (PON_REASON1, qpnp-power-on, ffs(bit)-1 indexes qpnp_pon_reason[])
index 0 = bit 0 HARD_RESET, 1 = SMPL, 2 = RTC, 3 = DC_CHG, 4 = USB_CHG, 5 = PON1, 6 = CBLPWR, 7 = KPDPWR.
tests/health/base/pon-reason.sh names the bits in this order. 0x03 = HARD_RESET + SMPL (two bits).
POFF_REASON1 (0x80c): bit0 SOFT, 1 PS_HOLD, 2 PMIC_WD (pm8916_wdt.c PON_POFF_REASON1_PMIC_WD = BIT(2)), 3 GP1, 4 GP2,
5 KPDPWR_AND_RESIN, 6 RESIN_N, 7 KPDPWR_N. Observed POFF 0x00, WARM_RESET 0x00: no PMIC_WD (so not the PMIC bite - consistent
with 1), and also no PS_HOLD and no SOFT.
Mainline qcom-pon.c (v7.3) exposes only the reboot-mode spare register; it never reads PON_REASON1 - the debugfs regmap is the only reader.

## 3. What an APSS bite leaves (not settled by reading)
APSS wdog bite resets the SoC; PMIC sees PS_HOLD deassert and acts on its PS_HOLD_RESET_CTL type, programmed by the
bootloader, not by mainline. HARD_RESET in PON_REASON1 says the PMIC did a hard (power-cycle) reset; SMPL together with it is
what a rail dropout during that cycle looks like. 0x03 with POFF 0x00 is therefore consistent with "SoC-side reset
turned into a PMIC hard reset", but no source read here gives POFF/PON for an APSS bite on PM6150: UNKNOWN. Settle it
cheaply by comparison, not theory: arm the same fuse twice on the same kernel and read PON/POFF each time, once from
a plain reboot (`systemctl reboot`) and once from `echo c > /proc/sysrq-trigger` for the baselines; a bite that reads
differently from both is a PMIC-seen bite; identical to the reboot means PON cannot tell them apart and the test
must use something else (pstore, a marker in the kernel log, boot counter file).

## 4. Why calls4 was not chosen: the one try is spent by the boot that uses it
lab-tools devlab kernel.rs: `kernel install` writes pmos-calls4+1-0.conf (one try); `kernel try` (what attended boot_once
runs) reboots into it, and systemd-boot decrements the counter at that boot: +0-1, an entry with no tries left sorts last.
Any reset after that boot - the fuse's included - boots the next entry: the kept calls+. The session's own comment says
"After a bite the next boot is a pm8916_wdt kernel, never calls+": false with a one-try entry. (The try was not consumed
before; the run's first try froze and the second was the good one - each installed anew.) The reboot after the bite
therefore proves nothing about calls4, and the run's last step "the phone restarts on a pm8916_wdt kernel" cannot pass.
Fix: arm the bite with a kernel that stays the default for the bite (keep it: `kernel keep calls4`, KEEP_TRIES 3, then unkeep),
or re-arm a try with `kernel install` + pending counter before the fuse, or have the program read the entry's counter before
the bite and refuse when none is left.
