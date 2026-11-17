# What the phone has for a way back from a suspend that does not return (2026-11-17, surya-keeper-3)

Read on the running kernel 7.1.0-sm7150-calls+ (read only) and in mainline drivers/watchdog/qcom-wdt.c:

- Watchdog: 17c10000.watchdog, compatible qcom,apss-wdt-sm7150 / qcom,kpss-wdt, driver qcom_wdt (module), /dev/watchdog0.
  Nobody holds it open (RuntimeWatchdogUSec=0). CONFIG_WATCHDOG_SYSFS and _NOWAYOUT are off, so it is armed through
  the char device (BusyBox `watchdog -T SECONDS`) and stops on a magic close ("V").
- qcom_wdt registers LATE system-sleep ops: qcom_wdt_suspend stops an active watchdog, qcom_wdt_resume starts it again.
  So the stock watchdog does not cover a hang inside s2idle, only one before the late phase.
- pstore: CONFIG_PSTORE_RAM, ramoops reserved memory 4 MiB at 0x9d800000 (console 1 MiB, pmsg 2 MiB, 512 KiB
  records, max_reason 2); /sys/fs/pstore is empty after the force reboot of the first hang.
- RTC: rtc0 = pm8xxx rtc@6000, reads 1970-01-15 (it loses its time); `hwclock -w -u` sets it.
- No CONFIG_PM_DEBUG (no pm_test), no hung-task, softlockup or DPM watchdog: nothing in the kernel times a stuck suspend out.
- kernel.panic = 120 at run time (a panic reboots after 2 min).
- Built the stock driver with one parameter, keep_armed_in_suspend (patches/qcom-wdt-keep-armed-in-suspend.patch);
  CONFIG_MODVERSIONS is off, so a module with the same vermagic loads: `make O=... drivers/watchdog/qcom-wdt.ko`
  gives vermagic 7.1.0-sm7150-calls+ SMP preempt mod_unload aarch64, equal to `uname -r` and the other modules.
