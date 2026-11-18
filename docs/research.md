<!-- Generated from data/ by tad. Do not edit by hand. -->

# Research

<a id="wiki-against-our-checks"></a>
### wiki-against-our-checks

Date
: 2026-11-11

Brief
: What does the community report for surya, and where does it disagree with what our checks measure?

Question
: What does the community report for surya, and where does it disagree with what our checks measure?

Found
: Of 19 parts, 9 agree. The wiki reports calls, SMS and NFC working where our checks say unknown (no SIM card yet); mobile data and Bluetooth working where we measured partial; the speaker partial where we measured it working; and the sensors working where we measured broken - possibly our own doing, since we masked the sensor service to stop the audio processor crashing on suspend. The claims were gathered earlier, on an unrecorded date; this comparison is of today.

Sources
: surya-wiki


<a id="sm7150-cluster-params"></a>
### sm7150-cluster-params

Date
: 2026-11-17

Brief
: Does sm7150's device tree ask the firmware for the cluster states surya's firmware knows?

Question
: Does sm7150's device tree ask the firmware for the cluster states surya's firmware knows?

Found
: Apparently not, for the two deepest. sm7150.dtsi (sm7150-mainline, the same in our tree) carries three cluster states whose latencies are surya's own but whose PSCI parameters are SC7180's: 0x41000044 (cluster power collapse), 0x41001244 and 0x4100b244. surya's own Android device tree (lpm-levels, cluster mode shifted by 4) has l3-pc 0x4, cx-off 0x224 and llcc-off 0xc24 - that is 0x41000044, 0x41002244 and 0x4100c244; 0x4100c244 is also what SM8150, the closest sibling, uses for its one cluster sleep. On the phone the deepest state (0x4100b244) was never entered once at runtime. Whether the firmware rejects, demotes or honours SC7180's values is not known: it is the first thing a measured suspend settles. SM7150 is not yet in mainline: the 2025 upstreaming series is to be resent, so a correction can go into it.

Sources
: sm7150-dtsi-v72, surya-downstream-fdt, sm8150-cluster-idle, sm7150-upstream-series

About
: deep-sleep


<a id="surya-sleep-measured"></a>
### surya-sleep-measured

Date
: 2026-11-17

Brief
: Where does surya's deep sleep stand, measured on the phone itself?

Question
: Where does surya's deep sleep stand, measured on the phone itself?

Found
: Measured 2026-11-17 on the test kernel 7.1.0-rc3-sm7150-wcd, read only. The kernel offers only s2idle, as on every Qualcomm phone. PSCI 1.1 runs in OS-initiated mode, and the CPU and cluster idle states are in use at runtime. The SoC's own sleep counters are readable (qcom_stats, from rpmh-stats at 0xc3f0000). Since boot: no suspend at all (suspend_stats success 0 - on USB the lab holds devlab-usb, and Sxmo holds sxmo_not_suspendable and sxmo_modem_warming_up); CX collapse (cxsd) 0, AOSS sleep (aosd) 0, DDR low-power states 0; the deepest cluster state (cluster-sleep-2) never entered once while the lighter two were entered thousands of times. The audio DSP never slept (adsp 0) while the compute DSP and the modem slept about 200 times each; no audio stream was open, yet the VA, TX and RX macros stayed active, and the command line carries soundwire_qcom.stay_awake=1 from the microphone hunt. So no measurement of deep sleep exists yet, and two things already seen would keep the SoC from its floor.

Sources
: soc-sleeps-check

About
: deep-sleep


<a id="checking-calls-automatically"></a>
### checking-calls-automatically

Date
: 2026-11-11

Brief
: How can calls, messages and data be checked without a person?

Question
: How can calls, messages and data be checked without a person?

Found
: Data checks itself: a small download over the mobile connection. A call needs someone to answer: a second phone on a test stand that answers and confirms, or a programmable telephone number that answers and plays a known tone the phone can hear. Until then, half-manual: the phone calls a person's number and the person confirms through the inbox.

Sources
: twilio-voice

About
: modem-calls


<a id="microphone-codec-drops-off"></a>
### microphone-codec-drops-off

Date
: 2026-11-17

Brief
: Why does nothing come back from surya's main microphone, now that the WCD9375 enumerates and the sound card is made?

Question
: Why does nothing come back from surya's main microphone, now that the WCD9375 enumerates and the sound card is made?

Found
: The codec dropped off both SoundWire buses because ASoC puts every idle component into its sleep pin state, and the codec's sleep state drove its active-low reset low (traced: snd_soc_bind_card committed it 0.24 ms before both interfaces went UNATTACHED). Without a sleep state the codec stays attached and capture prepares (linux-phone-oco/linux PR #4); the SoundWire pin-mux fix is PR #3. Capture still yields exact zeros: the built-in microphones are digital mics (vendor: TX DMIC1-3 on LPI gpio26-29, function 1, mic bias 1 and 3); this ADSP rejects the VA capture port, so they go through the TX macro to TX_CODEC_DMA_TX_3; with the VA DMIC clocks forced on the TX path still reads zeros, as it does from ADC1 - the next fault sits in the TX decimator to DSP leg. Details: research/microphone.md.

Sources
: vendor-sm6150-lpi-dtsi vendor-sm6150-audio-overlay lineage-sm6150-wcd937x

About
: audio-mic


<a id="the-modem-with-a-sim"></a>
### the-modem-with-a-sim

Date
: 2026-11-11

Brief
: Why does the modem not go online once a SIM card is in?

Question
: Why does the modem not go online once a SIM card is in?

Found
: With the SIM in (operator 1&1, card present and ready) the modem refuses every request to go online: its own operating mode reads shutting-down from the start of boot, and ModemManager gets DeviceNotReady. The modem processor boots cleanly; rmtfs and tqftpserv run; the kernel's pd-mapper module is loaded. Meanwhile the modem reads and writes /readwrite/lctoem.tmp over tqftpserv in an endless loop, with rsize=0 seek=0 options, each read ending at once - the same kind of loop that postmarketOS fixed for the Fairphone 4 and 5 with a tqftpserv that handles rsize and seek. A reboot with the SIM in place changed nothing.

Sources
: pmaports-tqftpserv-4747

About
: modem-data


<a id="mic-zeros-meant-no-input"></a>
### mic-zeros-meant-no-input

Date
: 2026-11-17

Brief
: What made the TX decimator to codec DMA path deliver zeros, and what does a capture of zeros tell?

Question
: What made the TX decimator to codec DMA path deliver zeros, and what does a capture of zeros tell?

