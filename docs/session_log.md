<!-- Generated from data/ by tad. Do not edit by hand. -->

# Session Log

<a id="2026-11-17-device-base"></a>
### The device base, from device-template

Entry date
: 2026-11-17

Done
: surya-lab gets its own open tad base from linux-phone-oco/device-template (#4, #5): tables.toml, idealkb.toml (0.9.1), devicebase.toml (parts = 1), generic, records/, queries/ (plus lane-next: a lane's next item by --needs phone|research|build, for the research and build launchers), Makefile, bin/install-tad.sh and install-ikb.sh, the tad CI; AGENTS.md and oco.toml point recording here. device.toml is unchanged (devlab's). Surya's rows move here from docs next, under the keeper lease (docs decision 2026-11-17-commons-and-device-bases).

Considered
: Recording this in docs as before; the base is the place from now on, so its first row is its own making.

---


<a id="2026-11-11-cameras-understood"></a>
### The cameras' fault, understood

Entry date
: 2026-11-11

Done
: Both cameras stay broken, but for a stated reason and with a way in: nothing describes the sensors; the wiring of seven slots is known from the vendor's kernel; the models are not.

Considered
: Naming sensor models from reports.

Rejected
: That: hearsay until a chip answers.

About
: camera-rear

---


<a id="2026-11-11-microphone-nearly"></a>
### The microphone's chain, nearly whole

Entry date
: 2026-11-11

Done
: For the first time the test kernel brought the whole microphone chain up to the codec; one timeout stands between it and a sound card. Measured: the right channel is the bottom speaker.

Considered
: Booting again without reading the bootloader's record.

Rejected
: That: three wrong theories cost three reboots.

About
: audio-mic

---


<a id="2026-11-11-recording-tries"></a>
### The microphone: the route is set, the stream does not start

Entry date
: 2026-11-11

Done
: In the test kernel the main-microphone route sets cleanly; starting a recording fails as the TX SoundWire bus loses the codec when it is reshaped for the stream. Power management ruled out. Next: the bus and port parameters, against the phone's Android kernel.

Considered
: Keeping the bus awake.

Rejected
: That as the answer.

About
: audio-mic

---


<a id="2026-11-17-deep-sleep-researched"></a>
### Deep sleep researched: the path chosen and measured where it starts

Entry date
: 2026-11-17

Done
: The first feature research (prompts/feature-research.md), signed research-deep-sleep. surya read without a change: s2idle only, OS-initiated PSCI, the SoC's sleep counters readable, no suspend yet in a measured boot, CX collapse and AOSS sleep at 0, the audio DSP never asleep, the deepest cluster state never entered. Six research rows (how Qualcomm reaches its floor, what blocks it, the SM7150 cluster parameters against surya's own tables, waking for calls, the other ways, surya measured), the decision with four ways rejected, six steps on the backlog each with its proof, a deep-sleep part with surya's row unknown, and the check soc-sleeps in lab-tools' suite. docs now shares its research and sources tables.

About
: deep-sleep

---


<a id="2026-11-10-flashed-by-devlab"></a>
### Flashed by devlab; the shell flash script retired

Entry date
: 2026-11-10

Done
: surya flashed from the pristine stock image by devlab flash and brought back by devlab provision, all 20 checks passing; flash.sh removed, as planned once devlab had done a real flash. A new check, root-fills-its-partition: the first boot had left the system at 2 GB on a 104 GB partition.

Considered
: Keeping flash.sh as a fallback.

Rejected
: That: two ways to flash drift apart; the shell original stays in git history.

---


<a id="2026-11-10-heard"></a>
### Both speakers heard - then withdrawn

Entry date
: 2026-11-10

Done
: With the author's EarPods as the lab's microphone, devlab hear played a 1000 Hz tone on each speaker and heard both: left at -24.0 dBFS, right at -29.2 dBFS, each over 70 dB above the silent room. The tones are in the manifest. Observed, not judged: the right read 5 dB quieter - the microphone's place or the speakers themselves; one measurement cannot say. WITHDRAWN the same day: the microphone was worn by the author and moved; neither the levels nor the 5 dB difference can be relied on.

Considered
: Calling the 5 dB a fault.

Rejected
: That, on one measurement from one position.

About
: audio-speaker

---


<a id="2026-11-10-its-idea"></a>
### The lab's idea, told for anyone

Entry date
: 2026-11-10

Done
: What this lab is - one particular phone, everything true of it written down, experiments that fall back by themselves - as a piece of writing for a reader who knows nothing of it.

Rejected
: A list of files.

---


<a id="2026-11-10-suspend-crash-found"></a>
### The suspend crash found: a FastRPC helper attached at suspend

Entry date
: 2026-11-10

Done
: After the flash the audio DSP died on every suspend attempt (the attempts abort at once: the USB link cannot go idle). Found by experiment, one change at a time: not a first-boot effect (9 of 9 on the second boot), not the sensor proxy (15 of 15 without it), but hexagonrpcd's RootPD helper - 0 of 8 without it, and 0 of 9 on a clean boot with it masked, all 21 checks passing. Masked in the manifest, so every flash has it. The check's resume counter, which always said 0, rewritten in awk and checked against a boot with 24.

Considered
: A hand-made change the manifest lacked; a first-boot effect; the sensor proxy; a stream left open.

Rejected
: All four, each by its own measurement. The old 'rare' crash was the same one: there the helper died with the first crashes and stayed down.

About
: deep-sleep

---


<a id="2026-11-10-the-ear-withdrawn"></a>
### What the ear heard is withdrawn

Entry date
: 2026-11-10

Done
: The microphone was the author's earphones, worn on his head: its distance from the phone changed as he moved. The levels measured, the difference seen between the two speakers, and the passes themselves cannot be relied on. The heard checks are out of the baseline and the lab's microphone is un-named until one is fixed in place; the tool stays, proven to work mechanically.

Considered
: Keeping the results with a caveat.

Rejected
: That: evidence from an instrument that moves is not evidence, and a later failure would have looked like the phone getting worse.

---


<a id="2026-11-10-usb-flapping"></a>
### The USB link no longer flaps

Entry date
: 2026-11-10

Done
: Reported by the author: the phone kept reconnecting on his PC (26 USB disconnects in 5 minutes on the lab machine). On USB a suspend cannot complete, and the shell retried every 12 seconds, each attempt dropping the link. A small service holds a kernel wake lock while the port is connected to a host - independent of any shell - baked in by the manifest, with a check. Known before, never written down: it is now.

Considered
: Changing the shell's suspend hook.

Rejected
: That: a fix inside one shell does not hold under another, or under none.

About
: deep-sleep

---


<a id="2026-11-11-more-measured"></a>
### More of the phone, measured

Entry date
: 2026-11-11

Done
: Eight of the phone's twenty parts stood as unknown. The checks now also ask: is Wi-Fi joined and does the gateway answer; is Bluetooth powered and does it hear anything; is there a SIM and is the modem ready; does the kernel expose a headset-jack detector, a fingerprint reader, any motion or light sensor, any image sensor behind the camera pipeline. All read-only.

Considered
: Marking parts as working from a device node alone.

Rejected
: That: there and set up is what a machine can prove; the rest are witnessed tests.

---


<a id="2026-11-11-port-table-cleared"></a>
### The port table cleared; a boot spent on a missing tool

Entry date
: 2026-11-11

Done
: The TX bus's port layout and timings match mainline sm8250 and the vendor's layout for the ports in use - not the cause. A boot to dump the SoundWire registers found this kernel has no SoundWire debugfs.

Considered
: Seven ports against the vendor's five as the cause.

Rejected
: That, after comparing the ports actually used. And booting before checking the tool exists - a lesson: check the instrument first.

---


<a id="2026-11-11-the-cameras-understood"></a>
### Why the cameras are dark, and the way in

Entry date
: 2026-11-11

Done
: Read from the phone and from sources, changing nothing: the camera pipeline and its control buses work; the phone's description lists no sensor. The vendor's kernel yields the wiring of seven sensor slots but no model names. Written up with the wiring table and a four-step way in (research/cameras.md).

Considered
: Describing the sensors from the models reported for this phone elsewhere.

Rejected
: That: hearsay. A chip should say what it is, on its own bus, before a driver is bound to it.

About
: camera-rear

---


<a id="2026-11-11-the-codec-comes-up"></a>
### The microphone codec comes up

Entry date
: 2026-11-11

Done
: Traced the codec's timeout to a bus clash on the microphone-side SoundWire bus, and that to one pin muxed to the wrong function in the audio pin driver (and one more on the receive side), read against the phone's own Android kernel. Corrected and rebuilt: the codec initialises and the sound card is made with it. Recording through it is next.

Considered
: The macros' autosuspend; the upstream revert (it gives no reason).

Rejected
: Guessing at clock fixes.

About
: audio-mic

---


<a id="2026-11-11-the-microphone-frontier"></a>
### The microphone's chain, nearly whole

Entry date
: 2026-11-11

Done
: Booted the microphone test kernel (after finding the earlier tries had been given a gzip kernel): for the first time everything up to the codec came up; the card fails on one timeout. Measured which speaker is the bottom one. Saw a boot with no sound card and recorded it.

Considered
: Theories about the bootloader.

Rejected
: Acting before reading the bootloader's own record.

About
: audio-mic

---


<a id="2026-11-11-the-modem-with-a-sim"></a>
### The modem with a SIM

Entry date
: 2026-11-11

Done
: The SIM is seen and ready (1&1). The modem stays shutting-down and refuses to go online, even after a reboot; it loops on one file through tqftpserv, ending each read itself. One theory - a missing read-write directory - was checked and is wrong: the directory exists.

Considered
: A missing directory.

Rejected
: That: the program's own paths showed it exists.

About
: modem-data

---


<a id="2026-11-11-the-recording-map"></a>
### The map to a first recording

Entry date
: 2026-11-11

Done
: Listed the codec's recording side in the test kernel and read how the phone's own Android build routes its main microphone; the names match closely. Found that the kernel branch's pin driver differs from the tested tree - the fix is to be ported, not pasted.

