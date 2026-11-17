# Why cxsd, aosd and ddr never count on surya - research, 2026-11-17 (surya-sleep-floor-research)

Two read-only researchers (mainline floor requirements; observed Android / pmOS on SM7150) plus the recorded
cycles (research/deep-sleep/2026-11-17-cluster-params, ...-adsp-floor). Nothing on the phone was touched.

## What the counters are
- cxsd / aosd / ddr are the SoC's own counters in the AOSS message RAM (rpmh-stats, 0xc3f0000), read by
  qcom_stats (debugfs). sm7150 uses the generic `qcom,rpmh-stats` (3 records, DDR stats at 0xb8, no
  "Client Votes" - that field exists only for the older RPM layouts), so the kernel cannot name the blocking
  client for us. The DDR block's magic key matched (ddr_stats file exists), so the layout is right.
- They count only when the always-on side (AOSS/AOP) really takes CX, the XO and DDR down: needs every RSC
  client - Apps, display, GPU/GMU, modem, ADSP, CDSP, SLPI - to have no active vote and each sleep set flushed.
  Maulik Shah (2021): the SoC count rises only if "all subsystems ... power down".

## What the recorded cycles say (surya)
- Cluster state 0x4100c244 entered (genpd idle_states usage 1, rejected 0) in a real 15 s s2idle; CX/MX
  active votes 0; sleep set zero except SH0 (0x5003c) x=1,y=3; counters 0 in 8 cycles.
- Floor tests stopped adsp, then adsp+cdsp+modem: still 0. BUT a remoteproc stopped by Linux after it ran is
  not a DSP that never ran: the votes it made on RPMh (its own DRV) are not cleared by a stop; nobody has
  shown they are. Both floor tests are therefore not clean subtractions. The clean one is a boot where the
  DSPs are never started (module_blacklist=qcom_q6v5_pas): then they cannot hold anything.
- clk_summary files of the floor runs are empty (0 lines): the clock holders were never read. genpd: usb30_prim_gdsc on
  (gadget), ufs_phy_gdsc on, cx/mx on at 256 in the awake read; the kernel command line (clk_ignore_unused /
  pd_ignore_unused?) is not recorded anywhere we found.
- sleep-tagged icc votes with QCOM_ICC_TAG_ALWAYS (tag 7: USB, both UARTs) go into the sleep set too; the
  a88000 serial keeps avg 1 / peak 1 across suspend - the likely owner of the SH0 residual (not shown).

## What others found
- Upstream proof it can count: Acer Aspire 1 (sc7180, TF-A, OSI mode): ddr, cxsd, aosd each Count 2 -
  lkml.rescloud.iu.edu/2308.1/00706.html (Nikita Travkin). apps_rsc in the cluster power domain, 3 cluster states.
- No sdm845 / sm8150 / sm8250 phone found with non-zero counts upstream; OnePlus 6: aosd 0 cxsd 0 (lkml 2208.2/01166).
- Floors reached after subtracting holders: X1E (Surface Pro 11) s2idle at CXSD/DDR/AOSD ~99.9% after removing the
  icc-bwmon DDR vote, PCIe vote, LPASS macro votes on the ADSP, a spinning console; AOSD appeared only with the
  CDSP running (github dwhinham/archiso-aarch64-sp11 #38). Retroid Pocket 5 (sm8250, s2idle) 0/0: camcc
  cam_cc_gdsc_clk vote, DSI PHY AHB clock, ADSP never sleeping (shuuri-labs/pocknix-os #161).
- QCS8550 handheld (docs row qcom-sleep-blockers): USB, PCIe and LPASS votes.
- Bjorn / Sadhasivam (lkml 2601.0/03006): on non-Chromebook pre-Hamoa SoCs s2idle behaves like s2ram; drivers
  must vote for what they need; SYSTEM_SUSPEND not offered (S2RAM series NACKed) - the deep state comes via CPU_SUSPEND only.
- Downstream (Pixel 4 floral, GPL, sm6150-pm.dtsi, lpm-levels.c, system_pm.c): the cluster levels are the same
  numbers as mainline sm7150 (0x4 / 0x124 / 0xB24); notify_rpm level only if rpmh controller idle; flush + wake timer
  written before entry; prints enabled clocks and bus clients on entry. No extra system-level mode found.
- Mainline rpmh-rsc: flush on genpd PRE_OFF (rpmh-rsc.c ~806,1106); sm7150 apps_rsc matches sc7180/sm8150 (tcs
  2/3/3/1, drv-id 2, cluster_pd, pdc ranges as sc7180). The tree has no smp2p sleepstate for sm7150 (only older SoCs).
- Not found: any sm6150/sm7150/sm8150 qcom_stats numbers on Android or mainline; any statement that s2idle
  cannot reach aosd; the surya downstream tree was not read.

## Hypotheses (ranked) and the cheap test of each
1. A DSP's latched RPMh vote (floor tests were stops, not never-started) - boot with DSPs never started.
2. Unclaimed bootloader clocks/GDSCs (display splash, camcc, dispcc, XO-related rpmh clocks), kept alive by
   clk_ignore_unused / pd_ignore_unused or by nobody claiming them - read /proc/cmdline and clk_summary.
3. Peripheral votes: USB (usb30_prim_gdsc, tag-7 icc), UFS, WLAN (ath10k_snoc), two UARTs - subtract one at a time.
4. The SH0 residual (tag-7 icc votes through suspend) keeps LLCC/DDR path alive.
5. AOSS prevent_* (cx_mol, ddr_mol, aoss_slp) left set by firmware - write them off (cheap, unlikely).
6. Counters or firmware: this firmware may not fill some entries (adsp 0 always; apss/display/gpu/slpi empty).
   Settled only by an independent measurement: standby current (sleep-standby-current).
Set aside: another cluster-state value (state taken is the same as downstream/sm8150); SYSTEM_SUSPEND (not
offered by these firmwares); smp2p sleepstate (not in mainline for this SoC; weakest).
