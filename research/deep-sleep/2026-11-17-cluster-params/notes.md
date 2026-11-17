# surya-keeper-7, sleep-cluster-params (2026-11-17 ~16:05-16:40)

Tried: kernel 7.1.0-sm7150-calls+ booted once with the dtb cp.dtb (cluster-sleep-1 0x41002244, cluster-sleep-2 0x4100c244;
cp.dtb.diff), healthy 35 pass 0 fail. `way-back.sh cycle 15 bt-on` 8 times (with traces): cxsd, aosd, ddr Count 0 every time.

What the cycle did (read from ftrace, kept in trace-rpmh-s2idle.txt):
- The trace clock (sched_clock) stops in s2idle: machine_suspend begin..end looks like 1 ms, but the RTC counts 17 s of 15 asked,
  the cycle is a real 15 s sleep. Woken by irq 20 pm8xxx_rtc_alarm (pm_system_irq_wakeup kprobe), as planned.
- The last CPU entered psci_domain_idle_enter state=0x4100c244 (the new cluster-sleep-2): the cluster S2 was used (genpd
  power-domain-cluster idle_states: S2 Usage 1, S2idle 1, Rejected 0). The old 0x4100b244 / 0x41001244 params were not needed to differ.
- rpmh: at the end of dpm_suspend_noirq the CX (0x30000) and MX (0x30010) active votes are set to 0; the sleep flush
  (tcs 2 [sleep]) holds MC0, SH5, MM1, MM0, ACV all 0 and ONE valid vote: SH0 0x5003c data 0x60004003 (x=1, y=3).
  Same in 3 cycles. Before suspend (idle) the sleep-tagged icc votes are large (cpu0/cpu6 tag 3 peak 7.2/3.2 GB/s to EBI,
  90b6300.pmu 4.5 GB/s, USB 240000/700000 tag 7, BT UART 88c000 3200 tag 7, a88000 115 tag 7): they are dropped by the
  suspend callbacks (sleep MC0 0) but a88000.serial sets avg 1 peak 1 on its cfg path and 115 on its data path during suspend.
- debugfs qcom_aoss has prevent_aoss_sleep, prevent_cx_collapse, prevent_ddr_collapse, ddr_frequency_mhz (write-only, not read: unknown).
- ddr_stats: "DDR LPM Stat" counts 0 (0xd3 0xd3 0x11 0xd0) - DDR never entered a low power mode.
- modem (1216) and cdsp (54) sleep (stats grow ~15 s per cycle); adsp 0; apss/display/gpu/slpi/wpss stats files read empty.
- pinning cpufreq to the minimum changed nothing in the real suspend flush (idle flushes with big sleep votes are not suspend).

Not known: what holds AOSS/CX/DDR with an apps side that looks clean. Not tried: the SH0 x=1,y=3 residual's owner (which icc
path); the prevent_* knobs' meaning (AOSS QMP writes); XO (xo.lvl ARC 0x30090) and VRM votes; display RSC; USB (gadget still bound).