Considered
: Pasting the table change into the branch.

Rejected
: That: the branch's driver is not the one that was tested.

About
: audio-mic

---


<a id="2026-11-11-two-recording-tries"></a>
### Two recording tries

Entry date
: 2026-11-11

Done
: The main-microphone route from the phone's Android build sets cleanly in the test kernel; the capture stream fails when it starts - the TX bus loses the codec exactly when it is reshaped for the stream. Ruled out power management. Measured the audio processor's once-a-second handover signal.

Considered
: Keeping the bus awake.

Rejected
: That as the answer: it changed nothing.

About
: audio-mic

---


<a id="2026-11-17-health-on-the-phone"></a>
### surya checks its own health after every boot

Entry date
: 2026-11-17

Done
: The manifest says what surya is expected to have ([health]: its sound card, three signal processors and what rests on each, the known boot warnings and failed unit with their reasons, and four known gaps - fingerprint, sensors, both cameras); its amplifier checks moved to tests/health/base. devlab suite put the suite on the phone; after a reboot it ran by itself and said healthy: 29 pass, 4 in known gaps, 1 not measured (no SIM card seen: the modem reports sim-missing).

---


<a id="2026-11-17-telegram-provision"></a>
### Telegram at provisioning: telegram-desktop, held by Alpine v3.24

Entry date
: 2026-11-17

