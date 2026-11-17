# sleep-adsp-awake, look-around and two floor tests (surya-keeper-6, 2026-11-17)
- idle-awake/summaries.txt: qcom_stats, pm_genpd_summary, interconnect_summary, regulator_summary, enabled clocks, remoteproc, wakeup sources, runtime-active devices, read awake on the kept kernel 7.1.0-sm7150-calls+.
- adsp-floor.sh: runs on the phone as a systemd-run unit: snapshots, optional remoteproc stop (30 s watchdog fuse around it), `way-back.sh cycle 15 bt-on`, snapshots, remoteprocs started again.
- floor1/: adsp stopped for the cycle. floor2/: adsp, cdsp and modem stopped. Both: cxsd, aosd, ddr stayed 0.
