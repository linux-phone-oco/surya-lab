# The way back, measured (2026-11-17, surya-keeper-3), kernel 7.1.0-sm7150-calls+

| try | what | result |
|---|---|---|
| accident | `unbind` of 17c10000.watchdog (hardware had been left armed) | the phone reset by itself ~1-2 min later, booted the stock kernel, answered; pstore empty |
| dry run 1 | `way-back.sh fuse 30` on the idle phone | reset 31 s after arming, reachable again after ~1.5 min, no hands; the journal of the dead boot kept the marker and `watchdog0: pretimeout event` (bark), pstore empty |
| probe | `cycle 20 50 probe` (Bluetooth on): s2idle entered 13:37:50, left 13:37:53 | the watchdog was NOT stopped: bark at 13:38:21 = 31 s after arming, reset followed; the patched parameter works across a real suspend entry |
| cycle | `cycle 15` (Bluetooth rfkill-blocked, USB gadget let go, fuse 30 s) | the journal ends 13:41:01 at the cycle marker (no `PM: suspend entry` line), reset 13:41:32 = 30 s after arming, back by 13:41:55 with no hands: the hang reproduces at once and the way back brought the phone home; suspend_stats 0/0 |

Findings: the qcom watchdog counts 32 s at most (kpss data: 0xFFFFF ticks at 32 kHz), BusyBox `-T 50` fails with EINVAL and the
30 s default holds, so the fuse is 30 s and the sleep at most 15 s. ramoops/pstore does NOT survive the watchdog's reset (empty
every time): the log that survives is the persistent journal, synced before the arm. The PMIC RTC cannot be set
(`hwclock -w`: No such device, no allow-set-time) - alarms work relative to its 1970 clock, so it is not a way back and not a cause.

After the watchdog resets the speaker amplifier 0x4c read digital volume 0x00 (silent) and the health check `amp-volume-0x4c`
failed once (boot of 13:41); one clean reboot cured it (health back to the 5 known gaps). A bite is an unclean reset of the SoC
while the amplifiers keep power: after a try that ended in a bite, reboot once cleanly and read the health before the next try.