Found
: The decimator-to-DSP leg worked all along: each silent recording began with ~0.5 s of ringing (-1774 settling to exact 0), the high-pass filter draining a constant input - the decimator ran and its output reached TX_CODEC_DMA_TX_3, but no samples entered it. The cause was upstream of the decimator: the capture link named the TX SoundWire controller's DAI 0, its playback DAI (qcom_swrm_register_dais makes the first num_dout_ports DAIs playback, and this controller has one dout port), so sdw_stream_add_master was never called and the codec's ports never programmed. The same one-dout-port shift moves master port numbers by one (ports start at 2; swr2's qcom,ports-* arrays begin with 0xff). For DMICs the same reading held: with no clock on the pin the data line is static and the filter removes it. So: start-up ringing then exact zeros means no input reaches the decimator - look at the source (SoundWire stream, DMIC clock), not the DMA or the AFE port. The AFE port is the vendor's too: TX AIF1 on TX_CDC_DMA_TX_3 (45111 = 0xB037), accepted by this ADSP.

Sources
: pulpoff-linux-surya,sm7150-mainline-pr60,lineage-sm6150-bolero

About
: audio-mic


<a id="call-audio-on-surya"></a>
### call-audio-on-surya

Date
: 2026-11-17

Brief
: What does a voice call with sound both ways need on surya, and what is there now?

Question
: What does a voice call with sound both ways need on surya, and what is there now?

Found
: Read on the phone 2026-11-17 (devlab phone sh, read only): the modem is online now - LTE on Vodafone.de (26202), registered home, packet service attached, signal 71%, UE mode csps-1, voice-centric with PS (VoLTE) preferred, so a call goes VoLTE if the modem's IMS profile allows it, else falls back to GSM; ModemManager 1.25.95, libqmi 1.38, tqftpserv 1.3, rmtfs 1.3; callaudiod and q6voiced are installed; no calls listed. The kernel (7.1.0-sm7150-mic+, linux-phone-oco/linux test/surya-mic) has no VoiceMMode PCM and no Voice Mixer controls: q6voice is not in it. pulpoff/linux-surya (7.2.15 on surya) carries calls with audio both ways: q6voice from sdm845-mainline (MVM, CVS, CVP over APR) with the CVD 2.3 set-up SM7150 needs (from the CVP version), codec DMA ports, a zeroed command buffer and the start moved from startup to prepare; the device tree adds the APR services and a hostless VoiceMMode1 link (PCM 4, hw:0,4) that q6voiced opens per call; routing 'TERT_MI2S_RX Voice Mixer VoiceMMode1' and 'VoiceMMode1 Capture Mixer TX_CODEC_DMA_TX_3' (our kernel uses the same back-end names); 'VoiceMMode1 TX Topology' at 0x10F70 (none) since the default 0x10F71 sends silence without Xiaomi's calibration; and the uplink is silent unless a 1-channel capture runs on TX_CODEC_DMA_TX_3 for the whole call (their surya-call-uplink on MultiMedia3; 2 channels or a prepared-only stream do not do). callaudiod picks a UCM Voice Call verb (earpiece or speaker). The order: q6voice and the device tree first (the PCM and controls appear - check call-audio-path), then UCM Voice Call with the topology and the uplink capture, then a call.

Sources
: pulpoff-linux-surya

About
: modem-calls


<a id="modem-online-tqftpserv"></a>
### modem-online-tqftpserv

Date
: 2026-11-17

Brief
: Why did surya's modem fail as soon as a SIM went in, and what makes mobile data work?

Question
: Why did surya's modem fail as soon as a SIM went in, and what makes mobile data work?

Found
: The modem looped 4769 times reading and writing /readwrite/lctoem.tmp: tqftpserv 1.1.1 (Alpine v3.24) never writes short WRQ files, so the state files stayed 0 bytes, the modem stayed in DMS mode shutting-down, UIM reported 'GW primary session index unknown' and ModemManager 'sim-missing'. tqftpserv 1.3 from Alpine edge (two packages, no other dependencies) fixed it on the next boot: mode online, Vodafone.de LTE, home registration, signal 71%. Mobile data then failed with 'Multiple PDN connection to same APN not allowed' when the NetworkManager connection named the APN web.vodafone.de: the modem's default profile attaches with an empty APN, which the network fills in. A gsm connection with no APN works: IPv4 and IPv6, 3/3 pings at 32 ms, 500 kB at 1.2 MB/s. The SIM sits in slot 2 (slot 1: no ATR), as pmaports #4441 found.

Sources
: pmaports-4441-tqftpserv

About
: modem-data


<a id="sensors-registry-rebuild"></a>
### sensors-registry-rebuild

Date
: 2026-11-17

Brief
: Why does the ADSP sensors service crash-loop the audio DSP on surya, and what would stop it without changing the firmware?

Question
: Why does the ADSP sensors service crash-loop the audio DSP on surya, and what would stop it without changing the firmware?

Found
: Measured on the phone (read only, kept kernel 7.1.0-sm7150-calls+, 2026-11-17) and read in hexagonrpcd's source. At start the DSP's registry sensor compares each config it knows (the registry's sns_reg_config: 47 configs, every one recorded with data 1230768000 - 2009-01-01, Android's fixed vendor mtime) with the config files hexagonrpcd serves, and hexagonrpcd passes their real mtime: all 46 on the phone carry 1779945838 (the package's build time), and sns_pickup.json is listed but absent. Every config therefore looks changed, the DSP re-parses and writes (temp.json), hexagonrpcd refuses every write by design, and the DSP asserts (SNS_REG_INIT, sns_registry_sensor.c) and restarts with audio. The version marker sns_reg_version, whose absence also forces a rebuild elsewhere (hexagonrpc #19), cannot be served at all: the virtual persist/sensors/registry holds only its registry subdirectory. So no trial of 2026-11-09 had both conditions of an untouched registry - the marker reached and the configs unchanged; they disproved only a registry swap. Hypothesis to settle first: configs touched to 1230768000 (and no listed config missing) make the pre-parsed registry current, so nothing is written and the ADSP stays up. Independent of it: the same assert is open upstream on X1P42100 (#29, 2026-11-14) and was stopped by writes elsewhere (#19, #27).

Sources
: hexagonrpc-source,hexagonrpc-19,hexagonrpc-27,hexagonrpc-29,firmware-xiaomi-surya,libssc

About
: sensors


<a id="sensors-hardware-surya"></a>
### sensors-hardware-surya

Date
: 2026-11-17

Brief
: Which sensors does surya carry, where, and is in-call proximity a real sensor?

Question
: Which sensors does surya carry, where, and is in-call proximity a real sensor?

Found
: All on the audio DSP's sensor core (no SLPI on SM7150), none on a bus Linux drives: the motion chip (accelerometer+gyroscope; one of bmi220, bmi26x, icm4x6xx, lsm6dso, probed by the DSP - the wiki names BMI220) on SPI instance 3; magnetometer AK09918 (ak0991x) on I2C 1 at 0x0c; adux1050, a capacitive SAR sensor for radio power, on I2C 1 at 0x2c (not the call proximity); Sensortek stk3a5x ambient light + infrared proximity on I2C 5 at 0x46, polled, near/far 12000/10000, one calibration value differing by panel (huaxing 2.0, tianma 1.0, chosen on Android by ro.boot.lcmtype through an apps-side get_property hexagonrpcd does not implement; the pre-parsed registry already holds stk3a5x). In-call proximity is that physical IR sensor: surya's tree has none of the ultrasound parts its sibling sweet carries (elliptic, mius, ro.vendor.audio.us), so the microphones and earpiece are not involved. The phone runs libssc 0.4.3 with ssccli, iio-sensor-proxy 3.9 with ssc support, and its udev tags fastrpc-adsp ssc-light, ssc-compass, ssc-accel, ssc-proximity; iio-sensor-proxy starts and waits ('registry sensor unavailable'). The suite's motion-and-light counted IIO devices only, so it could never pass through the sensor core.

Sources
: lineage-surya-tree,firmware-xiaomi-surya,wiki-surya-ssc-2024,iio-sensor-proxy-409,libssc

About
: sensors


<a id="sensors-family-state"></a>
### sensors-family-state

Date
: 2026-11-17

Brief
: How far have SSC sensors got on SM7150 and its siblings on mainline, and what stopped them?

Question
: How far have SSC sensors got on SM7150 and its siblings on mainline, and what stopped them?

Found
: surya: reported working once (wiki 'SSC works', 2024-03-11, mainline 6.7.4, hexagonrpcd 0.3.x, setup unwritten), never re-checked; firmware-xiaomi-surya's registry is Android's own (mtimes 1230768000). davinci (SM7150): rarely works on v26.06, iio-sensor-proxy at 100% CPU (#4674), the audio failure loop from ADSP crashes (#3871); a fix serving the real persist (!8203) was closed unmerged. tucana works (mount matrix fixed); sweet light and accel, its proximity is ultrasonic; sunfish (Pixel 4a) does not. miatoll (SM7125, ADSP only like surya) works with a registry rebuilt on Linux (sns_reg_config 1720791834). Fairphone 4 (SM7225) works. Upstream: no hexagonrpcd release writes (v0.5.0, 2026-08, none); write support exists out of tree (#27 withdrawn, a -S state dir on SG6275P, a 700-line patch on X1P42100) and the maintainers have not settled where writes go. Other routes: Linux driving the sensor chips on the SSC buses fights the DSP for them (X1E) and needs drivers stk3a5x lacks; Ubuntu Touch on surya has sensors through Android's vendor kernel (Halium).

Sources
: wiki-surya-ssc-2024,pmaports-4674,pmaports-8203,pmaports-5941-miatoll,hexagonrpc-19,hexagonrpc-27,hexagonrpc-29,lkml-ssc-qup-from-apps,firmware-xiaomi-surya

About
: sensors


<a id="sensors-across-suspend"></a>
### sensors-across-suspend

Date
: 2026-11-17

Brief
: Can the sensors helper stay attached across suspend, and what brings it back after?

Question
: Can the sensors helper stay attached across suspend, and what brings it back after?

Found
: postmarketOS stops sensorspd and rootpd before suspend (the units Conflicts=suspend.target; !5400 on the Pixel 3a, carried to systemd in !7303) and nothing restarts them: Restart=always does not fire on a conflict stop, by design - the helper is thought needed only while the DSP asks for its registry, and libssc talks QMI to the sensor service, not through hexagonrpcd. So after a first suspend on surya the sensors would have no helper; whether they keep working without it is unmeasured. One data point (SG6275P, #19) has a sensors helper with a writable registry surviving a 15 s rtcwake. surya's rootpd crash on suspend (24 of 24) is a separate helper; rootpd stays masked. No kernel fastrpc fix for suspend was found in 2025-2026; Qualcomm said in 2026-04 that a daemon attaching to a PD crashes the privileged PD and is being investigated.

Sources
: pmaports-sargo-suspend,hexagonrpc-19

About
: sensors


<a id="sensors-how-it-stands"></a>
### sensors-how-it-stands

Date
: 2026-11-17

Brief
: The sensor hub on surya: how it stands, what was tried, what never to do again

Question
: The sensor hub on surya: how it stands, what was tried, what never to do again

Found
: 2026-11-17 (research-sensor-hub): broken by our own mask - hexagonrpcd-adsp-sensorspd and -rootpd masked in surya-lab device.toml; iio-sensor-proxy runs and waits for the registry. Way decided: the registry kept current (decision 2026-11-17-sensors-registry-kept-current); queue sensors-and-the-mask (10, first), sensors-without-crash (11), sensors-proximity-in-calls (12), sensors-registry-writes (13, fallback only), sleep-fastrpc-helpers (4) for suspend, sensors-upstream (no phone). Dead ends: swapping registries (packaged, or the phone's own persist with the marker beside it) - hexagonrpcd cannot serve the marker, so those trials changed nothing (2026-11-09, surya-lab adsp/registry-trial.sh, which counts crashes and can take the probe). Tools on the phone: ssccli --sensor proximity|light|accelerometer|magnetometer, monitor-sensor, busctl on net.hadess.SensorProxy. Never: unmask rootpd (the DSP dies at every suspend attempt); leave sensorspd crash-looping - each crash restarts the DSP that carries the microphones and calls; read /sys/kernel/debug/gpio or the LPI pinctrl at 62b40000 - the sensor core's pins are there. The sensor chips are not on any bus Linux drives.

Sources
: hexagonrpc-source,firmware-xiaomi-surya

About
: sensors


<a id="2026-11-17-surya-first-s2idle-cycle"></a>
### 2026-11-17-surya-first-s2idle-cycle

Date
: 2026-11-17

Brief
: Does surya's SoC reach its sleep floor in one measured s2idle on the kept kernel 7.1.0-sm7150-calls+?

Question
: Does surya's SoC reach its sleep floor in one measured s2idle on the kept kernel 7.1.0-sm7150-calls+?

Found
: No. One 60 s cycle by hand (USB gadget let go via soft_connect, rtcwake -m freeze -s 60, run as a transient systemd unit so it survives the link dropping; nohup in the ssh session is killed on exit). The phone slept the whole time: the pm8xxx_rtc_alarm interrupt fired once and suspend_stats success went 0 to 1, fail 0. The 2.4 s between the kernel log's suspend entry and exit, and between date readings, is only the clocks not counting sleep (monotonic and wall time stand still in s2idle here) - read the sleep from the RTC, not from date or dmesg. qcom_stats: cxsd 0, aosd 0, ddr 0 before and after; adsp never counted a sleep, cdsp 58, modem +7. Cluster domain: S1 usage 9417 to 9482 across the run, S2 (the deepest state) never entered. The suite's soc-sleeps now says fail: suspended, yet the SoC never reached its lowest state: cxsd 0, aosd 0; suspends this boot: 1; processors never asleep: adsp; wake locks: devlab-usb (devlab-health 20261117-115521). No hands needed: the phone woke by itself on the RTC alarm and came back over USB. Careful: reading /sys/power/wakeup_count blocks while a wakeup event is held (the lab's devlab-usb wake lock) - never read it without a timeout.

Sources
: devlab suite run 20261117-115521; /var/tmp/sleep-cycle/before and after on the phone

About
: deep-sleep


<a id="2026-11-17-surya-s2idle-wakes-at-once"></a>
### 2026-11-17-surya-s2idle-wakes-at-once

Date
: 2026-11-17

Brief
: surya's suspend ends at once: the serial's IRQ 157 (a storm, wake-armed) wakes s2idle; Bluetooth dies after it

Question
: Why does surya's s2idle end after about 2 s instead of 60, and what does the first measured cycle show?

Found
: Five cycles by hand (kept kernel 7.1.0-sm7150-calls+, one with the cluster parameters of surya's own firmware tables in the device tree) all end early: the RTC advanced a few seconds only, the suspend core goes from dpm_suspend_noirq end to dpm_resume_noirq begin in microseconds and the CPUs never enter s2idle's idle loop. A function trace names the wake: s2idle_wake <- pm_system_irq_wakeup <- irq_pm_handle_wakeup, during suspend_device_irqs, no wakeup source involved. The interrupt is IRQ 157, qcom_geni_serial_isr (the serial at 88c000, wake-enabled, count 200579 ten minutes after boot): the kernel logs 'irq 157: nobody cared' and disables it. So the cluster sleep parameters and the audio DSP cannot be judged yet: the SoC has not been let sleep once. Also seen: a suspend leaves Bluetooth hci0 dead (command tx timeout, Reading QCA version information failed -110) and pm_suspend hangs in hci_resume_dev for minutes - a reboot was needed. The soc-sleeps check says fail (suspends 1, cxsd 0, aosd 0, adsp never asleep). The earlier note that the phone slept the full 60 s was wrong: it read the RTC alarm interrupt count, which fires awake too.

Sources
: /var/tmp/sleep-cycle on the phone; devlab suite run 20261117-115521

About
: deep-sleep

Material
: research/deep-sleep/2026-11-17/

Supersedes
: 2026-11-17-surya-first-s2idle-cycle


<a id="2026-11-17-surya-s2idle-bt-blocked-hang"></a>
### 2026-11-17-surya-s2idle-bt-blocked-hang

Date
: 2026-11-17

Brief
: IRQ 157 is the Bluetooth UART; with it blocked, a timed s2idle cycle hung the phone hard (no way back on USB).

Question
: What holds IRQ 157 up in surya's s2idle, and what does a timed cycle do once Bluetooth is blocked?

Found
: IRQ 157 is the Bluetooth UART: GICv3 hwirq 636 = serial@88c000 (interrupts 0x25c), with hci0 UP RUNNING on it (TX 444 KB, 1847 commands); the console UART ttyMSM0 is a88000, a different device with no wakeup attribute. With bluetooth rfkill-blocked, one timed cycle (soft_connect 0, rtcwake -m freeze -s 60, run as transient unit cycle1) did NOT return: the phone showed the pmOS initramfs gadget (18d1:d001) with no network until the author force-rebooted it (vol-down+power). The previous boot's journal ends at 12:37:25, the cycle script and its log are not on disk, suspend_stats this boot 0/0: so the phone went down hard right at suspend entry, losing the last seconds, and its wake path (the PMIC RTC reads 1970, epoch 1280063 s) did not bring it back. Not known yet: whether the hang is the RTC alarm not waking s2idle, a crash entering s2idle with the audio DSP up, or a reset; and whether the IRQ-157 wake was cured. Health after reboot: healthy, 36 pass, 0 fail. Next try needs a way back not depending on USB networking: a hardware watchdog or timed reboot, the RTC set first, a log written to a place that survives (sync, pstore/ramoops or a serial console).

About
: deep-sleep


<a id="2026-11-17-surya-way-back-inventory"></a>
### 2026-11-17-surya-way-back-inventory

Date
: 2026-11-17

Brief
: surya has the qcom_wdt watchdog, 4 MiB ramoops and a PMIC RTC (1970); the stock watchdog is stopped in late suspend, so no way back covers a hang inside s2idle

Question
: What does surya have, and what do mainline and others do, for a way back from a suspend that may not return?

Found
: On the phone: qcom_wdt (17c10000.watchdog) with /dev/watchdog0, ramoops 4 MiB reserved at 0x9d800000 with pstore (console 1 MiB), the PMIC RTC reading 1970 and settable with hwclock -w -u; the kernel has no suspend timeout of its own (no PM_DEBUG, hung-task, DPM watchdog). Mainline qcom-wdt.c registers late system sleep ops that STOP an active watchdog in suspend and start it on resume: so a hang before the late phase is covered by a watchdog, one inside s2idle is not. A module with that stop made optional (one parameter, no other change) builds for the running kernel (no MODVERSIONS; vermagic equals uname -r) and loads without a kernel rebuild or reboot-to-test; a reboot undoes it. The RTC alarm cannot be the way back: if the RTC wake does not reach the GIC out of s2idle the phone sleeps for good, which looks the same as a hang. A bite resets the SoC; whether it reaches a normal boot and whether ramoops survives it is what the dry run measures.

About
: deep-sleep

Material
: research/deep-sleep/2026-11-17-way-back/


<a id="2026-11-17-way-back-measured"></a>
### 2026-11-17-way-back-measured

Date
: 2026-11-17

Brief
: A 30 s watchdog fuse resets an idle or hung surya and it boots by itself; the BT-blocked s2idle hang reproduced at once (no log); pstore does not survive the reset

Question
: Does the watchdog way back work (idle, through a suspend entry, in the hanging cycle), and what log survives?

Found
: Yes. Idle: reset in 31 s, phone back in ~1.5 min with no hands. Probe (Bluetooth on, s2idle 3 s): the patched qcom_wdt kept counting through the suspend and bit 31 s after arming. The cycle with Bluetooth blocked and a 15 s sleep hung again right at suspend entry (the journal ends at the cycle marker, no PM: suspend entry line, suspend_stats 0/0) and the watchdog reset the phone 30 s after arming, back in under a minute more, no hands. The qcom watchdog counts 32 s at most (BusyBox -T 50 is EINVAL; the default 30 s holds), so a cycle's sleep is at most 15 s. pstore/ramoops stayed empty after every reset (the reset does not keep it); the persistent journal, synced before the arm, is the log that survives up to the last second before the hang. The PMIC RTC cannot be set.

About
: deep-sleep

Material
: research/deep-sleep/2026-11-17-way-back/


<a id="2026-11-17-qca-uart-wake-across-suspend"></a>
### 2026-11-17-qca-uart-wake-across-suspend

Date
: 2026-11-17

Brief
: The suspend wake is irq 158 (GPIO 41, the UART RX line, the serial's dedicated wake irq), not 157; the serial's power/wakeup is its mainline switch

Question
: What ends surya's s2idle at once with Bluetooth up, and what do mainline and others do for a qca UART Bluetooth across suspend?

Found
: Measured 2026-11-17 on 7.1.0-sm7150-calls+ with ftrace and a kprobe on pm_system_irq_wakeup (suspend-wake-arm-trace.sh in the material): s2idle was ended by irq 158 ('88c000.serial:wakeup', msmgpio 41, edge), armed by dev_pm_arm_wake_irq in the late phase because the platform device 88c000.serial has power/wakeup enabled (qcom_geni_serial sets device_init_wakeup and dev_pm_set_dedicated_wake_irq when the DT gives a second interrupt: the RX pin). The main irq 157 (GIC 636) fires 6 times at the end of qca_suspend, which waits up to 2 s for the chip's sleep indication (hci_qca.c); no 'nobody cared' appeared in these tries. Mainline source read (torvalds/linux master): uart_suspend_port keeps the irq wake only if the tty device serial0 may wakeup (here disabled); hci_qca qca_wakeup() returns device_may_wakeup of the serdev controller and the Bluetooth core then arms a passive scan for suspend, so an RX edge from the chip is a wake by design; the switch is the serial's power/wakeup, a plain sysfs file. With it off for a cycle, s2idle ends by the RTC alarm (RTC counted 7 s for 5 asked, 7 s for 5, 17 s for 15) with hci0 up and scanning after. Not read this time: what postmarketOS ships for qca Bluetooth across suspend (only the earlier note of its hook stopping Bluetooth for the Pixel 3a FastRPC crash). The earlier hang on resume was seen with Bluetooth blocked; not reproduced with it unblocked and wakeup off.

Sources
: https://github.com/torvalds/linux/blob/master/drivers/tty/serial/qcom_geni_serial.c; https://github.com/torvalds/linux/blob/master/drivers/tty/serial/serial_core.c; https://github.com/torvalds/linux/blob/master/drivers/bluetooth/hci_qca.c

About
: deep-sleep

Material
: research/deep-sleep/2026-11-17/


<a id="dropping-the-lpass-macros-hw-votes-at-runtime"></a>
### dropping-the-lpass-macros-hw-votes-at-runtime

Date
: 2026-11-17

Brief
: Dropping the LPASS macros' hw votes at runtime suspend does not wake the audio DSP's sleep: adsp stays 0, with or without it

Question
: Which LPASS vote keeps the audio DSP from sleeping with no stream open?

Found
: Not the macros' macro/dcodec votes alone: with them released at runtime suspend (patch kept in the material, upstream-aligned) a quiet cycle 15 bt-on still counts adsp 0, cxsd 0, aosd 0; stopping the voice, sensors and sound-server services changes nothing; the kept kernel has no stay_awake. Linux itself holds CX through the two active UARTs. Not known yet: what the DSP waits for (its own firmware, sensors PD, a vote by another subsystem).

About
: deep-sleep

Material
: research/deep-sleep/2026-11-17/


<a id="2026-11-17-adsp-stopped-cx-aosd-ddr-stay-0"></a>
### 2026-11-17-adsp-stopped-cx-aosd-ddr-stay-0

Date
: 2026-11-17

Brief
: With the audio DSP stopped - or all three DSPs - a measured cycle still counts cxsd 0, aosd 0, ddr 0: the audio DSP is not what holds the SoC

Question
: Which vote or clock keeps the audio DSP awake, and is the audio DSP what stops CX, AOSS and DDR from sleeping?

Found
: Measured 2026-11-17 on the kept kernel (7.1.0-sm7150-calls+, patched qcom_wdt), cycle 15 bt-on, as systemd-run units, nothing polled during a cycle.
(1) The DSP side, read awake: adsp, cdsp and modem remoteprocs running; qcom_stats adsp 0 (cdsp 56, modem 1798 counted): the three share one reader, so the layout is right for the subsystems; whether the ADSP firmware fills its own sleep-stats entry at all is not known yet. The only LPASS clocks enabled: LPASS_HW_MACRO (rx, tx macros and codec), TX_CORE_MCLK/NPL (rx, tx macros), fsgen - the macros' own clocks; the previous keeper's vote release did not change adsp.
(2) Others, read awake: genpd cx on at performance 256 with the two UARTs (88c000 Bluetooth, a88000) as devices; mx on 256; usb30_prim_gdsc on (USB gadget, the lab's link: qns_llcc/ebi avg 240000 peak 700000 are the USB's vote, cut by the cycle's gadget disconnect); ufs_phy_gdsc on; interconnect: only USB and the UARTs vote with bandwidth, the CPUs 8.7 GB/s peak; the PSCI cluster domain has states S0 (6 ms residency), S1 (8.5 ms) and S2 (9.8 ms): S2 entered once during the one cycle of that boot (s2idle count 1), so the cluster reached its deepest state.
(3) Floor test 1: adsp stopped for the cycle (offline, no LPASS clock left, no APR devices; the teardown logged a clk_unregister warning from tx_macro, harmless): cxsd 0, aosd 0, ddr 0 after. Floor test 2: adsp, cdsp and modem all offline: cxsd 0, aosd 0, ddr 0 after. Started again after: all three running; the sound card needed a clean reboot, then the suite: 35 pass, 0 fail.
Meaning: the audio DSP is not the (only) thing keeping CX, AOSS and DDR up: with no DSP running at all they still do not count. The cause is on the Apps side or in AOSS/RPMh: the sleep set (rpmh flush at cluster power-off), the cluster's PSCI state parameter (sleep-cluster-params), the remaining CX vote of the two UARTs, or WLAN/UFS. Not known yet: which; this kernel has no RPMh trace points (events: clk, regulator, interconnect, power/psci_domain_idle_enter only).
Not measured: a cycle with the UARTs closed; the PSCI state taken at the suspend; the live rpmh sleep-set contents.

About
: deep-sleep

Material
: research/deep-sleep/2026-11-17-adsp-floor/


<a id="2026-11-17-cluster-params-clean-yet-no-collapse"></a>
### 2026-11-17-cluster-params-clean-yet-no-collapse

Date
: 2026-11-17

Brief
: On the cluster-params dtb the cluster entered 0x4100c244 for a real 15 s s2idle, RPMh CX/MX at 0 and the sleep set clean but SH0 x=1,y=3; cxsd, aosd, ddr still 0

Question
: With surya's own cluster sleep parameters booted, does a timed cycle collapse CX/AOSS/DDR, and if not what is held?

Found
: See notes.md: cluster S2 used (genpd idle_states), wake by the RTC alarm after 15 s (trace clock stops in s2idle), CX/MX active votes 0, sleep set all zero except SH0 (x=1,y=3), stats cxsd/aosd/ddr 0 in 8 cycles. Cause not found in genpd, clk, icc or rpmh traces; candidates untested: SH0 owner, qcom_aoss prevent_* knobs, XO/VRM votes, USB gadget, display RSC.

About
: deep-sleep

Material
: research/deep-sleep/2026-11-17-cluster-params/


<a id="2026-11-17-floor-research"></a>
### 2026-11-17-floor-research

Date
: 2026-11-17

Brief
: Nobody shows a phone-class SM7150/8150/845 reaching cxsd/aosd on mainline; surya's DSP floor tests were stops not never-started, holders' clocks never read; six ranked holders

Question
: Why do cxsd, aosd and ddr never count on surya after a real s2idle, and what is the way to the SoC floor?

Found
: See the material. Counters are the SoC's own (rpmh-stats; no client-votes field on this layout), so they are valid but name no culprit. It can be done on mainline s2idle: Acer Aspire 1 (sc7180, OSI) counts all three; X1E s2idle reaches 99.9% after subtracting icc-bwmon, PCIe, LPASS macro and console votes (AOSD only with the CDSP running); sm8250 RP5 stays 0/0 with camcc and DSI clock votes and the ADSP up. No system-level mode is missing: surya's cluster state equals downstream's and sm8150's, apps_rsc matches sc7180. Surya's weak points: the floor tests stopped DSPs that had run (their RPMh votes may stay latched) instead of never starting them; clk_summary was never captured (files empty) and the kernel command line (clk_ignore_unused?) is unrecorded; tag-7 icc votes and the a88000 serial vote through suspend (SH0 x=1,y=3). Ranked: DSP latched votes, unclaimed bootloader clocks, peripheral votes (USB/UFS/WLAN/UARTs), SH0 owner, AOSS prevent knobs, counter validity.

Sources
: floor-travkin-aspire1,floor-x1e-s2idle,floor-rp5-sm8250,floor-sleep-stats-v12,floor-osi-s2idle-rfc,floor-floral-pm,floor-oneplus6-stats

About
: deep-sleep

Material
: research/deep-sleep/2026-11-17-floor-research/


<a id="2026-11-17-sensorspd-probe-still-writes"></a>
### 2026-11-17-sensorspd-probe-still-writes

Date
: 2026-11-17

Brief
: Registry probe on the kept kernel: configs at mtime 1230768000, sensorspd alone unmasked - the DSP still writes (temp.json, sns_reg_version) and crashed 7 times in 150 s

Question
: Does the ADSP still write the registry once the 46 sensor configs match its record (sensors-and-the-mask, one boot, kept kernel 7.1.0-sm7150-calls+)?

Found
: Yes. With touch -d @1230768000 on the configs and sensorspd unmasked and started, hexagonrpcd logged ~70 times each 'Tried to open .../registry/../temp.json for writing' and '.../sns_reg_version for writing' (no such file), 'Could not read from directory: Bad file descriptor'; the DSP asserted SNS_REG_INIT sns_registry_sensor.c:94 (SNS_RC_SUCCESS == rc) and crashed 7 times in about 25 s of the 150 s (remoteproc crash #1-#7), then 'Handover signaled, but it already happened' every second; ssccli: QRTR node was removed from the bus. After stop, the audio card stayed gone: only a reboot restored it (health 35 pass 0 fail after). Mask and mtimes put back; nothing kept. So the rule in the item applies: the way turns to sensors-registry-writes. Note: count crashes by remoteproc 'crash detected in adsp' lines, not by awk on dmesg timestamps (the probe's own count read 0).

Sources
: hexagonrpc-19,hexagonrpc-27,hexagonrpc-29

About
: sensors


<a id="2026-11-17-sh0-and-aop-research"></a>
### 2026-11-17-sh0-and-aop-research

Date
: 2026-11-17

Brief
: SH0 is a keepalive LLCC BCM; its sleep residual is a TAG_ALWAYS consumer (QUP/uart8), not a latch; AOP QMP wiring equals sm8150, no-ack unexplained

Question
: What is SH0 x=1,y=3, who votes it, what do SDM845/SM8150/SC7180 do, and why does the AOP not ack QMP?

Found
: SH0 is not a holder someone took; it is a keepalive BCM. In mainline sm7150.c, bcm_sh0 is "SH0", keepalive, node qns_llcc, identical to sdm845, sm8150 and sc7180 (the sc7180 Acer Aspire 1 reaches cxsd/aosd/ddr counts with the same definition). bcm-voter.c forces keepalive BCMs to x=y=1 (or enable_mask) only in the AMC and WAKE buckets. The SLEEP bucket is aggregated from consumers' tags only, so a sleep-set SH0 x=1,y=3 means a consumer whose tag includes SLEEP (QCOM_ICC_TAG_ALWAYS = AMC|WAKE|SLEEP) has a path through qns_llcc with a tiny bandwidth. In sm7150.dtsi the candidates are the QUP nodes, which use TAG_ALWAYS interconnects (one serial toward gem_noc SLAVE_LLCC, near line 1259), the crypto engine (ALWAYS to EBI, line 460), and uart8 serial@a88000 (the debug UART), which the recorded cycles show at avg 1 peak 1 across suspend. The owner is a DT tag on a consumer, not a firmware latch.
Whether the SH0 sleep vote blocks aosd is NOT known yet: no source shows the sleep-set contents of the Aspire 1 or any SM7150-class phone; SH0 is only the sole non-zero sleep entry on surya, which makes it the cheapest subtraction.
QMP: the aoss_qmp node (c300000, spi 389, mboxes apss_shared 0, apss_shared at 17c00000) is identical to sm8150 and sc7180, so the wiring in the tree is not the difference. Open succeeds, every send times out: the AOP does not clear the length word after the kick; qmp_send gives no other signal. Downstream wiring (irq-reg-base 17c0000c, mask 1) could not be confirmed from a source this session - not known yet. QMP matters only for the aoss prevent knobs (cx_mol, ddr_mol; hypothesis 5, unlikely) and is not on the path to the SH0 owner.
Read from the tree at kernel-rc3; nothing on the phone was touched.

Sources
: sh0-bcm-voter-c,sh0-sm7150-icc,aoss-qmp-patchwork,floor-travkin-aspire1

About
: deep-sleep


<a id="2026-11-17-pr27-registry-try"></a>
### 2026-11-17-pr27-registry-try

Date
: 2026-11-17

Brief
: PR #27 hexagonrpcd on surya: DSP writes /../sns_reg_version (outside any mapped dir), PR answers ENOSYS; ADSP dropped, reboot twice

Question
: Does hexagonrpcd of PR #27 (40e5041), run over a writable state copy of the registry, stop the DSP's registry write crash on surya?

Found
: No, not as built. Built 40e5041 for the phone (static aarch64 by hand: no meson on the lab; sha256 c4557f04...), seeded a state root with sensors/persist/registry as a copy of the package registry (the layout build_persist_dir maps), one try as a transient unit, sensorspd attach. The DSP asked for /vendor/etc/sensors/sns_reg_config (not found; our tree has it under sensors/config) and for /../sns_reg_version, first read then write: the path is outside every mapped directory and the PR answers 'Function not implemented' on the write; then 'Could not fetch next FastRPC message: Broken pipe' within a second - the ADSP dropped and the audio card went. Nothing was written to the state copy. One reboot did not bring the DSP back (no apr services); the second did (35 pass, 0 fail). So a writable registry directory is not enough: sns_reg_version has to be served as a file at the path the DSP uses, and sns_reg_config found. Next try: serve /../sns_reg_version (virtual file at root, writable in the state copy) and map sns_reg_config; one try per boot, expect two reboots to recover after a crash.

Sources
: hexagonrpc-27,hexagonrpc-19

About
: sensors


<a id="2026-11-17-sh0-not-uart8"></a>
### 2026-11-17-sh0-not-uart8

Date
: 2026-11-17

Brief
: SH0 x=1,y=3 (0x5003c data 0x60004003) stays in the suspend sleep flush with uart8 disabled: uart8 is not its owner; the GENI driver forces tag ALWAYS on every QUP path

Question
: Does the debug UART (uart8, a88000) hold the SH0 sleep vote?

Found
: Read-only: icc_summary on the kept kernel lists non-zero bw only for usb, a88000 (1), 88c000 BT (2, 3200 aggre1), cpus. Try 1: dtb with uart8 interconnect tags 7->3 (ACTIVE_ONLY): the kernel summary still shows tag 7 - qcom-geni-se sets ALWAYS on its paths whatever the DT says, so tags in the DT cannot subtract a QUP vote. Try 2: dtb with serial@a88000 disabled; booted (health showed audio failures on that boot only; the next normal boot is healthy). cycle 15 bt-on, rpmh trace: the suspend-time sleep flush (tcs 2 [sleep], 6 cmds) at 153.75 reads addr 0x5003c data 0x60004003 = SH0 x=1,y=3 unchanged; cxsd/aosd/ddr 0 -> 0. So uart8 is not the owner, and DT tag changes are the wrong tool for the QUP consumers. Next suspects: the BT UART 88c000 (in use in bt-on), other QUP/crypto always-consumers by driver unbind, or SH0 not coming from an icc consumer at all.

About
: deep-sleep


<a id="2026-11-17-sh0-bt-blocked-cycle-resets"></a>
### 2026-11-17-sh0-bt-blocked-cycle-resets

Date
: 2026-11-17

Brief
: cycle 15 with Bluetooth blocked does not return: the phone reset, no reading; icc bw is 0 on every QUP/UFS/MMC path, so SH0 looks by-design

Question
: Does blocking Bluetooth (88c000 quiet) drop the SH0 sleep vote?

Found
: On the kept kernel, way-back.sh enable then cycle 15 (BT blocked): the journal ends at 'cycle: sleep 15 s, fuse 30 s' and the phone came back after a reset (uptime 1 min, no pstore record), so the watchdog fired and no counters were read. icc_summary before the cycle: only usb (240000) and cpus carry bw on llcc/ebi; ufshc, i2c, spi, mmc, scm paths carry tag 7 at bw 0. So there is no consumer with bandwidth to subtract; SH0 x=1,y=3 may be by design and the holder elsewhere (clocks, GDSCs, counter validity). Wi-Fi after the reset stayed down: the saved SSID is not in range (the lab AP shows another name) - an environment change, not the cycle.

About
: deep-sleep


<a id="2026-11-17-floor-research-validity"></a>
### 2026-11-17-floor-research-validity

Date
: 2026-11-17

Brief
: Counters look valid; SH0 is not shown to block (awake icc read is not the flush moment); the unread facts are the RSC flush, last-CPU idle state and IRQ rate at entry

Question
: Is SH0 x=1,y=3 the blocker at all - counter validity, clocks/GDSC, late-suspend state?

Found
: Question 1, counter validity: the counters are very probably valid. qcom_stats creates its files by reading each record's name word out of the message RAM (qcom_stats.c), and surya has aosd, cxsd and ddr: three names read, not assumed. ddr_stats also passed its magic key, and its frequency rows move while the LPM rows stay 0 (research floor-holders), so the block is live and the layout is the one sc7180 uses, where the Acer Aspire 1 counts. adsp 0 and empty apss/display/gpu are SMEM entries this firmware does not fill; they are not the SoC counters. Not found anywhere: an Android reading of these counters on SM7150 (no source, none observed). Only an independent measure can make the last doubt certain: standby current (sleep-standby-current).

Question 2, is SH0 x=1,y=3 the blocker: not shown, and the reading rests on a mix-up that is worth fixing. bcm-voter.c forces keepalive BCMs only in the AMC and WAKE buckets, so a SLEEP-bucket x=1,y=3 means some request with a SLEEP-bearing tag (ALWAYS = 7) had non-zero bandwidth at the flush. The awake icc summary is not that moment: the only large vote there is USB (240000 = USB_MEMORY_AVG_HS_BW in dwc3-qcom.c, tag 7) and dwc3_qcom_suspend sets it to 0 before the last CPU flushes; the peak is cpu0/cpu6 at tag 3 (AMC|WAKE, not SLEEP). So the vote that makes x=1,y=3 is one nobody has seen being made: not USB as a floor holder (UDC unbound: counters 0 -> 0; whether SH0 changed was not read), not uart8, not the cpufreq votes by tag. Two readings remain and they cannot be told apart by subtracting: (a) the flush the log shows is stale or not the last one, i.e. the sleep set is not what the AOP sees at entry; (b) SH0 is harmless and something else blocks. So SH0 is demoted from "the blocker" to "one unexplained entry"; no more owner-hunting by tag until the entry is read.

What is the blocker then: the three observations nobody has taken at the entry itself. (1) Is the RSC flush invoked on the last CPU and what does it write (tracepoints rpmh_send_msg state=sleep; rpmh_rsc_cpu_pm_callback flushes at CPU_PM_ENTER of the last online CPU). (2) What the last CPU's idle state is (power:cpu_idle with the PSCI state, per-CPU cpuidle usage/time deltas): a cycle can "take" the cluster state once and still wake every few ms. (3) Whether anything wakes the CPUs during the 15 s: /proc/interrupts delta. This last one is what the nearest measured sibling found: on the Odin 2 (SM8550) suspend succeeded, counters read 0, and the cause was an SD controller firing ~30 irq/s through the whole suspend plus a USB PHY vote and CPU0 idle disabled (armada#274). The Qualcomm guide's own order for "aosd count zero" is also: display off, USB disconnected, suspend success count, then wake locks. Surya has never had its interrupt rate read across a cycle; devlab-usb is also a wakeup source active the whole time (research floor-holders).

Question 3, what a late-suspend dump should read: per-CPU cpuidle state usage/time before and after; the cluster genpd idle_states usage (taken, rejected) and the time spent; the sleep-set commands written (trace rpmh); /proc/interrupts delta; wakeup_sources; suspend_stats; qcom_stats of all nodes before and after (including each subsystem's last-entered time). All of it is tracefs/procfs/debugfs: no kernel build is needed, so floor-suspend-late-dump (a debug kernel) is not first.
Also AOP QMP: the AOP does process RSC commands (regulators, rpmhpd and icc work), so it is alive; QMP is a separate channel and, as found, off the path.
Sources read, not run on the phone; nothing on the phone was touched.

Sources
: qcom-stats-c,qcom-debug-high-sleep-current,armada-odin2-s2idle-274,rpmh-timeout-debug-v4,dwc3-qcom-c,sh0-bcm-voter-c,floor-travkin-aspire1

About
: deep-sleep


<a id="2026-11-17-floor-entry-trace"></a>
### 2026-11-17-floor-entry-trace

Date
: 2026-11-17

Brief
: Entry read: sleep set flushed by last CPU 7 just before cluster-sleep-2 (0x4100b244); only wake IRQ is the RTC alarm; not an IRQ storm

Question
: At the s2idle entry, is the RSC sleep set flushed after the last CPU, which idle state does the last CPU take, and how noisy are the interrupts?

Found
: One way-back.sh cycle 15 bt-on (BT left on, its UART wake off), tracing rpmh, cpu_idle, psci_domain_idle, suspend_resume, with before/after snapshots; the phone returned, RTC asleep 17 s. (1) After the other seven CPUs entered 0x40000004 (cpu-sleep-x-1, s2idle=yes), cpu7 wrote in one instant the wake set (tcs 5) and the sleep set (tcs 2: 0x50000=0x40000000, 0x50028=0, 0x5003c=0x60004003 (SH0 x=1,y=3), 0x50088=0, 0x50084=0x40000000, 0x5000c=0x40000000) and then entered psci_domain_idle 0x4100b244 = the DT's deepest cluster-sleep-2 (awake idle only uses 0x41001244, cluster-sleep-1): the flush is in order and the deepest state is requested. (2) The last CPU is cpu7 in 0x4100b244. (3) Between that entry and the wake the trace holds no event at all; the only interrupt counted for the sleep is pm8xxx_rtc_alarm (+1, cpu2, the first CPU out); every other delta (arch_timer, IPIs, apps_rsc, ufshcd, WLAN_CE) is the awake time around it. After: cxsd, aosd, ddr, adsp still 0; cdsp and modem counters move; the cluster genpd S2idle column stays 0 though S1 usage rose 402 to 483 awake. Not known yet: why the S2idle column is 0, what the AOP does on seeing this flush, which master holds the floor. Trace-clock time stops in suspend, so event times inside the window are not sleep time.

Sources
: devlab phone root on 2026-11-17: /var/tmp/entry-trace.sh (a read-only tracefs/debugfs wrapper over way-back.sh cycle 15 bt-on); output /var/tmp/et2 on the phone

About
: deep-sleep


<a id="2026-11-17-floor-aop-view-and-standby"></a>
### 2026-11-17-floor-aop-view-and-standby

Date
: 2026-11-17

Brief
: The AOP's view is not readable from Linux; the flush is sound; peers on near-mainline never read the counters as good either, so standby current, not aosd, is the arbiter

Question
: Does the AOP receive the RSC sleep flush, why is the cluster genpd S2idle column 0, and is the SoC perhaps already asleep - how does standby current arbitrate, and what is Android's to match?

Found
: (1) Does the AOP get the flush. The entry trace already shows the Apps RSC writes wake and sleep sets in one instant on the last CPU and then requests the deepest cluster state (0x4100b244), so Linux's half is done in order. The AOP's half is not observable from Linux: the only outputs are the counters it fills (aosd, cxsd, ddr in the message RAM) and the rails. Nothing in mainline reads an AOP log. What the AOP needs for cxsd is every master's sleep vote on CX gone (Apps, modem, adsp, cdsp, display, WLAN BB), not only Apps'. A peer found exactly that kind of cause: on SM7325 a WLAN BB vote prevented CX power collapse (CXPC) and, once removed, "HLOS and DDR votes remain" (pmaports#4846, 2026-11-16); on SM8550 an SD-controller IRQ storm and a USB PHY vote did (armada#274). So the entry is not the open question any more; the other masters' votes and the wakeups are.

(2) Why the cluster genpd S2idle column stays 0. From core.c: usage_s2idle is incremented only in genpd_sync_power_off, after the domain's governor (pm_domain_cpu_gov, set by cpuidle-psci-domain only when the domain has idle states) approved the power-down, and that function returns early unless every device attached to the cluster domain has been suspended (suspended_count == device_count) and every child CPU domain is off. s2idle reaches it through dev_pm_genpd_suspend, not runtime PM. The trace shows the cluster bits in the PSCI state (0x4100b244), so the cluster power-off callback did run; then either the counter is read from the wrong row/domain, or the state composed is from a path that did not count. Both are cheap to tell apart and are not known yet: read idle_states of every power-domain-* after one cycle (all rows, all columns) and the psci_domain_idle_enter trace's s2idle flag.

(3) Is the SoC asleep already, and the arbiter. The peer record says the counters are not the whole picture: motorola-dubai (SM7325) reads S2 for ~1 ms, and the author of the qclaptops tree removed WLAN BB, touch, audio and regulator holders with "idle drain lowered by 0.00000 W". Standby current moved only with: USB runtime PM allowed (0.196 -> 0.180 W), the camera VCM and always-on audio regulators released, modem off. The same report measures current_now: near-mainline 152 mA (later 60 mA, 0.2-0.3 W), the same-era Droidian downstream kernel on xiaomi-miatoll (SM6250) 9 mA. So a number exists to match: about 9 mA average with screen off on a Snapdragon 6/7-series phone running the vendor kernel. Android's own number on surya is not known yet: nobody has measured it, and the public sources give no standby current (android-reference).

(4) Cheaper tools than the AOP: regulator_summary (what rails stay on, with users), pm_genpd_summary, qcom_stats, and current_now / charge_counter. Android's value is the end, regulators the where.

Sources
: pmaports-4846-dubai-idle,genpd-core-c,cpuidle-psci-c,floor-travkin-aspire1,armada-odin2-s2idle-274,qcom-debug-high-sleep-current,2026-11-17-floor-entry-trace

About
: deep-sleep


<a id="standby-drain-as-a-repeatable-test"></a>
### standby-drain-as-a-repeatable-test

Date
: 2026-11-17

Brief
: Standby drain is made a repeatable test, scored as average current from the charge counter delta; no standard 'suitcase test' exists

Question
: Should standby drain be a proper repeatable test (idle, unplugged, fixed time, screen off, radios as in daily use) rather than a single measurement, and what should the one-off run prepared now take from it?

Found
: Yes, repeatable - but scored as mean current, not battery percent. Observed (Android power-component guide, source.android.com/docs/core/power/component): measure suspend with no wakelocks, confirm the device really suspends, wait for the reading to settle, average radio current over time, unplug USB first (a host can feed current). GameBench: hourly drain = capacity / average current. No standard 'suitcase test' or 'overnight drain test' found; the name is ours. pmaports#4846 (motorola-dubai 17x Droidian; method unread). Droidian miatoll 9 mA: its method not found; PinePhone anecdotes are single reports. Inference: charge_counter delta over the whole window is the primary number, current_now only a cross-check (wake samples inflate it), the gauge percentage least trustworthy. Take: average over a window, a settle period, unplug before the run, proof of real suspend. Leave: percentage scoring, the 30-80 mA 'normal' figures, 6-8 h windows. Test-catalogue fit: test standby-current, threshold 15 mA, median of 3 runs, a witness step 'unplug USB, confirm'; one run row per attempt (start/end charge_counter, elapsed, mean mA, samples, suspended fraction, radio state, kernel, unplug time), a failed unplug is an invalid run not a zero. One-off run: >=60 min measured after a 10 min settle (10 min is too short, the counter is coarse); Wi-Fi on the lab AP, Bluetooth as two separate runs (on, off), SIM out so record the modem state and do not call it airplane mode; screen off; log current_now, charge_counter, voltage_now, status every 30-60 s with a monotonic time, plus wakeup and suspend counts; discard samples while status is Charging; score from the charge_counter delta, report suspended fraction, compare with 15 mA and 9 mA now, Android 'not known yet'.

Sources
: https://source.android.com/docs/core/power/component; https://docs.gamebench.net; https://gitlab.postmarketos.org/postmarketOS/pmaports/-/work_items/4846

About
: deep-sleep


<a id="2026-11-17-sns-reg-version-served"></a>
### 2026-11-17-sns-reg-version-served

Date
: 2026-11-17

Brief
: hexagonrpcd of PR 27 plus a served writable sns_reg_version: sensorspd runs 150 s with no ADSP crash and iio-sensor-proxy shows accelerometer, light, proximity, compass

Question
: Does hexagonrpcd, with the version marker served as a writable file and the packaged sns_reg.conf in the state root, stop the ADSP registry-write crash on surya, and do the sensors then appear?

Found
: Yes. 40e5041 (PR #27) plus a 62-line patch (surya-lab/patches/hexagonrpcd-sns-reg-version.patch: a create op on the virtual root that opens a mapped file entry for writing, and a mapped sns_reg_version entry at the root), static aarch64, run once as a transient unit over a state root made of the package tree (config, registry, sns_reg.conf, dsp, acdb, socinfo) with the registry copied to sensors/persist/registry/registry. The earlier try's failures were the state root lacking sns_reg.conf (so /vendor/etc/sensors/sns_reg_config was not found) and no way to create the marker. Result on the kept kernel 7.1.0-sm7150-calls+: sensorspd alone, 60 s then 150 s, 0 ADSP crashes, the daemon active throughout; the DSP read then wrote sns_reg_version into the state copy ('version=2') and 174 state files; iio-sensor-proxy started and monitor-sensor reported accelerometer (orientation right-up), ambient light (values changing, lux), proximity sensor and compass. Stopping the daemon afterwards: still 0 crashes. The suite after: 35 pass, 6 fail, 4 not measured - as before (known gaps; deep-sleep soc-sleeps lists adsp never asleep). Not done: motion-and-light and proximity-reads as suite tests with the daemon lasting (it ran as a transient unit and is stopped; the stock unit is masked as before); a witnessed proximity cover; suspend with the helper (sensors-across-suspend). Hand-built binary only; upstream would want the patch shaped for hexagonrpc #19/#29.

Sources
: hexagonrpc-27,hexagonrpc-19

About
: sensors


<a id="2026-11-17-r2-reboot-was-the-fuse"></a>
### 2026-11-17-r2-reboot-was-the-fuse

Date
: 2026-11-17

Brief
: r2's reboot was its own 30 s fuse: after UART irq 157 was disabled, Bluetooth's retry loop stalled a cycle past 30 s; the 25 measure samples average 40 mA, unscored

Question
: Why did surya reboot by itself during standby run r2?

Found
: Read from the pstore console of the dead boot (console-ramoops-0), the journal and r2's logs. r2 (armed 20:08Z, cable out) ran 47 way-back bt-on cycles; 24 slept 0 s, 23 slept 17-19 s. At dmesg 3379 s 'irq 157: nobody cared' (qcom_geni_serial_isr, the BT UART) disabled the IRQ; then hci0 'Injecting HCI hardware error event', 'Freezing user space processes aborted ... 149 tasks refusing to freeze', and the QCA setup retried (command tx timeout, Reading QCA version failed -110, Retry BT power ON 0..2, each about 70 s). The loop kept cycling (a fuse armed every 10 s, 'watchdog did not stop!' each time is normal: busybox watchdog is killed hard by design) until a cycle's arm to defuse took over 30 s while Bluetooth was stuck, and the SoC watchdog reset the phone (console ends at 3646 s, no panic, no oops). So it was no spontaneous fault: the fuse did its job, and r2's loop does not survive a stuck Bluetooth. Scoring: r2 reached 25 measure samples (about 4.5 min of the 60 asked), all charger_online 0, current_now mean -39.6 mA, current_avg -33.8 mA (settle samples -45 mA): not a standby figure, since Bluetooth was in its retry loop and half the cycles did not sleep; unscored. Phone after: boot 20:25 healthy, stock services, kept kernel 7.1.0-sm7150-calls+.

About
: deep-sleep


<a id="2026-11-17-r3-partial-and-the-reset-after"></a>
### 2026-11-17-r3-partial-and-the-reset-after

Date
: 2026-11-17

Brief
: r3 scored PARTIAL: 63 min on battery, median 31 mA (mean 55), gauge avg 26-35 mA, 63% asleep; its own abort rule fired first (irq 157, Bluetooth), the reset came 3 min later

Question
: Why did surya reboot mid-r3, and what did r3 measure before it?

Found
: Order from r3's STOPPED/DONE and journalctl -b -1: scoring began 20:36:44Z (charger_online 0 in all 141 measure samples, post-settle). 21:41:39Z after 3893 s: suspend cycle 'irq 157: nobody cared', IRQ 157 (BT UART) disabled, hci0 command 0x0c01 tx timeout, controller crash dump; r3 stopped itself 'aborted, partial' - the abort rule fired FIRST, run ended on its own, not the phone. Afterwards (r3 over) hci0 setup failed three times (Reading QCA version -110, Retry BT power ON 0,1,2 at 21:42:23, 21:43:34, 21:44:45); journal ends 21:45:00Z with no panic or oops in it, the boot -1 ended 21:45:00 and boot 0 began 21:46:41Z. So the reset happened after r3, in Bluetooth's retry loop, ~15 s after retry 2: fuse or hang, not proven (pstore not readable as user; ramoops empty after boot). Figures, measure phase 792.9-4574.9 s mono, 141 samples, 0 on charger: instantaneous current mean 55.0 mA, median 31.1 mA, p10 22.7 mA, min 21.5, max 143.4 (instantaneous snapshots include wake bursts); fuel gauge current_avg 25.9-35.4 mA (28.7 at end); suspended 2380 s of 3782 s = 63% (suspended_s_cum 51 -> 2431), 289 suspends, 735 wake events. charge_counter is na on this gauge, so no charge-delta score. Against targets: 15 mA and 9 mA NOT met; Android's figure not known yet. A partial: 63 min, not the 75 min the run asks for.

About
: deep-sleep


<a id="2026-11-17-sensors-lasting-install-three-boots"></a>
### 2026-11-17-sensors-lasting-install-three-boots

Date
: 2026-11-17

Brief
: The patched hexagonrpcd is lasting on surya: three boots, 0 ADSP crashes, four sensors each boot; a 10 s freeze with the helper running crashed the ADSP once (it came back in 0.5 s)

Question
: Does the patched hexagonrpcd, installed lasting, keep the sensors without crashing the audio DSP?

Found
: lab/build-hexagonrpcd-sns.sh builds the daemon (hexagonrpc 40e5041 + the patch, static aarch64, aarch64-linux-gnu-gcc, no meson); lab/sensors-install.sh on the phone put it at /usr/local/bin/hexagonrpcd-sns, made the state root /var/lib/hexagonrpcd-sensors from the package tree (registry also under sensors/persist/registry/registry, owner fastrpc), a drop-in 10-state-root.conf (-R) and unmasked sensorspd (rootpd masked). First start: 150 s, 0 crashes; monitor-sensor needed iio-sensor-proxy restarted once (it had started with no sensors), then accelerometer, light, proximity, compass. Three reboots in a row (devlab phone reboot): helper and proxy active, 0 crashes, 4 sensors each time, no ordering fix needed; the watch's health: 37 pass, 0 fail, sensors/motion-and-light and sensors/proximity-reads now pass (known gaps no more). The DSP writes sns_reg_version into the state root (sensors/persist). Across suspend: one way-back cycle 10 bt-on (rtcwake freeze, helper left running): the ADSP logged 'crash detected in adsp: type fatal error' 0.03 s after the suspend exit and was up again 0.5 s later; sensors came back (4); a real systemctl suspend would stop the helper (Conflicts=suspend.target, no restart): unmeasured. n=1.

About
: sensors-without-crash


<a id="2026-11-17-irq157-quiet-with-wakeup-off"></a>
### 2026-11-17-irq157-quiet-with-wakeup-off

Date
: 2026-11-17

Brief
: Four bt-on 15 s cycles (serial wakeup off): no 'nobody cared', irq 157 stays registered, hci0 up each time; each cycle crashes the ADSP (sensor_process)

Question
: Does way-back bt-on (serial power/wakeup off for the cycle) keep irq 157 quiet so Bluetooth-on standby is representative?

Found
: On 7.1.0-sm7150-calls+, USB-powered, 4 consecutive way-back.sh cycle 15 bt-on: dmesg 'nobody cared' count 0, irq 157 still listed, hci0 present after every resume, RTC 17 s asleep of 15, suspend entries and exits clean. cxsd/aosd/ddr stay 0 (soc-sleeps not met, as before). Side finding: every cycle ended with the ADSP fatal 'err_qdi.c EX:sensor_process frpc_dsp' (crashes #2-#5 in the boot; sound card gone, health UNHEALTHY) - the sensors-across-suspend crash is 4 of 4 with the sensorspd helper running, not n=1. A reboot restored healthy (37 pass, 0 fail). So the wakeup-off switch alone already quiets irq 157; r2/r3's 'nobody cared' needs a longer or off-USB run to recur.

About
: deep-sleep


<a id="2026-11-18-r4-aborted-partial-and-the-hang"></a>
### 2026-11-18-r4-aborted-partial-and-the-hang

Date
: 2026-11-18

Brief
: r4 ABORTED (partial): 4 clean samples, median 120 mA, 63% asleep; irq 157 + Bluetooth SSR stopped it at 22:40:48, then sxmo's own suspend loop wedged the phone at ~22:45

Question
: Score r4 and find why surya hung after the run

Found
: r4 (log /var/tmp/standby-r4): USB gone 22:28:35Z (sensorspd stopped), settle 600 s, measure began mono 1319 s. Run stopped itself 22:40:48Z: Bluetooth failed (irq 157 'nobody cared' at 22:40:40 inside the 15 s cycle, hci0 cmd 0x0c01 timeout, controller crash). So the plan's 'no noirqdebug' did not stop irq 157 firing in a bt-on cycle. SCORE: aborted/partial, NOT scorable: only 4 post-settle samples (charger_online 0): current_now 125.9/114.1/60.0/142.4 mA, median 120, mean 111; gauge current_avg 29.4 mA; suspended 51 s of 81 s (63%) in the measure window, 442 s of ~702 s since USB left; instantaneous reads taken awake so biased high; vs 15/9 mA targets: unknown; Android reference not measured; sensorspd restore: never ran (run ended aborted; reboot restored it). HANG: after the stop, sxmo's own autosleep kept calling 'rtcwake -m mem -s 99999999' every 1-20 s while the QCA Bluetooth was in SSR/retry (setting up wcn399x, 'SSR or FW download time out', qca_suspend returned -110 at 22:41:05). Three 'rfkill' processes sat in D state on the misc_open mutex (26697, 26727, 26892; trace repeated every 21 s) until the journal ends at 22:45:01; no pstore, no panic, no hung-task panic: the phone wedged with the USB gadget gone, until the author's forced reboot at 23:56. Cause: a Bluetooth SSR stuck in hci_uart_qca holding the misc/rfkill path while sxmo kept suspending. Not shown: which exact lock holder; why USB died (journal shows no panic).

About
: deep-sleep


<a id="2026-11-18-sensorspd-stopped-no-adsp-crash"></a>
### 2026-11-18-sensorspd-stopped-no-adsp-crash

Date
: 2026-11-18

Brief
: With sensorspd stopped before and started after, 3 of 3 bt-on s2idle cycles crashed no processor; sensors came back each time

Question
: Does stopping hexagonrpcd-adsp-sensorspd around a suspend (what its Conflicts=suspend.target does) stop the ADSP crash on every suspend?

Found
: way-back.sh cycle 15 bt-on stop-sensors x3, watchdog armed, USB attached: no sensor_process/ADSP crash in dmesg (4 of 4 crashed before, with the daemon running); after each restart the daemon was active and iio-sensor-proxy still gave Accelerometer, AmbientLight, Proximity; hci0 present. Suite after: no-processor-crashes, motion-and-light, proximity-reads pass; soc-sleeps still fails (cxsd/aosd 0, adsp never asleep). The unit already carries Conflicts/Before=suspend.target, so a real systemd suspend does this by itself; rtcwake bypasses it, hence the new stop-sensors flag. Not done: a real systemctl suspend path (sxmo) and the sensors-across-suspend streaming read.

About
: deep-sleep


<a id="2026-11-18-systemctl-suspend-leaves-sensors-stopped"></a>
### 2026-11-18-systemctl-suspend-leaves-sensors-stopped

Date
: 2026-11-18

Brief
: A real systemctl suspend stops sensorspd and nothing restarts it; a hook start is refused mid-suspend; try 3 with a delayed start left the phone unreachable

Question
: Does a real systemctl suspend (RTC wake) keep the sensors working, as the manual stop/start did?

Found
: Try 1 (no hook): suspend returned at once (serial wakeup write 'echo 0' was invalid; fixed to 'disabled'), sensorspd stayed inactive after return: Conflicts=suspend.target stops it and Restart=always does not apply, so sensors are lost until a manual start. Try 2 (hook starting it in post): systemctl start refused 'destructive: suspend.target has start job queued'; an earlier suspend entry (09.33) still saw the daemon running and ADSP crashed (sensor_process); sensors gone until daemon started by hand, then restored. Try 3 (hook starts via systemd-run --on-active=3, lab/devlab-sensors-resume): phone stopped answering on USB for 10+ min after the try; fuse defuse ran only on return, so cause unknown (hang or wedge). Not proven; the hook is not landed as a fix.

About
: deep-sleep


<a id="2026-11-18-unreachable-after-suspend-journal"></a>
### 2026-11-18-unreachable-after-suspend-journal

Date
: 2026-11-18

Brief
: Previous boot's journal ends at 'PM: suspend entry (s2idle)' from sxmo autosleep (rtcwake -m mem); no pstore, so no crash proof

Question
: Why was surya unreachable on USB after the third systemctl-suspend try?

Found
: Phone came back (up 1 min, same kept kernel) after the author's power-cycle. /sys/fs/pstore is empty: no oops was stored. The previous boot's last journal line is 'kernel: PM: suspend entry (s2idle)' at 00:10:19, right after a systemctl suspend finished at 00:10:18 and sxmo autosleep ran 'rtcwake -m mem -s 99999999' (a second, nested suspend with no near wake). So: the phone went into a second s2idle straight after resume, because sxmo autosleep was still on, and did not wake on USB; the journal alone does not say whether that is a hang or a missing wake source. Not shown: a FastRPC/ADSP crash. Unproven.

About
: deep-sleep


<a id="2026-11-18-bt-suspend-how-it-stands"></a>
### 2026-11-18-bt-suspend-how-it-stands

Date
: 2026-11-18

Brief
: Surya's BT device tree already equals mainline's s2idle-capable sc7180 wiring (CTS bias aside); failures are sleep/SSR timeouts and a level irq storm; others fix it in user space

Question
: How do other mainline Qualcomm phones with QCA UART Bluetooth survive s2idle, and what is surya missing?

Found
: Read 2026-11-18. (1) Surya's device tree already is the mainline pattern: the live /sys/firmware/devicetree node serial@88c000 has interrupts-extended (GIC 604 + tlmm 41 edge falling), pinctrl default+sleep, bluetooth compatible qcom,wcn3998-bt. Its sleep state: CTS gpio38 bias-bus-hold, RTS gpio39 pull-down, TX gpio40 pull-up, RX gpio41 pull-up. The only mainline QCA UART Bluetooth built to sleep in s2idle, sc7180-trogdor (same GPIO 38-41, same qup03), has the same wiring; its sleep state differs in one pin: CTS gets bias-pull-down 'to match the pull of the Bluetooth module' (surya: bus-hold). So the DT is not what is missing; one pin bias is the only measured-nowhere difference. (2) Mechanism of the failures, from the code: qca_suspend waits only 200 ms for the chip's own HCI_IBS_SLEEP_IND and returns -ETIMEDOUT (suspend then refuses, as in r4 'qca_suspend returned -110'); during SSR it waits up to memdump+3 s then times out. qcom_geni_serial_isr returns IRQ_NONE while uport->suspended, and irq 157 is a level irq: any RX/CTS activity from the chip after the port is suspended, or while a crashed controller keeps talking, is the 'nobody cared' storm. Not measured: whether the storm comes before or after the controller crash (r4 shows both within 8 s, order unread). (3) What others do: mainline gives no hook - Chromebooks (trogdor) rely on in-band sleep plus the RX wake; every desktop/distro remedy found is user space: bluetoothctl power off before sleep (ArchWiki), rfkill block in a sleep hook (pop-os, which breaks BT peripherals and needs a power cycle), and for a QCA UART controller that loses state, unbinding only the serdev from hci_uart_qca before sleep and binding it after (SteamOS 2845, worked across S4). No postmarketOS/Mobian/Droidian rule for qca UART Bluetooth across s2idle was found in two searches (only our earlier note of a pmOS hook stopping Bluetooth for the Pixel 3a FastRPC crash); not found is not absent. (4) Local facts that bound the choice: wakeup off + BT up passed 4 of 4 15 s cycles (irq157-quiet-with-wakeup-off) yet r4 failed at its first long off-USB run; BT blocked (rfkill) hung suspend entry hard twice (surya-s2idle-bt-blocked-hang, sh0-bt-blocked-cycle-resets) - so closing the port is not safe; unbind and power-off by serdev remove were never tried; the r4 wedge was sxmo calling rtcwake in a 1-20 s loop while the controller sat in SSR, with three rfkill processes on the misc_open mutex, not a kernel panic. Ways it could go: A mirror trogdor exactly (CTS pull-down in sleep) and run with the wakeup switch on; B unbind hci_uart_qca (serdev) before suspend, bind after - a clean controller power-off and a full re-setup, never rfkill; C gate sxmo's autosleep on a healthy hci0 (no suspend while SSR or rfkill busy), which cannot fix the storm but removes the wedge; D take Bluetooth off the standby profile (bluetoothctl power off) - the ArchWiki remedy, loses BT peripherals; E patch hci_qca (longer sleep wait, reset on timeout) - upstream-shaped but needs the cause first.

Sources
: src-linux-hci-qca,src-linux-qcom-geni-serial,src-linux-sc7180-trogdor-uart3,src-steamos-2845-qca-uart-resume,src-archwiki-bluetooth-s2idle

About
: deep-sleep

Material
: research/deep-sleep/2026-11-18/


<a id="2026-11-18-bt-trace-20x15-no-crash"></a>
### 2026-11-18-bt-trace-20x15-no-crash

Date
: 2026-11-18

Brief
: 20 x 15 s bt-on s2idle cycles with hci_qca dyndbg and irq 157 trace: no controller crash in any; irq 157 storm in 1 (443 events), bursts of 29-72 in 3 more

Question
: In bt-on s2idle cycles, which comes first: the irq 157 storm or the Bluetooth controller crash (decision 2026-11-18-bt-suspend-way step 1)?

Found
: 20 cycles of 15 s (way-back.sh cycle bt-on stop-sensors, fuse 30 s, sxmo autosleep stopped) through the stopgap sleep/bt-trace.sh: all 20 returned rc 0 with hci0 present. irq 157 (qcom_geni_serial_uart0) entries per cycle: 9-13 in 14 cycles (normal wake exchange), 17-19 in two, 29/48/72 in three, 443 in cycle 10; none saw SSR, 'nobody cared' or a crash, hci0 up. With sensorspd stopped the storm is intermittent and led to no crash here, so there is no crash to order against it. Not done: 3 x 120 s (the fuse is 30 s; way-back.sh allows 15 s at most). Suite after: unchanged. Probe to remove: sleep/bt-trace.sh.

About
: deep-sleep

Material
: research/deep-sleep/2026-11-18-bt-trace-20x15/


<a id="2026-11-18-cts-pulldown-dtb-hangs"></a>
### 2026-11-18-cts-pulldown-dtb-hangs

Date
: 2026-11-18

Brief
: CTS pull-down dtb (qup-uart3-sleep gpio38 bus-hold -> pull-down): phone booted it healthy, then vanished from USB during the first bt-trace 20x15 s run and did not return in 15+ min

Question
: Does the sc7180-trogdor CTS pull-down in qup-uart3-sleep stop the Bluetooth s2idle failures (bt-sleep-cts-pulldown)?

Found
: One-shot dtb built from the installed one with only gpio38 sleep bias changed, tried through devlab kernel try calls --dtb: booted healthy (37 pass, 0 fail), cts-pins bias-pull-down confirmed in the live device tree, way-back check passed. bt-trace.sh 20 15 started as unit bt-trace-cts; afterwards the phone never answered again, not on USB at all, 15+ min, well past the 30 s fuse, so the watchdog way-back did not rescue it. Result not scored: no cycle log read back. Author asked by notification to hold power.

About
: deep-sleep


<a id="2026-11-18-screen-blanks-by-itself"></a>
### 2026-11-18-screen-blanks-by-itself

Date
: 2026-11-18

Brief
: Screen blanking/relight was sxmo's autosuspend loop (swayidle 3 s idle, rtcwake mem) failing on USB; the devlab-usb wake lock stops it

Question
: Why does the screen turn off by itself and come back with no touch; is it ours?

Found
: Read-only, 11:20Z: the phone has devlab-usb-awake active and wake lock devlab-usb held. Boot suspend count 24 (fail 0) did not move over 20 s, so no loop now. sxmo runs swayidle (timeout 3 releases sxmo_not_suspendable) and sxmo_autosuspend.sh: idle blanks the screen and tries rtcwake mem; on USB a suspend aborts and the link drops, giving the lock-screen flicker the author saw. logind shows only the author's power-key presses (11:09-11:13), no bouncing keys. Cause: sxmo idle suspend, not our change; our wake lock is the fix. Plain idle screen-off by sxmo remains normal. soc-sleeps fails by design while awake (24 suspends, cxsd 0). Also seen, not this item: sound card, mic and call-audio-path checks now fail and adsp crashed 4 times after the loop; worth a look.

About
: deep-sleep


<a id="2026-11-18-screen-off-while-typing-key-events"></a>
### 2026-11-18-screen-off-while-typing-key-events

Date
: 2026-11-18

Brief
: Screen-off in use is not suspend or a job of ours; sxmo state follows key events and the volume-down key (pm8941_resin) chatters in 6 ms bursts

Question
: Why does the screen go off while the author is using sxmo (not idle)?

Found
: Read-only, 11:22-11:30Z, wake lock devlab-usb held, suspends steady at 24: not suspend. No lpoco job runs (lpoco-health timer ran once at 08:22; the 11:20 run was mine). sxmo state went lock->screenoff at 11:27:42 with no key, then screenoff->lock->unlock after a real power key at 11:27:49. Key capture: pm8941_resin (KEY_VOLUMEDOWN, event1) shows press/release pairs 6 ms apart in bursts (11:27:57 eight events; 11:25:03 and 11:25:09 alike), and at 11:27:26 and 11:29:16 power, volume-up and volume-down edges land within 20 ms of each other, not a finger. So cause (a) fits: phantom key edges on the PMIC keys that sxmo's input handler turns into state changes; (b) and (c) not seen. Not settled: whether the author touched the keys during the bursts; needs a capture with hands off, and the screenoff transition caught with its sxmo caller.

About
: deep-sleep


<a id="2026-11-18-suspend-flap-stopped-at-1117"></a>
### 2026-11-18-suspend-flap-stopped-at-1117

Date
: 2026-11-18

Brief
: Suspend loop (one per ~38 s) ended after the 11:17:41 resume once devlab-usb stayed held; the lock drops with USB at each suspend, which feeds the loop

Question
: What stopped the screen flapping around 11:17-11:26Z and what started it?

Found
: Journal: last of 24 suspends at 11:17:41, then none; devlab-usb held since 11:18:23 and sxmo_autosuspend blocks while a wake lock is held. Lab root sessions at 11:17:57 and 11:18:27 (content not logged) and sxmo idle daemons restarted 11:18:33 and 11:19:03. devlab-usb-awake (running since 08:20) holds the lock only while the USB gadget is configured, polling every 5 s; a suspend drops USB, so the lock is released and the next idle suspend follows: the loop feeds itself. Mechanism not proven; the weak point is that no lock is held across a resume. Possible fix: hold the lock regardless of USB state unless /etc/devlab-allow-autosleep.

About
: deep-sleep
