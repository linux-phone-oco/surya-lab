# sleep-adsp-awake: what was measured (surya-keeper-5, 2026-11-17)
Kernel 7.1.0-sm7150-calls (kept) vs a one-shot try 7.1.0-sm7150-calls-idle (same tree + the patch beside, plus the patched qcom_wdt in updates/).
- Kept kernel: no soundwire_qcom stay_awake parameter, none on its command line: "without stay_awake" is the kept kernel. Quiet cycle 15 bt-on: cxsd 0, aosd 0, ddr 0, adsp 0 before and after; modem and cdsp count.
- Idle, clk_summary: LPASS_HW_MACRO enable count 3 (holders listed: tx, rx, va macros, the LPI pinctrl, deviceless); rx/tx/va macros and both SoundWire controllers runtime-suspended about 95% of the time.
- Patch (beside): rx, tx, va macro runtime suspend also drops their macro and dcodec clocks (the DSP votes), resume takes them first. Same idea as Qualcomm's 2026 series moving the macros to the PM clock framework (lkml 2026-07-07).
- With the patch: a trace of clk_enable/clk_disable showed LPASS_HW_MACRO and TX_CORE_MCLK disabled on macro suspend (the vote does drop), yet clk_summary kept showing counts 3 and 4 afterwards (not explained: not known yet). Cycle 15 bt-on on the try kernel: adsp 0, cxsd 0, aosd 0 before and after - no change. Health on the try: 35 pass, 0 fail (sound checks pass).
- Awake-idle, stopping q6voiced, devlab-call-uplink, iio-sensor-proxy, hkdm, pulseaudio one after another: adsp count stays 0.
- pm_genpd_summary: Linux holds cx on (88c000.serial and a88000.serial active; the Bluetooth UART and the console), mx on; lcx and lmx off; the adsp's own domains are off from Linux's side.
- A cycle taken while polling the phone over ssh hung it (needed the author's hands); the same cycle left alone ends in 3 minutes (ssh answers slowly for about a minute after resume). Do not poll during a cycle.