Done
: The author asked for a Telegram client at provisioning as firefox is. Alpine ships one Telegram client for aarch64, the official telegram-desktop (no tdlib, no libpurple Telegram plugin for chatty, no Kotatogram); it went into provision/packages.txt (surya-lab #108). Installing it on the phone failed: v3.24 community ships 6.8.5-r0 linked to libada.so.3 while ada is now 4.0, so apk cannot resolve it even after apk update. devlab provision installs the list in one apk add, so the line would have failed firefox and i2c-tools too; it now waits there as a comment (surya-lab fix right after #108). Edge has 7.4.4-r0 rebuilt against libada.so.4. Nothing was installed or changed on the phone.

Considered
: Installing telegram-desktop from the edge repository for one package: it would pull edge libraries into a v3.24 system that another session is testing audio on.

Rejected
: chatty with a Telegram plugin: no such plugin is packaged. Keeping the line live: it breaks the whole package list.

---


<a id="2026-11-17-1000-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Hand-over from the bring-up session (2026-11-17, ~10:00 UTC) to the phone keeper. RUNS: kernel 7.1.0-sm7150-calls+ is the KEPT default (boot entry pmos-calls.conf, blessed); built from linux-phone-oco/linux branch test/surya-calls = tas2562 fixes + PR3 (LPI SoundWire pin mux) + PR5 (SoundWire controllers at 0x62ed/0x62ef, no DCODEC vote) + PR4 (WCD9375 reset: active-low, gpio mux, no sleep state) + PR6 (capture through swr2 DAI 1) + PR7 (q6voice from pulpoff/linux-surya). The proven microphone-only kernel (pmos-mic, 7.1.0-sm7150-mic+) is still installed as a fallback; stock (7.1.0-rc3-sm7150) boots after 3 bad boots. The old /lib/modules/7.1.0-rc3-sm7150-wcd belongs to a removed experiment and can go. HEALTHY: the last runs say healthy, 37-39 pass, 4 known gaps (fingerprint, sensors, both cameras). WORKS, proven by the phone itself: speakers (stereo), earpiece (= the top TAS2564 speaker; the WCD9375 EAR amplifier is silent), both microphones (bottom ADC1, top ADC2 at INP3) through the UCM profile, mobile data (Vodafone.de LTE; tqftpserv 1.3 from Alpine edge, a gsm connection with no APN), SMS (texts its own number, telephony layer, daily), calls both ways (q6voice, Voice Call UCM verb, q6voiced on PCM 0,6, devlab-call-uplink, daily call-echo to blueSIP's echo line +49 89 721010 99701 - its announcement lasts ~19 s). MUST NOT BE UNDONE: the VoiceMMode1 TX Topology 69488 set in the HiFi verb at boot (the DSP builds its voice processor once, at the first call of a boot; a call set up with the default 0x10F71 keeps the uplink silent until a reboot); the codec node has no sleep pin state (ASoC holds it in reset otherwise); /etc/modprobe.d/devlab-pd-mapper.conf (loads qcom_pd_mapper before the ADSP; without it ~1 boot in 5 has no sound card); tqftpserv@edge (1.1.1 keeps the modem in shutting-down); the SIM's own number lives only in ~/.config/devlab/xiaomi-surya/own-number and /etc/devlab/private/own-number - never in a repository. Test sounds are -6 dBFS at 20% (the author: soft). The SIM is in slot 2 (slot 1: no ATR). Never read /sys/kernel/debug/gpio or the LPI pinctrl at 62b40000 (manifest hazards).

Considered
: next: (1) headphones and the headset mic: need a headset plugged in and the author listening (verify-headphone-mic-earpiece; the jack detector exists since the WCD fixes). (2) upstream, waiting for the author to send: upstream-queue linux/sm7150-wcd 0001-0004 (sm7150-mainline), the tas2562 pair, upstream-alpine-tqftpserv, upstream-pd-mapper-order; q6voice is out of tree (sdm845-mainline) - its upstreaming is not ours yet. (3) the kernel is not yet a package: the kept kernel lives only on the phone's boot partition; a reflash returns stock until it goes through the package conveyor (device.toml carries the userspace side: UCM, q6voiced conf, call-uplink, pd-mapper, tqftpserv@edge, the mobile connection). (4) the deep-sleep steps, sensors, off-state charging, as the queue orders.

---


<a id="2026-11-17-1145-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Keeper phone-keeper-20261117-1135: ran sensors-and-the-mask on the kept kernel 7.1.0-sm7150-calls+ (stays the kept default). Result: DSP still writes (temp.json, sns_reg_version) and crashes with only sensorspd unmasked; undone, rebooted, healthy 37 pass 0 fail. Sleep items need the devlab suspend verb (lab-tools health-suspend-cycle, not yet built) so they were not taken; no suspend was tried by hand.

Considered
: next: sleep-measured-once needs the devlab suspend-cycle verb first (lab-tools, soft_connect + wake locks released + rtcwake, counters read before and after); sensors-registry-writes needs a hexagonrpcd build with state-copy writes (a package, then one probe). Must not be undone: sensorspd and rootpd stay masked; configs mtimes restored.

---


<a id="2026-11-17-1225-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Keeper surya-keeper, 2026-11-17. Phone runs the kept kernel 7.1.0-sm7150-calls+ (default; the one-shot dtb with cluster parameters 0x41002244/0x4100c244 was tried once and is gone), healthy 37 pass 0 fail after a reboot. Deep sleep: the first measured suspend cycles (5, by hand: research/deep-sleep/2026-11-17/) show soc-sleeps = fail and the real cause of no sleep so far: the suspend ends at once on the wake-armed, storming serial IRQ 157 (qcom_geni_serial 88c000); and Bluetooth dies across a suspend and hangs the resume, a reboot recovers. sleep-measured-once and sleep-wake-source are done.

Considered
: next: sleep-wake-uart (disable the serial's wakeup and find why it storms), with sleep-bt-resume (rfkill/stop bluetooth before suspend) in the same cycle; then repeat the cycle on the kept kernel for a real number, then sleep-cluster-params on the prepared dtb (decompile /boot/dtbs-calls/qcom/sm7150-xiaomi-surya-huaxing.dtb, sed the two values, dtc, devlab kernel try calls --dtb). Must not be undone: sensorspd and rootpd stay masked. Cycle method: put the script on the phone and run it with systemd-run, never nohup; never read /sys/power/wakeup_count with a wake lock held (it blocks); read sleep length from the RTC, not date or dmesg.

About
: deep-sleep

---


<a id="2026-11-17-sim-removed-skips"></a>
### SIM out: the four SIM checks skip

Entry date
: 2026-11-17

Done
: Added no_sim to the health suite's lib.sh (ModemManager: sim-missing or no SIM object); modem-registered and mobile-data (lab-tools #73, released as devlab-health 0.1.6) and call-echo and sms-loopback (surya-lab #123) now say 'skip: no SIM card'. The SIM check sits before once_a_day, so a skip does not use up the day. Put the suite, rebooted once: modem-registered, mobile-data, call-echo, sms-loopback all skip; 35 pass, 5 fail (only the known gaps), 5 skip. The support status of calls, SMS and data stays 'works'.

Considered
: Detecting the missing SIM per check (the checks already skipped on 'modem state failed', but under that wording and, for the echo call, after the day was marked).

Rejected
: A manifest flag 'sim = false' (a state to keep true by hand; the modem says it itself).

About
: sim-removed-skips

---


<a id="2026-11-17-way-back-decided"></a>
### Deep sleep's way back: decided before the next suspend

Entry date
: 2026-11-17

Done
: Looked around (research 2026-11-17-surya-way-back-inventory): the stock qcom_wdt is stopped in late suspend, so it would not have rescued the first hang; ramoops (4 MiB) and a settable RTC exist. Decided (2026-11-17-deep-sleep-way-back): a patched qcom_wdt module that stays armed through sleep, the RTC set, the log from ramoops; built it for the running kernel (vermagic matches), wrote sleep/way-back.sh and sleep/build-wdt.sh.

Considered
: Timed reboot, USB awake, pstore alone, a kernel rebuild, serial console.

Rejected
: See the decision.

About
: deep-sleep

---


<a id="2026-11-17-way-back-proven"></a>
### The way back proven; the Bluetooth-blocked hang reproduced and recovered

Entry date
: 2026-11-17

Done
: Built and installed the patched qcom_wdt (updates/, stock behaviour until enabled); sleep/way-back.sh verbs check/install/enable/fuse/defuse/collect/cycle. Idle fuse, a probe through a real s2idle entry and the one measured cycle (BT blocked, 15 s) all ended with the watchdog resetting the phone and the phone booting by itself; the cycle hung at suspend entry as before. pstore is empty after a bite; the journal keeps the marker.

Considered
: A longer fuse (the watchdog counts 32 s at most), setting the RTC (not settable).

Rejected
: ramoops as the log (does not survive the reset).

About
: deep-sleep

---


<a id="2026-11-17-1350-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Keeper surya-keeper-3, 2026-11-17. Phone on the kept kernel 7.1.0-sm7150-calls+, healthy after a clean reboot (only the 5 known gaps fail; the SIM is out: modem-registered, mobile-data, call-echo, sms-loopback skip 'no SIM card'; calls/SMS/data stay 'works'). Deep sleep's way back is built and proven (decision 2026-11-17-deep-sleep-way-back, research 2026-11-17-way-back-measured): sleep/way-back.sh in surya-lab (verbs check/install/enable/fuse/defuse/collect/cycle) with the patched qcom_wdt in updates/ (acts as stock until enabled; keep_armed_in_suspend, enable per cycle); the watchdog is 30 s at most, so a cycle sleeps at most 15 s. Idle fuse, probe through a suspend entry and the one measured cycle all reset the phone by the watchdog and it came back with no hands. The cycle (Bluetooth rfkill-blocked) hung at suspend entry again: no 'PM: suspend entry' line, suspend_stats 0/0; with Bluetooth on s2idle ends in 2-3 s on IRQ 157. pstore is empty after a bite, the persistent journal (synced before the arm) is the log. The PMIC RTC cannot be set. After a bite the amp 0x4c read silent: reboot once cleanly after a bite.

Considered
: next: sleep-wake-uart as one change, with way-back.sh cycle SLEEP as the way back: Bluetooth unblocked but the wakeup of serial@88c000 off (or hci_uart/btqca unbound before the suspend) so IRQ 157 cannot end s2idle and the BT UART is not half-powered; then 'cycle 15' (the script blocks Bluetooth itself: add a verb or a flag for the unblocked variant first). Put the script on the phone with devlab phone put and run it with systemd-run (never nohup). After any try that ends in a bite: one clean reboot, read the health. Must not be undone: sensorspd and rootpd stay masked.

---


<a id="2026-11-17-1500-sleep-wake-uart"></a>
### sleep-wake-uart: the wake found (irq 158) and turned off; a cycle of 15 s that lasts, the SoC still not asleep

Entry date
: 2026-11-17

Done
: Looked first: mainline serial_core/qcom_geni_serial/hci_qca read (research 2026-11-17-qca-uart-wake-across-suspend). Traced one short cycle with Bluetooth up: the wake is irq 158 (GPIO 41, the UART RX wake pin, '88c000.serial:wakeup'), not 157. Added way-back.sh cycle SLEEP bt-on (serial power/wakeup off for the cycle, restored after; qcom_stats before/after, RTC-measured sleep, hci0 check). Tests: cycle 5 bt-on twice and cycle 15 bt-on once, all three woke by the RTC alarm (RTC 7, 7, 17 s), the watchdog defused each time, hci0 scanning after, no bite, no reboot needed. Counters from the SoC after the 15 s cycle: cxsd 0, aosd 0, ddr 0, adsp 0 (as before); soc-sleeps fails: 'suspended, yet the SoC never reached its lowest state: cxsd 0, aosd 0; suspends this boot: 7; processors never asleep: adsp; wake locks: devlab-usb'. Whether the cluster low-power states were entered in these cycles: not known yet (cpuidle residency not read in way-back).

Considered
: Rejected for the wake: rfkill block, unbinding hci_uart/btqca, a device-tree change, a udev rule now (decision 2026-11-17-serial-wakeup-off).

About
: deep-sleep

---


<a id="2026-11-17-1500-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Keeper surya-keeper-4, 2026-11-17. Phone on the kept kernel 7.1.0-sm7150-calls+, booted once (up since about 13:45), 7 s2idle suspends this boot, no watchdog bite, no reboot after them; Bluetooth up and scanning; the serial's power/wakeup is back to enabled. Suite after: 35 pass, 6 fail, 4 not measured - the fails are the known ones (fingerprint reader, two image sensors, sensors, proximity) and soc-sleeps; SIM checks skip. Deep sleep: the wake is solved (irq 158, the UART RX pin; way-back.sh cycle SLEEP bt-on), the SoC still does not collapse CX or AOSS: qcom_stats cxsd 0 and aosd 0 after a 15 s cycle, adsp 0 against about 200 for the compute DSP and the modem. sleep-wake-uart and sleep-bt-resume are done (bt-resume: not seen in 3 cycles of at most 15 s). Sensorspd and rootpd stay masked.

Considered
: next: sleep-adsp-awake (rank 1 now): reboot without soundwire_qcom.stay_awake=1 (a one-shot test kernel cmdline through devlab kernel try), then cycle 15 bt-on and read qcom_stats adsp, cxsd, aosd; then find the LPASS vote that holds the audio DSP up. After that sleep-cluster-params on the prepared dtb (decompile /boot/dtbs-calls/qcom/sm7150-xiaomi-surya-huaxing.dtb, sed 0x41002244 and 0x4100c244, dtc, devlab kernel try calls --dtb) and a cycle 15 bt-on. Cycle method: sh /var/tmp/way-back.sh cycle 15 bt-on as a systemd-run unit with StandardOutput=file:, after devlab phone put sleep/way-back.sh; read the RTC, not date or dmesg; a bt-on cycle also records qcom_stats. Not read yet: cpuidle residency per state across a cycle (add to way-back.sh stats if the cluster question needs it).

---


<a id="2026-11-17-1530-lpoco-health-on-the-phone"></a>
### lpoco-health put on the phone

Entry date
: 2026-11-17

Done
: Built devlab from lab-tools main (the installed binary predated #75), ran suite put now, run, list and gather now. Found and fixed the old lib.sh path in 8 device checks; moved one empty report aside; gathered 19 reports into tests/results and filed 6 runs. Health reads as before: 35 pass, 6 fail, 4 not measured, SIM checks skip. The installed devlab (/home/mll/.local/bin/devlab, 14:13) is older than main: not replaced here; runs used wt-k4-labtools/target/release/devlab.

About
: deep-sleep

---


<a id="2026-11-17-1540-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Keeper surya-keeper-4, 2026-11-17 (end). Phone on the kept kernel 7.1.0-sm7150-calls+, one boot (up since about 13:45), 7 s2idle suspends this boot, no watchdog bite. The suite is now lpoco-health on the phone (put 14:10, 21 checks, /usr/bin/devlab-health kept as an alias, old reports moved to /var/lib/lpoco-health): 35 pass, 6 fail, 4 not measured - SIM checks skip; the fails are fingerprint, two image sensors, motion-and-light, proximity-reads and soc-sleeps (cxsd 0, aosd 0, adsp never asleep). Deep sleep: the wake is solved (irq 158, the UART RX pin; way-back.sh cycle SLEEP bt-on keeps Bluetooth up with the serial's wakeup off for the cycle; 3 cycles ended by the RTC alarm, hci0 up); the SoC does not yet collapse CX or AOSS. Sensorspd and rootpd stay masked. The installed devlab in /home/mll/.local/bin (14:13) is older than lab-tools main: use a build of main (cargo build --release -p devlab in a lab-tools worktree) for suite put, list, off, on.

Considered
: next: sleep-adsp-awake (rank 1): reboot without soundwire_qcom.stay_awake=1 (devlab kernel try, one-shot cmdline), then sh /var/tmp/way-back.sh cycle 15 bt-on as a systemd-run unit with StandardOutput=file: (devlab phone put sleep/way-back.sh first; it is on the phone now), read adsp, cxsd, aosd. Then sleep-cluster-params on the prepared dtb. Note: devlab suite put uses the lab as main has it, so a change to the checks must land before put. Open: gather stops on a 0-byte report (one was moved to /var/lib/lpoco-health/empty-reports/).

---


<a id="2026-11-17-1550-lpoco-health-v017"></a>
### lpoco-health v0.1.7 put on the phone

Entry date
: 2026-11-17

Done
: Built devlab from lab-tools main (v0.1.7), suite put now, suite run: 35 pass, 6 fail, 4 not measured as before, the SIM checks skip 'no SIM card', the eight audio and call checks pass again with the old and new lib.sh paths both present; gather now filed 20 runs. soc-sleeps is the one failing check that matters (cxsd 0, aosd 0).

About
: deep-sleep

---


<a id="2026-11-17-sleep-adsp-awake-first-try"></a>
### sleep-adsp-awake: first try

Entry date
: 2026-11-17

Done
: Baseline cycle without stay_awake (the kept kernel has none): adsp 0. Built the macros' hw-vote release (rx, tx, va), tried once as 7.1.0-sm7150-calls-idle with the patched qcom_wdt: healthy, cycle adsp 0. Stopped services live: no change. Phone back on the kept kernel, healthy.

Considered
: Linux holds CX through the UARTs (pm_genpd_summary); the LPI pinctrl also votes LPASS_HW_MACRO.

Rejected
: Polling the phone during a cycle: it hung the phone once (author reset it).

About
: deep-sleep

---


<a id="2026-11-17-1620-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Keeper surya-keeper-5, 2026-11-17 (end). Phone on the kept kernel 7.1.0-sm7150-calls+, healthy (35 pass, 0 fail, 5 known gaps, 5 not measured, no SIM), after one clean reboot from the try kernel 7.1.0-sm7150-calls-idle (installed as pmos-idle; remove with devlab kernel remove idle if not wanted). sleep-adsp-awake: the kept kernel has no stay_awake; the macros' hw-vote release did not change adsp (0), cxsd 0, aosd 0; patch and notes in research/deep-sleep/2026-11-17/. A cycle polled over ssh hung the phone once (author reset it): start the cycle as a systemd-run unit with StandardOutput=file: and leave the phone alone for 3 minutes (ssh answers slowly for about a minute after resume). Linux itself holds CX through the active UARTs (pm_genpd_summary: 88c000.serial, a88000.serial).

Considered
: next: sleep-adsp-awake stays in-progress: read the DSP side before more LPASS code (the ADSP's sensors PD, call audio q6voiced/pd-mapper, remoteproc glink channels, what other subsystem votes for it); a useful awake-idle probe is qcom_stats adsp count without suspending. Also sleep-cluster-params on the prepared dtb. Open: a try kernel needs its own release name (make LOCALVERSION=-NAME, no autoconf rebuild) and the patched qcom_wdt built as module name qcom_wdt in updates/ (way-back.sh refuses otherwise); ocoeco manual wrote rows without project (fixed by hand in PR 218): a gap in ocoeco for repositories whose tables require project.

About
: deep-sleep

---


<a id="2026-11-17-keeper-6-adsp-floor"></a>
### sleep-adsp-awake: the DSP side read, two floor tests

Entry date
: 2026-11-17

Done
: Read the DSP and the others' votes awake; two measured cycles with adsp stopped, then adsp+cdsp+modem stopped (adsp-floor.sh): cxsd/aosd/ddr 0 both times. Phone rebooted once cleanly, suite 35 pass 0 fail. Recorded research, decision 2026-11-17-adsp-is-not-the-floor, backlog.

Considered
: A trace of the rpmh sleep set: no rpmh trace events in this kernel.

About
: deep-sleep

---


<a id="2026-11-17-1650-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Keeper surya-keeper-7: phone on the kept kernel 7.1.0-sm7150-calls+ (the cp.dtb try booted once, healthy 35 pass 0 fail; since then the kept dtb again after the next reboot). 8 cycles 15 bt-on on cp.dtb: real 15 s s2idle, cluster S2 0x4100c244 used, cxsd/aosd/ddr 0. Tracing was left on in ftrace (reset by reboot).

Considered
: next: sleep-cluster-params waits on a deeper decision (what holds AOSS/CX/DDR is unknown); candidates: owner of the SH0 x=1,y=3 sleep vote, qcom_aoss prevent_* knobs, XO/VRM votes, USB gadget, display RSC. Then sleep-wake items.

---


<a id="2026-11-17-floor-research"></a>
### Why the SoC floor is not reached: researched

Entry date
: 2026-11-17

Done
: Read the recorded cycles, qcom_stats and apps_rsc in the tree; two researchers on mainline/other SoCs and downstream/observed SM7150; ranked six holders; chose subtraction; nine backlog items with proofs.

Considered
: S2RAM, other cluster values, a smp2p sleepstate port, a downstream power-mode port.

Rejected
: Anything touching the phone: it is the keeper's.

About
: deep-sleep

---


<a id="2026-11-17-1800-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Keeper-8: phone on the kept kernel 7.1.0-sm7150-calls+, rebooted after the sensors probe, healthy 35 pass 0 fail (5 known gaps). sensorspd and rootpd masked as before, config mtimes restored, nothing kept from the probe. sleep-fastrpc-helpers could not be measured: the probe (research 2026-11-17-sensorspd-probe-still-writes) shows the DSP still writes temp.json and sns_reg_version with the configs current, 7 ADSP crashes in 25 s and the audio card gone until reboot.

Considered
: next: sensors-registry-writes (rank 3, needs phone): build hexagonrpcd with write support limited to a state copy of the registry (hexagonrpc PR #27 commits 40e5041, or the -S state dir of #19, or the #29 patch) for aarch64 musl, seed the copy from the package, serve sns_reg_version, one try per boot; reboot after any try that crashes the ADSP. No hexagonrpc source tree is on the lab yet. Then sleep-fastrpc-helpers (measure sensors after a resume with sensorspd stopped). Also: sleep-cluster-params waits on a deeper decision (research session).

About
: deep-sleep

---


<a id="2026-11-17-1730-keeper9-floor-read-holders"></a>
### floor-read-holders: what is on before a cycle

Entry date
: 2026-11-17

Done
: Read cmdline, clk, regulator, icc, genpd, cpuidle, wakeup_sources, qcom_stats at idle and before way-back.sh cycle 15 bt-on (baseline: cxsd/aosd/ddr 0, modem moves 2137->2147, cdsp 60 fixed). No clk_ignore_unused/pd_ignore_unused (floor-no-ignore-unused closed). remoteprocs hold bi_tcxo xo; cx/mx at 256 from the two serials; usb, ufs, wcn3998 rails on; rpmh bb/rf, camera, gpu, video not held. Late-suspend contents not known yet.

Considered
: next: floor-dsps-never-started (module_blacklist=qcom_q6v5_pas, one try, cycle 15 bt-on). Sensors item skipped: helper crash-loops the ADSP.

About
: deep-sleep

---


<a id="2026-11-17-1810-keeper9-dsps-never-started"></a>
### floor-dsps-never-started: the DSPs are not the holder

Entry date
: 2026-11-17

Done
: One-shot dtb with adsp/cdsp/modem remoteprocs disabled on the kept kernel: cycle 15 bt-on cxsd/aosd/ddr 0 -> 0; soc-sleeps fail (wake lock devlab-usb); no-processor-crashes pass. DSP-vote hypothesis retired. Phone falls back to the kept dtb at the next boot.

Considered
: next: floor-wlan-off, then floor-udc-unbound (devlab-usb wake lock), floor-sh0-owner, floor-aoss-knobs.

About
: deep-sleep

---


<a id="2026-11-17-1840-keeper9-wlan-off"></a>
### floor-wlan-off: WLAN is not the holder

Entry date
: 2026-11-17

Done
: Phone back on the kept dtb after the no-DSP try. ath10k unloaded, cycle 15 bt-on: cxsd/aosd/ddr 0 -> 0, cdsp 60 -> 60. Phone on the kept kernel, healthy as before (wlan returns at the next boot).

Considered
: next: floor-udc-unbound, floor-sh0-owner, floor-aoss-knobs.

About
: deep-sleep

---


<a id="2026-11-17-1900-keeper9-udc-unbound-stuck"></a>
### floor-udc-unbound stalled the phone: a step that can drop USB keeps the watchdog armed

Entry date
: 2026-11-17

Done
: Unbound a6f8800.usb from dwc3-qcom-legacy, ran way-back.sh cycle 15 bt-on, rebound: the lab link did not return (no usb interface, 172.16.42.1 silent 10+ min), WLAN still unloaded from the previous item. The cycle defuses the watchdog on return, so nothing reset the phone: the author's hands (hold power) are needed. Cycle result unread in /var/tmp/k9u.out on the phone: not known yet.

Considered
: Lesson: any step that can drop the only link (UDC unbind, WLAN unload) must leave the watchdog ARMED (way-back.sh fuse 30, not defused) so the phone resets itself, and must not rely on a rebind to bring the gadget back. Next after the reboot: read /var/tmp/k9u.out first, then floor-sh0-owner / floor-aoss-knobs; floor-udc-unbound stays open until measured.

About
: deep-sleep

---


<a id="2026-11-17-1950-keeper9-udc-and-aoss"></a>
### floor-udc-unbound and floor-aoss-knobs measured

Entry date
: 2026-11-17

Done
: UDC unbound: cxsd/aosd/ddr 0 -> 0 (result survived in /var/tmp/k9u.out, phone healthy after the hard reboot: 35 pass 0 fail). aoss knobs: cx/ddr writes time out, 'ucore did not ack channel': the QMP link to the AOP is dead, counters 0 -> 0. Holders subtracted so far with no change: DSPs, WLAN, USB.

Considered
: next: floor-aop-qmp-no-ack (new, read only first), floor-sh0-owner, floor-suspend-late-dump.

About
: deep-sleep

---


<a id="2026-11-17-surya-research-sh0-aop"></a>
### SH0 and AOP QMP researched

Entry date
: 2026-11-17

Done
: Read bcm-voter, sm7150/sm8150/sc7180/sdm845 icc tables, qcom_aoss and the three DTs in the kernel-rc3 tree; found SH0 is keepalive-by-design and the sleep residual a consumer tag; chose DT subtraction; queued phone items.

Considered
: QMP-first, late-suspend dump kernel, keepalive patch, firmware-latch reading

Rejected
: QMP-first and the dump kernel: more build for what one dtb answers; keepalive patch: hides the consumer. Nothing on the phone was touched.

About
: deep-sleep

---


<a id="2026-11-17-1815-keeper10-sh0-owner"></a>
### floor-sh0-owner: uart8 is not the SH0 owner

Entry date
: 2026-11-17

Done
: Read icc_summary; two one-shot dtbs on the kept kernel. Tags ACTIVE_ONLY: ignored (geni-se forces ALWAYS). uart8 disabled: cycle 15 bt-on, sleep flush still has SH0 x=1,y=3; counters 0 -> 0. Phone rebooted to the kept dtb, healthy 35 pass 0 fail.

Considered
: next: floor-sh0-qup-tags by driver unbind not DT tag (BT UART 88c000 with bt off; i2c/spi QUPs; crypto), or a late-suspend dump (floor-suspend-late-dump) to see who holds SH0; SH0 may not come from an icc consumer.

About
: deep-sleep

---


<a id="2026-11-17-1820-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Kept kernel 7.1.0-sm7150-calls+ on the kept dtb, rebooted after the uart8 tries, healthy 35 pass 0 fail (5 known gaps). Nothing kept from the tries.

Considered
: next: floor-sh0-qup-tags (by driver unbind, BT-off cycle), sensors-registry-writes (rank 3), sleep-fastrpc-helpers. sleep-cluster-params waits on a deeper decision.

About
: deep-sleep

---


<a id="2026-11-17-1940-surya-keeper-sh0-bt"></a>
### floor-sh0-owner: BT-blocked cycle

Entry date
: 2026-11-17

Done
: One cycle 15 with BT blocked on the kept kernel: phone reset by the watchdog, no reading; rebooted, healthy except Wi-Fi (saved SSID out of range, lab AP renamed). Nothing kept.

Considered
: next: SH0 looks by-design; a deeper decision on holders (clocks/GDSC/counter validity) or floor-suspend-late-dump

About
: deep-sleep

---


<a id="2026-11-17-1945-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Kept kernel 7.1.0-sm7150-calls+ on the kept dtb, rebooted by the watchdog after a BT-blocked cycle; suite 33 pass 6 fail (5 known gaps + Wi-Fi: the saved SSID is out of range, the lab AP shows another name). Nothing kept from the try.

Considered
: next: floor-sh0-owner is at a turning point (deeper decision), sensors-registry-writes, sleep-fastrpc-helpers

About
: deep-sleep

---


<a id="2026-11-17-2010-surya-research-validity"></a>
### floor-research-validity answered

Entry date
: 2026-11-17

Done
: Read qcom_stats.c, bcm-voter.c, dwc3-qcom.c, the Qualcomm sleep-current guide, the Odin 2 s2idle report; recorded research, decision, 3 backlog items. Nothing on the phone touched.

Considered
: ranked: read entry (trace, IRQ rate) before more subtraction

Rejected
: more SH0 owner-hunting, debug kernel first, calling counters broken

About
: deep-sleep

---


<a id="2026-11-17-1900-floor-entry-trace"></a>
### Floor: the suspend entry read

Entry date
: 2026-11-17

Done
: floor-entry-trace: one way-back cycle 15 bt-on traced; the sleep set is flushed by the last CPU (7) just before cluster-sleep-2 (0x4100b244); one wake IRQ (RTC alarm); floor-irq-quiet dropped; soc-sleeps still fails (cxsd/aosd/ddr 0)

Considered
: next: the holder is not the entry; look at what the AOP or a master holds (floor-sh0-owner stays paused, standby current as arbiter); deeper decision for the coordinator

---


<a id="2026-11-17-1905-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Nothing changed on the phone: kept kernel 7.1.0-sm7150-calls+, last suite (18:51) as at the previous hand-over. The only queue item, sleep-standby-current, needs the author to unplug USB for an hour (and Android booted for its number); marked as waiting for him.

Considered
: next: floor-sh0-owner (turning point), sensors-registry-writes, sleep-fastrpc-helpers; standby current once he can unplug

---


<a id="2026-11-17-2010-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Kept kernel 7.1.0-sm7150-calls+ and kept dtb, stock services as before (sensorspd and rootpd still masked); one try of a patched hexagonrpcd ran sensorspd 150 s with 0 ADSP crashes and showed accelerometer, light, proximity, compass; transient units stopped, suite 35 pass 6 fail 4 not measured (known gaps, deep-sleep soc-sleeps lists adsp never asleep).

Considered
: next: sensors-without-crash (make the patched daemon lasting: build, state root, drop-in, unmask, across suspend), sleep-fastrpc-helpers, floor-sh0-owner (turning point)

---


<a id="2026-11-17-rows-moved-from-docs"></a>
### Surya's rows moved here from docs

Entry date
: 2026-11-17

Done
: Under the lease orchestration-move, in the standby window: all 143 test runs (5456 results) replayed from tests/results through test-run, identical row for row to docs' (runs from before audio-mic left the gaps filed with it); 20 parts seeded from docs' support_status of xiaomi-surya; 48 backlog items (device xiaomi-surya except lab-tools' own, or project surya-lab), 34 research, 23 decisions and 52 log entries (the lab's, those about a moved item, and docs-project ones about surya's own parts and measurements - deep sleep's floor, the sensor registry, the microphone path, standby drain) replayed through ikb, waits '' as none, ranks kept. Abouts naming a milestone or a component docs has but surya claims nothing of (charging, proximity) are left empty; a research or decision without a brief takes its question or decision; a decision's research list keeps its first moved research and names the whole list in why. Method and family research (qcom sleep path, microphones are analog, the echo call's design) stays in docs. Added queries/phone-stands.sql (the keeper's last hand-over). From now on surya records here; devlab gather files runs here (lab-tools #82).

Considered
: Rule of the move: docs decision 2026-11-17-moving-a-lane.

---


<a id="2026-11-17-standby-r1-invalid"></a>
### Standby run r1 is invalid: USB was connected throughout

Entry date
: 2026-11-17

Done
: r1 ran about 85 min on the phone with USB connected the whole time (the author thought the lab link was the blocker), so its current_now/current_avg readings are charger-fed, not standby; recorded invalid, never scored. r2 is queued with a start check that refuses to score while USB power is present.

Considered
: Scoring r1 anyway with charger_online filtering (every sample is online, so nothing scores).

About
: deep-sleep

---


<a id="2026-11-17-2115-standby-r2-armed"></a>
### Standby run r2 armed, waiting for the unplug

Entry date
: 2026-11-17

Done
: standby-run.sh now refuses to score while any USB source is online (ARMED file, no cycles; phase usb never scored; REFUSED after 10800 s). r2 started as unit standby-r2 on the phone, armed (USB present); coordinator told ready to unplug. Phone kept: kernel 7.1.0-sm7150-calls+, stock otherwise, USB link flaky but up.

Considered
: next: on 'plugged back', read /var/tmp/standby-r2/samples.tsv (measure rows with charger_online 0) and record the mainline figure, honestly not at the SoC floor

About
: deep-sleep

---


<a id="2026-11-17-2145-standby-r2-spec"></a>
### Standby run spec: 60 s absence, 30 min wait, 75 min measure

Entry date
: 2026-11-17

Done
: standby-run.sh on main now waits for 60 s without USB power (poll up to 1800 s, else REFUSED 'never unplugged'), writes REFUSED-TO-SCORE into the header, measures 4500 s by default. NOT yet on the phone: the phone left USB (author unplugged) before it could be pushed, so the running standby-r2 is the first guard version (3 polls of 5 s, 3600 s measure, 10800 s wait); r1 was not stopped or marked INVALID on the phone (it was not running then; mark /var/tmp/standby-r1/INVALID when reachable).

Considered
: next: on 'plugged back', score r2's measure rows with charger_online 0 only; check header.txt and ARMED for when scoring began; r2 measures 60 min, not 75

About
: deep-sleep

---


<a id="2026-11-17-2135-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Kept kernel 7.1.0-sm7150-calls+ and kept dtb, stock services as before, booted 20:25 healthy after r2's fuse reset; r2 closed unscored (its stalled Bluetooth retry loop outlasted the 30 s fuse); suite as at 20:26: pass, with known gaps and no SIM skips

Considered
: next: the surya coordinator picks how r3 treats Bluetooth (decision 2026-11-17-r3-waits-on-the-bluetooth-choice), then the author unplugs again; meanwhile sensors-without-crash, sleep-fastrpc-helpers

About
: deep-sleep

---


<a id="2026-11-17-2300-r3-scored-partial"></a>
### r3 scored partial, reset cause read

Entry date
: 2026-11-17

Done
: Read r3's logs and boot -1: abort rule fired first (BT, irq 157, 21:41:39Z), reset ~21:45Z after it in BT retries; scored 63 min partial, median 31 mA, 63% asleep; recorded research and decision for r4.

Considered
: next: author unplugs, r4 with noirqdebug

About
: deep-sleep

---


<a id="2026-11-17-2330-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Kept kernel 7.1.0-sm7150-calls+ and kept dtb; sensorspd unmasked with the patched hexagonrpcd (lab/sensors-install.sh), three boots healthy, 4 sensors, 0 ADSP crashes; r3 scored partial; nothing armed

Considered
: next: devlab-kernel-try-cmdline (lab-tools), then r4 with noirqdebug and the author's unplug; sensors-across-suspend (1 ADSP crash after a freeze with the helper, n=1); the proximity cover witnessed test (author)

About
: deep-sleep

---


<a id="2026-11-17-2230-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Kept kernel 7.1.0-sm7150-calls+, healthy after a reboot (37 pass, 0 fail); irq 157 quiet over 4 bt-on cycles; ADSP crashes after every suspend with sensorspd running (4 of 4)

Considered
: next: stop sensorspd/sensor clients around suspend (or fix sensor_process across suspend) before the r4 standby run; r4 with the author's unplug

---


<a id="2026-11-17-2330-r4-blocked-on-noirqdebug-entry"></a>
### r4: Bluetooth stop landed, noirqdebug entry refused

Entry date
: 2026-11-17

Done
: standby-run.sh now stops bluetooth.service and blocks it when Bluetooth fails; devlab kernel install of the kept kernel with --cmdline noirqdebug refused (running release); half-made entry removed, phone unchanged, kept kernel healthy

Considered
: next: lab-tools lets a cmdline-only entry reuse the running release (or a differently-named build of the same kernel); then install, try, confirm noirqdebug in /proc/cmdline, arm r4. Rejected: hand-editing boot entries (forbidden), faking a release name (modules would not match)

---


<a id="2026-11-17-2345-r4-armed"></a>
### r4 armed: sensorspd stopped for the run, waiting for the unplug

Entry date
: 2026-11-17

Done
: standby-run.sh stops hexagonrpcd-adsp-sensorspd.service when scoring starts (not while waiting for the unplug) and restores it on any ending (trap; DONE.sns); r4 started as unit standby-r4, ARMED + REFUSED-TO-SCORE with USB present, sensorspd still active; serial wakeup off and Bluetooth on come from way-back.sh; no kernel install, no noirqdebug. Finding to record at scoring: sensorspd crashed the ADSP on every suspend (4 of 4), tied to sleep-fastrpc-helpers

Considered
: next: on the unplug, read /var/tmp/standby-r4/samples.tsv (measure rows, charger_online 0), score; confirm sensorspd restored (DONE.sns)

About
: deep-sleep

---


<a id="2026-11-18-0058-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-17

Done
: Kept kernel 7.1.0-sm7150-calls+ and kept dtb, booted 00:56 CET, health 37 pass / 3 known gaps / 0 fail, nothing armed; the only queue item (sleep-standby-current, r4) needs the author's unplug, nothing else waits on nothing

Considered
: next: arm r4 per the coordinator's plan (no noirqdebug, sensorspd stopped, Bluetooth on) when the author can unplug; step 1 (cmdline-only install) no longer needed under that plan; sensors-across-suspend; proximity cover witnessed test

About
: deep-sleep

---


<a id="2026-11-18-r4-scored"></a>
### r4 scored: aborted partial, hang explained

Entry date
: 2026-11-18

Done
: Scored r4 from /var/tmp/standby-r4 (4 clean samples, median 120 mA, 63% asleep, aborted by irq 157 + Bluetooth SSR); read journalctl -b -1 for the hang (sxmo suspend loop with a stuck QCA Bluetooth SSR, rfkill D-state, journal ends 22:45:01); recorded research 2026-11-18-r4-aborted-partial-and-the-hang

Considered
: next: r4 is unscorable, so arm r5 with Bluetooth OFF in the cycle (rfkill block before, unblock after) or irq 157 handled; stop sxmo autosleep (sxmo_wm / rtcwake loop) during the run so a failed run cannot wedge the phone; needs the author's unplug

About
: deep-sleep

---


<a id="2026-11-18-0105-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Kept kernel 7.1.0-sm7150-calls+ and kept dtb, booted 23:56 CET-1 (up, healthy, nothing armed); r4 scored aborted/partial (unscorable) and the hang explained; no change made to the phone this session

Considered
: next: arm r5 when the author can unplug - Bluetooth off during cycles (irq 157 aborts bt-on), sxmo autosleep stopped so a failed run cannot wedge it, sensorspd stopped; sensors-across-suspend; proximity cover witnessed test

About
: deep-sleep

---


<a id="2026-11-18-0010-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Kept kernel 7.1.0-sm7150-calls+ and kept dtb, up, healthy, nothing armed; sensorspd stop/start across suspend measured 3/3 crash-free (way-back.sh stop-sensors flag); suite 37 pass, 4 fail (known: fingerprint, cameras, soc-sleeps)

Considered
: next: prove the same through a real systemctl suspend (sxmo), then mark sleep-fastrpc-helpers done; r5 when the author can unplug

About
: deep-sleep

---


<a id="2026-11-18-0125-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Kept kernel 7.1.0-sm7150-calls+. Three real systemctl-suspend tries for sleep-fastrpc-helpers; the third left surya unreachable on USB (10+ min, no answer): it needs the author's hands (unplug/power-cycle) and a look at the log after

Considered
: next: after reboot check ramoops/pstore and journal -b -1; do not retry the hook until the cause of the unreachable state is known; stop sxmo autosleep first; lab/devlab-sensors-resume (delayed start) is unproven, kept on a branch

About
: deep-sleep

---


<a id="2026-11-18-sign-defused-watchdog"></a>
### Sign: the watchdog was defused for a real suspend and the phone stayed away

Entry date
: 2026-11-18

Done
: A keeper ran the third real systemctl suspend try with the 30 s fuse defused (only re-armed on return); the phone never returned and has not enumerated on USB since; it waits for the author's power cycle (backlog surya-unreachable-after-suspend). The lesson was already written (docs PR 272: a step that can drop the only link must leave the watchdog armed) and the coordinator had asked for it armed on every try while the author is away; it did not reach the keeper, because a launcher run reads the queue, not messages.

Considered
: The sign points at the whole: the rule lives in a lesson (log) but not where the keeper starts; the launcher start reads phone-keeper.md and the item note only. Answer: the rule goes into phone-keeper.md's surya part (via orchestration, docs is theirs): never defuse the watchdog on an unattended try; a suspend that cannot happen with it armed waits for an attended window - and into the note of every item whose try can drop the link.

About
: deep-sleep

---


<a id="2026-11-18-0725-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Took the lease; phone reachable again on kept kernel 7.1.0-sm7150-calls+ (suite latest: audio passes, telephony skip for no SIM). Read pstore (empty) and journal -b -1 (ends at s2idle entry from sxmo autosleep's rtcwake). Changed nothing on the phone.

Considered
: next: sleep-fastrpc-helpers stays open; before any further suspend try stop sxmo autosleep, have the author at hand, and fix a wake source (RTC alarm short, e.g. 60 s) so an unreachable phone returns by itself; do not repeat the hook until then

About
: deep-sleep

---


<a id="2026-11-18-0830-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Unattended scheduled run: took the lease, phone reachable on kept kernel 7.1.0-sm7150-calls+ (up 4 min, sxmo autosleep inactive). Changed nothing; no real suspend run because no witness is at hand (a real suspend needs the attended window, fuse armed, short RTC alarm).

Considered
: next: sleep-fastrpc-helpers waits for an attended window; the other open items need the author (SIM, unplug) or research decisions, so none was taken

About
: deep-sleep

---


<a id="2026-11-18-bt-suspend-research"></a>
### surya-research: Bluetooth suspend-proof researched, decision and phone steps queued

Entry date
: 2026-11-18

Done
: Read mainline hci_qca, qcom_geni_serial, sc7180-trogdor and the live surya node; surya's DT already equals trogdor's except CTS bias. Decision 2026-11-18-bt-suspend-way; backlog bt-trace-cycles, bt-sleep-cts-pulldown, bt-unbind-hook, bt-suspend-gate; check tests/health/base/bt-suspend.sh.

Considered
: serdev unbind, CTS pull-down, suspend gate, power off

Rejected
: rfkill block, noirqdebug, BT off for good

About
: deep-sleep

---


<a id="2026-11-18-0850-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Unattended scheduled run: took the lease, phone reachable on kept kernel 7.1.0-sm7150-calls+ (up 24 min), suite latest unchanged (fingerprint and cameras fail as before, no SIM skips). Changed nothing; bt-trace-cycles (20x15 s + 3x120 s real s2idle with hci_qca dyndbg) not started: it needs an attended window and the trace script is not written

Considered
: next: bt-trace-cycles in an attended window, with a cycle wrapper adding dyndbg and trace_geni_serial_irq to way-back.sh; the other open items need the author or research

About
: deep-sleep

---


<a id="2026-11-18-1200-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Took the lease, read the queue: only item bt-trace-cycles remains, blocked on a longer-fuse way-back for 3x120 s cycles (30 s fuse); no phone change made; kept kernel 7.1.0-sm7150-calls+ unchanged, last suite as before (soc-sleeps fails, rest pass/skip no SIM)

Considered
: next: coordinator decides whether to build a longer-fuse way-back or accept the 20x15 s finding (research 2026-11-18-bt-trace-20x15-no-crash) and close bt-trace-cycles

About
: deep-sleep

---


<a id="2026-11-18-1330-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Took the lease; item bt-sleep-cts-pulldown (unblocked, coordinator accepted bt-trace-cycles). Built the CTS pull-down dtb, tried it: healthy boot, pull-down confirmed live; bt-trace 20x15 s then left the phone off USB for 15+ min (fuse did not rescue). Phone state unknown until power is held; author notified. Kept kernel 7.1.0-sm7150-calls+ unchanged; the dtb was one-shot, never kept.

Considered
: next: after a power hold, read pstore/journal for the hang, then repeat once on the dtb to tell a one-off from the pull-down; if it hangs twice it is a turning point for the coordinator. Rejected: keeping the dtb, or repeating without a power hold (nobody can reach the phone)

---


<a id="2026-11-18-0855-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Took the lease; phone unreachable: 172.16.42.1 and its Wi-Fi 192.168.178.142 (MAC 02:20:43:87:8d:c8, stale in ARP) both time out, no USB gadget net on the host (lsusb shows only the Pixel). Nothing changed on the phone; could not read journalctl -b -1 / pstore for how the pull-down try came back.

Considered
: next: someone with hands checks the phone is on and on Wi-Fi/USB; then read journalctl -b -1, pstore, boot reason, address, record as research, then bt-suspend-gate. Rejected: guessing from the host side

---


<a id="2026-11-18-0905-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Took the lease; item bt-suspend-gate, coordinator's first step: stop sxmo autosleep. The phone answered once (up 39 min, kept kernel 7.1.0-sm7150-calls+, sxmo_autosuspend.sh running, wake lock only devlab-usb, which devlab-usb-awake drops whenever the UDC is not 'configured'), then went off USB twice within 5 min (enp10s0f3u1 vanished; 172.16.42.1 and the other address dead). Nothing changed on the phone: it never held long enough for a write.

Considered
: next: when it answers, make autosleep off lasting through provisioning (device.toml overlay: a wake lock held always, or sxmo's autosuspend off) with a health check 'autosleep off'; hypothesis to test: devlab-usb-awake releases its lock on any non-configured UDC moment, so one USB blip lets sxmo suspend and the link never returns (a deadlock). The phone needs the author's power press now: nobody can reach it. Rejected: writing the provisioning change blind, with no phone to prove it.

About
: deep-sleep

---


<a id="2026-11-18-1500-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Phone silent (no known address); changed nothing on it. Wrote and landed the repo part of sxmo-autosleep-off-lasting: devlab-usb-awake holds the wake lock always, autosleep-off health check. Kernel kept 7.1.0-sm7150-calls+ unchanged.

Considered
: next: when surya answers, provision the new devlab-usb-awake (overlay) and run the suite for autosleep-off; then the pending pstore/journal read after the power hold, and the dtb repeat. Rejected: stopping sxmo_autosuspend by superctl - the wake lock needs no sxmo knowledge

---


<a id="2026-11-18-1700-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Phone still silent (no known address); changed nothing on it. Kernel kept 7.1.0-sm7150-calls+ unchanged as last known.

Considered
: next: when surya answers, provision devlab-usb-awake overlay, run suite for autosleep-off, then the screen-turns-off-by-itself question read-only (journal, sxmo idle hooks, pwrkey events)

---


<a id="2026-11-18-1125-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Phone answered in a window; kernel 7.1.0-sm7150-calls+ unchanged, devlab-usb-awake already live, wake lock held, no suspend loop now. Screen question answered read-only (sxmo autosuspend; research recorded). Not run: reboot or reflash. Audio checks fail since adsp crashes.

Considered
: next: look at the audio/adsp regression after the loop (reboot only through devlab, tests first)

---


<a id="2026-11-18-1140-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Kept kernel 7.1.0-sm7150-calls+ unchanged, healthy; devlab-usb wake lock held, autosleep checks pass, no suspend since 11:17:41; screen-by-itself item closed (cause: sxmo autosleep loop, fixed by the lock)

Considered
: next: phone-next queue; soc-sleeps still fails (cxsd/aosd 0) - deep-sleep research continues

---


<a id="2026-11-18-1745-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Phone awake and answering (up 3 h, kernel 7.1.0-sm7150-calls+ kept, autosleep service active). bt-suspend-gate done: devlab-usb-awake also holds the wake lock while hci0 is not UP or an rfkill is in D state, even with /etc/devlab-allow-autosleep; installed on the phone; test autosleep-bt-gate added (the suite run on the phone still uses its installed tests, so it did not show it yet)

Considered
: next: queue's next item via phone-next; install tests/health on the phone so autosleep-bt-gate shows in the suite

About
: deep-sleep

---


<a id="2026-11-18-1145-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Phone awake, kernel 7.1.0-sm7150-calls+ kept, autosleep service inactive, usb-awake active, nothing changed this run. sleep-fastrpc-helpers not tried: two real systemctl suspends already left the phone unreachable with no log, so a third is a turning point for the coordinator

Considered
: next: coordinator decides how the sensorspd restore across a real suspend is tried (the phone may need hands to come back); else take the next queue item

---


<a id="2026-11-18-1250-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Real systemctl suspend try 4 with fuse armed: the phone left USB at ~11:46 and had not returned or reset after an hour. It is unreachable (kernel 7.1.0-sm7150-calls+ was kept, health was green before the try).

Considered
: next: author power-cycles surya; then read /var/tmp/sus-try/*, pstore (way-back collect) and the previous boot's journal to see whether the fuse armed; do not run another real suspend before that

About
: deep-sleep

---


<a id="2026-11-18-1220-try4-read-back"></a>
### Try 4 read back (read only)

Entry date
: 2026-11-18

Done
: Read /var/tmp/sus-try, pstore, journals, boot list on surya after the author's power hold: fuse never bit, a stray rtcwake -m mem -s 99999999 followed the fuse marker; recorded research 2026-11-18-try4-read-back. Nothing suspended, phone untouched.

Considered
: next: find who ran rtcwake -m mem -s 99999999; cycle probe attended; no real systemctl suspend unattended

About
: deep-sleep

---


<a id="2026-11-18-1225-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Phone awake, up ~1 min after the author's power hold, kernel 7.1.0-sm7150-calls+ kept, watchdog check passes (keep_armed N until enable, by design). Try 4 read back read-only (research 2026-11-18-try4-read-back); nothing changed on the phone.

Considered
: next: surya-unreachable-after-try4 stays in-progress: trace who ran rtcwake -m mem -s 99999999; cycle probe attended; no unattended real systemctl suspend

About
: deep-sleep

---


<a id="2026-11-18-1850-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Phone awake, kernel 7.1.0-sm7150-calls+ kept, devlab-usb lock held (autosuspend blocked). Answered who-runs-rtcwake-99999999 (sxmo_autosuspend -> sxmo_suspend.sh), prepared the attended probe note

Considered
: next: coordinator asks the author for the go on health-cycle-probe-attended; install tests/health on the phone for autosleep-bt-gate

About
: deep-sleep

---


<a id="2026-11-18-1405-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Ran the attended probe (cycle 10 probe) with the author's go: phone stayed up on the same boot until 13:58:14 (~35 s after arming), then left USB and had not returned 6+ min later. Reset vs hang not read. Phone is DOWN: the author holds power ~10 s and boots it.

Considered
: next: after the power cycle read pstore + previous journal (reset or hang?); why keep_armed_in_suspend=N; no real suspend try until the fuse is shown to bite and the phone to return

About
: deep-sleep

---


<a id="2026-11-18-1310-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Read the 13:58 probe drop (read only): hang after a clean resume, pretimeout fired, no reset; recorded. Phone awake, kernel 7.1.0-sm7150-calls+ kept, wake locks devlab-usb sxmo_modem_warming_up sxmo_not_suspendable held, way-back check ok, suite 12:18Z healthy apart from known fingerprint/camera fails and no-SIM skips

Considered
: next: no suspend try until the coordinator decides the way back from a hang with CPU1 stalled; health-cycle-probe-attended waits for the author

About
: deep-sleep

---


<a id="2026-11-18-1325-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Phone awake, up since 13:09 after the author's power hold, kernel 7.1.0-sm7150-calls+ kept, healthy. Read the previous boot: the fuse bit (pretimeout then reset, pstore empty) but the phone did not boot itself after; recorded.

Considered
: next: attended window for reset-reason read (health-cycle-probe-attended); surya-kernel-pmic-wdt build is the next unattended item

About
: deep-sleep

---


<a id="2026-11-18-1410-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Awake on kept kernel 7.1.0-sm7150-calls+, suite healthy (44 pass, 3 known gaps, 0 fail). resume-stall-way-back done: sysctl panic_on_rcu_stall=1, panic=5 via /etc/sysctl.d/90-lpoco-way-back.conf (also a device.toml overlay); no suspend run, nothing flashed. ramoops is not reserved (way-back-ramoops-present fails) - new item ramoops-reserved-dt

Considered
: next: coordinator asks the author for the go on health-cycle-probe-attended; ramoops-reserved-dt needs a dt change, coordinator to decide; install tests/health on the phone for autosleep-bt-gate

---


<a id="2026-11-18-1530-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Took ramoops-reserved-dt with the author's go. Read first: ramoops is already in the live dtb and bound, so no reboot/dtb try was made; the proof test grepped iomem for a word it never prints, fixed to the bound platform device, passes. Phone untouched: kernel 7.1.0-sm7150-calls+ kept, awake, watchdog as before.

Considered
: next: resume-stall-repro-attended (the panic kept in pstore, attended); the dtb try was rejected as pointless. The go for it is spent unused.

About
: deep-sleep

---


<a id="2026-11-18-1435-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Installed sxmo-utils@lab 1.18.1_p20261118-r0 (repo tagged @lab in /etc/apk/repositories; modemmanager/mmsd-tng/vvmd pinned in world so apk did not purge them). Awake, kernel 7.1.0-sm7150-calls+ kept, wake lock held, suite 44 pass 0 fail, no suspend, watchdog untouched.

Considered
: next: ramoops dtb try then the two suspend tests, both attended with the fuse armed; lab-tools: sxmo-utils-common drops the modemmanager dependency

About
: sensors

---


<a id="2026-11-18-2000-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Keeper took the lease; surya answers at no address and is not on USB (lpoco lab phone sh: does not answer; lsusb shows only the Pixel). Nothing changed. Last known: kernel 7.1.0-sm7150-calls+ kept. Needs the author's hands (power cycle or cable).

Considered
: next: coordinator asks the author to check surya's cable and power; then surya-kernel-pmic-wdt

About
: deep-sleep

---


<a id="2026-11-18-2100-surya-follows-template"></a>
### surya-lab follows docs' device layer

Entry date
: 2026-11-18

Done
: devicebase.toml pins linux-phone-oco/docs 0.17.0 (own empty); tables.toml device tables between device:begin/end; tad check green. Repo-only, phone untouched

Considered
: next: surya still not answering; needs the author's cable/power

About
: surya-follows-template

---


<a id="2026-11-18-2100-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Keeper took the lease; surya still answers at no address (lpoco lab keeper take ok, phone sh: does not answer). Phone untouched. Landed repo-only item surya-follows-template (PR 258): devicebase pin docs 0.17.0, device markers, tad check green. Last known kept kernel 7.1.0-sm7150-calls+.

Considered
: next: author's hands (cable/power) for surya; then surya-kernel-pmic-wdt; no phone item is ready

About
: deep-sleep

---


<a id="2026-11-18-1800-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: surya answers on kept kernel 7.1.0-sm7150-calls+, healthy (44 pass, 0 fail, 6 not measured, no SIM). Closed surya-silent-after-sxmo-apk: cable event (usb0 carrier down 15:36-17:47), no suspend, ModemManager still installed, sxmo-utils installed. Nothing flashed.

Considered
: next: surya-kernel-pmic-wdt (build + one-shot try only; never arm the PMIC bite until reset type proven to restart, author present - walleye power-off caution). Findings for the upstreams coordinator: (1) packaging ok on phone, ModemManager present (2) no apk-time restart of NM/tinydm seen.

---


<a id="2026-11-18-1820-pmic-wdt-kernel-tried"></a>
### PMIC watchdog kernel built and tried once

Entry date
: 2026-11-18

Done
: Built surya's calls branch (test/surya-calls) + the 4 pmic-wdt commits (cherry-picked clean, pm6150 hunk merged by itself) + &pm6150_wdt okay/wakeup-source in sm7150-xiaomi-common.dtsi (surya-audio/wt-pmic-wdt, uncommitted-upstream; CONFIG_PM8916_WATCHDOG=y, LOCALVERSION -sm7150-pmicwdt so the kept kernel's modules are not overwritten). Installed as pmicwdt, one try: booted in 71 s, healthy 44 pass 0 fail. Read-only probe: pm8916-wdt bound at pon@800 as /dev/watchdog0 (qcom_wdt is watchdog1), power/wakeup 'disabled' until opened. Returned to kept kernel 7.1.0-sm7150-calls+, health healthy, way-back check passes. The PMIC watchdog was not opened or armed: reset type (restart vs power-off, walleye caution) is unproven.

Considered
: next: the author present to arm a PMIC bite and read the reset type (walleye decision 2026-11-18-walleye-pmic-bite-read-then-warm); item surya-kernel-pmic-wdt stays open (proof pmic-wdt-bites). Image.gz is refused by kernel install: use the EFI-stub Image. Build tree ~/Projects/surya-audio/obj-pmic-wdt

About
: deep-sleep

---


<a id="2026-11-18-1830-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Runs the kept kernel 7.1.0-sm7150-calls+, healthy (44 pass, 0 fail, no-sim), way-back check passes, qcom_wdt not keep-armed (N) as usual. Test kernel pmicwdt stays installed (not kept), not booted. Done this run: pmic-wdt kernel built+tried read-only; drop-stale-generic-file.

Considered
: next: author's hands for a PMIC bite try; otherwise no phone item is ready

About
: deep-sleep

---


<a id="2026-11-18-1930-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Took lease; surya answers again. Reinstalled pmicwdt, one try (61 s, healthy 44/0 fail), read PON S2_CTL=0x07 S2_CTL2=0x00 read-only, no watchdog opened. Back on kept kernel 7.1.0-sm7150-calls+, healthy, way-back check ok.

Considered
: next: send the S2_CTL values to the surya coordinator for the upstreams coordinator; the bite only with the author present; then sxmo-config-migration

About
: deep-sleep

---


<a id="2026-11-18-1855-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Keeper took the lease; surya answers again (author's hands earlier), kept kernel 7.1.0-sm7150-calls+, way-back.sh check passes, watchdog armed state ok, nothing changed this run. The only ready item, surya-kernel-pmic-wdt, needs its bite step (S2_CTL read with /dev/watchdog0 open, then unfed 20-30 s bite) attended: no witness on a scheduled run, so not done.

Considered
: next: author present at the phone for the PMIC bite (kernel pmicwdt installed; register read S2_CTL=0x07, S2_CTL2=0x00 already recorded); then surya-pmic-wdt-proof. No other phone item is ready.

About
: deep-sleep

---


<a id="2026-11-18-1955-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Keeper took the lease; surya answers again (phone sh ok), running the kept kernel 7.1.0-sm7150-calls+; nothing changed on the phone. The PMIC-wdt kernel was built and tried once at 18:20 (S2_CTL=0x07, S2_CTL2=0x00 read); what remains of surya-kernel-pmic-wdt is the BITE, which needs the author at the phone to press power if it powers off - not run unattended, no watchdog defused.

Considered
: next: the bite only in an attended window (author present, told what to expect); sxmo-config-migration (read-only) is the other ready item

About
: deep-sleep

---


<a id="2026-11-18-1910-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Took lease; item surya-kernel-pmic-wdt: read-only facts sent to coordinator; attended PMIC bite run in the author's witnessed window: restart PASS, then boot loop every ~35 s on calls+, now not answering (19:09Z). Backlog item left open (not marked done: phone not left known-working).

Considered
: next: author's power hold (15 s) then a boot; then check way-back.sh check passes on calls+; keep pm8916-wdt out of the kept kernel until it can stop S2 on its own or the kept kernel carries the driver

About
: deep-sleep

---


<a id="2026-11-18-1915-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: Took the lease; surya answers again on the kept kernel 7.1.0-sm7150-calls+ (qcom_wdt is watchdog0 there). Read PMIC regmap 0-00 read-only: 0x856=01, 0x857=00 (S2 disabled), phone up >2 min, no loop. pmic-loop-recovery done. Nothing flashed, no writes, no suspend.

Considered
: next: way-back-pick-watchdog-by-identity (repo + dry run, fuse arms the APSS node, nothing suspended), then surya-kernel-pmic-wdt (BITE attended only); way back from a PMIC loop is the eOS-recovery power-off

About
: deep-sleep

---


<a id="2026-11-18-2200-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: surya answers again (kept kernel 7.1.0-sm7150-calls+, phone sh ok). Took the only ready item surya-kernel-pmic-wdt: its build and one-shot try were done earlier (log 2026-11-18-1820-pmic-wdt-kernel-tried) and the attended bite proved a restart (research 2026-11-18-surya-pmic-bite-restarts), so nothing remained that is safe unattended; no phone change made this run.

Considered
: next: item stays open for its last step - boot the pmicwdt kernel (driver stops S2) as the kept one, attended, with the author told a power cycle may be needed; then way-back-pick-watchdog-by-identity (sleep/way-back.sh wd=/dev/watchdog0 is the PMIC one on that kernel). way-back.sh check not run: /root/way-back.sh not readable by phone sh, use lpoco lab phone root.

About
: deep-sleep

---


<a id="2026-11-18-2330-steps-claimed"></a>
### Surya's bring-up steps claimed

Entry date
: 2026-11-18

Done
: steps=1 in devicebase.toml; all 113 chain steps claimed from suite run 20261118-191339 (kernel 7.1.0-sm7150-calls+): done 11, partial 2, failing 12, open 6, unknown 82. Records only; no phone change; pmic-wdt item left for an attended window (no witness now)

Considered
: next: coordinator runs docs feeds; way-back-pick-watchdog-by-identity

About
: deep-sleep

---


<a id="2026-11-18-2335-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: unchanged: kept kernel 7.1.0-sm7150-calls+ and stock fallback; no phone change this run; the steps claimed in the base

Considered
: next: surya-kernel-pmic-wdt last step is attended (needs author at phone, fuse/power-cycle warning); way-back-pick-watchdog-by-identity next unattended

About
: deep-sleep

---


<a id="2026-11-18-2050-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: unchanged: kept kernel 7.1.0-sm7150-calls+ and stock fallback, watchdog defused after a seen dry run (way-back.sh check passes). Took way-back-pick-watchdog-by-identity: way-back.sh and standby-run.sh pick the APSS watchdog by parent device, WORKAROUND(kept-kernel-with-pmic-wdt) marked, new health check. surya-kernel-pmic-wdt: only the attended bite remains (nothing done on it).

Considered
: next: surya-kernel-pmic-wdt bite and pmic-bite-then-pmicwdt-boot-check need the author at the phone; other ready: sxmo-config-migration, surya-steps-map-history

About
: deep-sleep

---


<a id="2026-11-18-2035-adsp-audio-restart"></a>
### A boot whose ADSP had no audio services: restart cured it

Entry date
: 2026-11-18

Done
: Suite 20261118-202828 on the kept kernel (boot 19:12) failed 11: no sound card. Read only: pinctrl@62b52000 (lpass lpi) never bound, rx/tx macros, codec, sound all deferred; no q6 audio modules loaded. Restarted the ADSP through its remoteproc (stop, 3 s, start): card X3 registered, suite 20261118-202945 healthy (44 pass, 3 known gaps: fingerprint, two cameras). So the 12 failing claims of run 191339 were that boot, not the kernel; reclaimed 11 as done/partial from 202945, image-sensor-identified stays failing (0 sensors bound, real).

Considered
: next: why that boot (after the author's power cycle) came up without the ADSP audio services - a boot-time health check plus ADSP restart as the way back is worth a backlog item. Not run: the PMIC bite (attended)

About
: audio-speaker

---


<a id="2026-11-18-2040-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: unchanged: kept kernel 7.1.0-sm7150-calls+ with stock fallback; fresh suite run 20261118-203254 (72 pass, 5 fail incl. awake-service-active: lpoco-awake inactive, wake lock held by devlab-usb; fingerprint/image-sensor expected); step mapping found no claimable proofs among 82 unknown

Considered
: next: surya-kernel-pmic-wdt bite attended; way-back-pick-watchdog-by-identity; surya-adsp-audio-boot-race; sxmo-config-migration

About
: deep-sleep

---


<a id="2026-11-18-2359-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: kept kernel 7.1.0-sm7150-calls+ with stock fallback, healthy (suite 20261118-203654: 71 pass, 0 fail beyond known gaps). Done: surya-awake-from-package - wake lock now from lpoco-awake.service, hand-put devlab-usb-awake removed, no gap, stale autosleep-off check retired.

Considered
: next: surya-kernel-pmic-wdt and kept-kernel-with-pmic-wdt need the attended window; unattended next: sxmo-config-migration, surya-adsp-audio-boot-race, surya-step-checks. Rejected: taking surya-kernel-pmic-wdt unattended (never defuse).

---


<a id="2026-11-18-2100-sxmo-config-migration"></a>
### sxmo config migration cleared

Entry date
: 2026-11-18

Done
: The 4 .needs-migration files (foot.ini, sxmo/conky.conf, profile, bonsai_tree.json) were the package's defaults for sxmo-utils 1.18.1_p20261118@lab; diffed each: the defaults are OLDER than the files on the phone (profile: typo 'countryu'; bonsai: delay_duration in ns without delay_unit, power_released not power_pressed; foot: [colors] without [key-bindings]; conky: own_window_argb_value). Kept ours (no lab edits in them; taking the defaults would downgrade). Backed up all 8 files to /home/user/migration-backup-20261118 on surya, removed the markers; sxmo_migrate.sh state says all up to date. No restart, wake lock untouched.

Considered
: THE CLASS: a user-config copy drifted from its source when the package upgraded; here the fork's defaults lag the configs, so the next sxmo-utils install may flag them again. Our configs carry no deliberate lab change, so nothing to move into the fork or device.toml; the upstreams lane should check the fork's configversion hashes against upstream 1.18.1 (open item if it recurs).

Rejected
: taking the new defaults (older, would revert fixes); running interactive sxmo_migrate.sh (needless, risks sxmo restart)

About
: deep-sleep

---


<a id="2026-11-19-0000-how-the-phone-stands"></a>
### How the phone stands

Entry date
: 2026-11-18

Done
: kept kernel 7.1.0-sm7150-calls+ with stock fallback, unchanged, healthy (last suite 20261118-203654). Done: sxmo-config-migration (markers cleared, configs kept, backup on phone).

Considered
: next: surya-kernel-pmic-wdt and kept-kernel-with-pmic-wdt need the attended window (never defuse unattended); unattended next: surya-adsp-audio-boot-race, surya-step-checks. 

About
: deep-sleep
