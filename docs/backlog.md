<!-- Generated from data/ by tad. Do not edit by hand. -->

# Backlog

<a id="off-state-charging"></a>
### The phone cannot stay off: shutdown and a charger both boot pmOS

Status
: open

Note
: Seen 2026-11-09. poweroff in pmOS boots pmOS again. The same shutdown from the EOS recovery on the phone stays off, until a charger is plugged in; then pmOS boots instead of Android-style off-mode charging (battery on screen, system off). So the hardware can stay off; pmOS or the boot chain does not. Not diagnosed. After the audio work.

Waits
: the decision of a feature research session: the author has hard ones researched first (2026-11-17)

Opened
: 2026-11-09

Needs
: phone

Rank
: 20


<a id="no-sound-card-boots"></a>
### Boots that come up without the sound card

Status
: done

Note
: 







































































On 2026-11-11 one stock boot had no phone sound card: the audio processor ran with no crash, but its service channel (APR) never appeared, so no audio driver loaded. A reboot restored it. Next: a run of reboots to measure how often.

Done 2026-11-17: the ADSP sometimes booted before qcom_pd_mapper was loaded; device.toml now carries lab/devlab-pd-mapper.conf (softdep qcom_q6v5_pas pre: qcom_pd_mapper) to every flash - 21 of 21 boots with the sound card. Upstream form: docs upstream-pd-mapper-order.

Opened
: 2026-11-11

Needs
: phone

Proof
: sound-card


<a id="telegram-at-provisioning"></a>
### Telegram client at provisioning: uncomment telegram-desktop in provision/packages.txt

Status
: open

Note
: Alpine v3.24 telegram-desktop 6.8.5-r0 needs libada.so.3, gone with ada 4.0; edge 7.4.4-r0 is rebuilt. Check with: echo apk add --simulate telegram-desktop | devlab phone root. When it passes, uncomment the line and apk add it on the phone.

Waits
: Alpine v3.24 rebuilding telegram-desktop against ada 4 (libada.so.4)

Opened
: 2026-11-17


<a id="gps-measurable"></a>
### GPS: a component and a failing test, so location can be measured

Status
: open

Note
: The author, 2026-11-17: lp-connected needs the feature gps, but components has no GPS row, so nothing can measure it. Add the component and a failing test first; on SM7150 location comes through the modem (QMI LOC / ModemManager location). Then research the way.

Waits
: the decision of a feature research session: the author has hard ones researched first (2026-11-17)

Opened
: 2026-11-17

Needs
: phone

Proof
: gps-fix

Rank
: 30


<a id="sim-removed-skips"></a>
### Checks that need the SIM skip, not fail, while it is out

Status
: done

Note
: Done 2026-11-17 (lab-tools #73 no_sim helper, surya-lab #123): with the SIM out, modem-registered, mobile-data, call-echo and sms-loopback say 'skip: no SIM card' (before the once-a-day stamp, so a skip costs nothing). After one reboot on devlab-health 0.1.6: 35 pass, 5 fail (the known gaps: fingerprint, sensors, cameras), 5 skip; calls, SMS and data stay 'works' at their last real measurement.

Opened
: 2026-11-17

Needs
: phone


<a id="mic-capture"></a>
### Sound recorded through the microphone

Status
: done

Note
: 



































































Two tries on 2026-11-11 in the test kernel. The Android route sets cleanly (TX DEC0 MUX=SWR_MIC, TX SMIC MUX0=ADC0, TX_AIF1_CAP Mixer DEC0, ADC1_MIXER, ADC1, MultiMedia2 Mixer TX_CODEC_DMA_TX_3) and the card's routing wires mic bias to AMIC1-3. Starting the capture stream fails: the TX SoundWire bus can no longer read from the codec (read underflow at DPN_PortCtrl of port 1; 'Program transport params failed'), so no recording is made. Not power management: the same with the bus, macros and codec kept awake. Next lead: the moment of failure is when the bus is reshaped for the stream - compare the TX controller's frame and port parameters with the phone's Android kernel. Compared with the Android kernel: the TX bus's port layout and timings match (ports 2-5 as on sm8250 mainline and the vendor), so not the port table. The first read of a port register (DP1 PortCtrl) at stream prepare fails while hundreds of codec register accesses worked at init. Next: trace the bus's transfers (dynamic debug on the SoundWire bus and the qcom controller, or a kernel with SoundWire debugfs - this one has none). Parked 2026-11-12: the lab-agent redesign after the 2026-11-11 incident comes first; resume from the next step above (order: open-commons-observatory decision 2026-11-12-the-redesign-first).

Done 2026-11-17 (bring-up): sound is recorded through both microphones on the kept kernel and through the UCM profile; proven by mic-hears-speaker and mic-top-hears-speaker. See docs backlog microphone and mic-ucm-capture.

About
: audio-mic

Opened
: 2026-11-11


<a id="mic-codec-init-timeout"></a>
### The microphone codec times out at initialisation

Status
: done

Note
: Solved 2026-11-11: the audio pin driver muxed gpio19 (TX SoundWire data) to function 1 and gpio23 (RX data) to 3, where the phone's own Android kernel has 3 and 2. With both corrected the TX bus no longer clashes, the codec initialises and the sound card is made with the codec on it. The clocks going to 0 were a consequence, not the cause.

About
: audio-mic

Opened
: 2026-11-11


<a id="modem-shutting-down"></a>
### The modem stays in shutting-down and will not go online

Status
: done

Note
: 





































































The modem stays in shutting-down from boot with the SIM in. tqftpserv 1.1.1 is installed; its read-write base is /tmp/tqftpserv and exists (an earlier note said a directory was missing - wrong: it checked the wrong paths). The loop: the modem writes /readwrite/lctoem.tmp, reads it back with rsize=0 seek=0, and itself ends the transfer at once - the option handling the Fairphone fix (pmaports !4747) changed. Next: compare tqftpserv 1.1.1 with upstream's rsize and seek handling, look at what the modem wrote, then one try with a fixed build. No calls, messages or data without the author's word.

Done 2026-11-17: tqftpserv 1.1.1 never wrote the modem's short state files; tqftpserv 1.3 from Alpine edge (tqftpserv@edge, provisioned) brought the modem online, Vodafone.de LTE. Research modem-online-tqftpserv.

About
: modem-data

Opened
: 2026-11-11

Needs
: phone


<a id="needs-a-sim"></a>
### A SIM card in the phone

Status
: done

Note
: Inserted by the author on 2026-11-11: the card is seen (1&1, present and ready).

Waits
: the author

About
: modem-data

Opened
: 2026-11-11


<a id="port-lpi-fix-to-branch"></a>
### Port the pin fix to the microphone kernel branch

Status
: done

Note
: 








































































The tested tree came from the phone's v7.1-rc3 source plus upstream's WIP; linux-phone-oco/linux's microphone branch has the audio pin driver laid out differently (no LPI_PINGROUP entries for pins 18-23 in that form). Port the fix deliberately, rebuild from the branch, boot it, and only then add it to pull request #1.

Done 2026-11-17: linux-phone-oco/linux PR 3 (fix/sm7150-lpass-lpi-swr-data-mux), in the kept kernel, queued as upstream-queue linux/sm7150-wcd/0001.

About
: audio-mic

Opened
: 2026-11-11

Needs
: phone


<a id="telephony-checks"></a>
### Telephony in the test suite

Status
: done

Note
: 











































































devlab checks: modem registered; mobile data (download a small file over the mobile connection); a call to the number in ~/.config/devlab/call-to, confirmed through the inbox (half-manual) or by a stand (automatic). First the modem must leave shutting-down.

Done 2026-11-17: surya-lab tests/health/telephony/ has sms-loopback and call-echo (once_a_day); mobile-data is the generic suite's telephony check.

About
: modem-calls

Opened
: 2026-11-11

Needs
: phone


<a id="sensors-and-the-mask"></a>
### Sensors probe: the registry kept current, sensorspd alone unmasked

Status
: done

Note
: Probe done 2026-11-17 (keeper-8, research 2026-11-17-sensorspd-probe-still-writes): with the configs at mtime 1230768000 the DSP still writes temp.json and sns_reg_version through hexagonrpcd (refused) and crashed 7 times in 25 s; the audio card needed a reboot. Not kept: sensorspd masked again, mtimes restored. The proof (proximity-reads) did NOT pass; per this item the way turns to sensors-registry-writes, which now carries the work.

About
: sensors

Opened
: 2026-11-11

Needs
: phone

Proof
: proximity-reads

Rank
: 10


<a id="sensors-registry-writes"></a>
### Fallback: hexagonrpcd serves a writable sensor registry

Status
: done

Note
: proven by a 150 s run with 0 ADSP crashes and monitor-sensor showing accelerometer, light, proximity and compass; research 2026-11-17-sns-reg-version-served. Lasting install not yet (transient run)

About
: sensors

Opened
: 2026-11-09

Needs
: phone

Proof
: motion-and-light

Rank
: 3


<a id="sleep-way-back"></a>
### A way back from a suspend that may not return: the watchdog kept armed through sleep

Status
: done

Note
: Done 2026-11-17 (surya-lab sleep/way-back.sh, build-wdt.sh, patches/qcom-wdt-keep-armed-in-suspend.patch; patched module in updates/ on the phone, acts as stock until 'enable'): idle fuse, probe through a suspend and the hanging cycle all reset the phone by the watchdog and it came back with no hands. Next: sleep-wake-uart with the cause of the hang: see 2026-11-17-way-back-measured.

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone


<a id="sleep-cluster-params"></a>
### surya's own cluster sleep parameters in its device tree

Status
: in-progress

Note
: 2026-11-17 keeper-7: cycle 15 bt-on on the cp.dtb (0x41002244, 0x4100c244) 8 times: a real 15 s s2idle (RTC alarm wake), cluster S2 entered, cxsd/aosd/ddr 0 (research 2026-11-17-cluster-params-clean-yet-no-collapse). The parameters are not the blocker. Untried: the SH0 residual's owner, qcom_aoss prevent_* knobs, XO/VRM votes, USB gadget, display RSC.

Waits
: a deeper decision: WHAT holds CX, AOSS and DDR with an apps side that looks clean (cluster S2 used, CX/MX 0, sleep set zero but SH0 x=1,y=3) is unknown

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps

Rank
: 2


<a id="floor-wlan-off"></a>
### Cycle with WLAN unloaded

Status
: done

Note
: Done 2026-11-17 (keeper-9): ath10k_snoc/core unloaded, cycle 15 bt-on: cxsd/aosd/ddr 0 -> 0. WLAN is not the holder. research/deep-sleep/2026-11-17-floor-wlan-off/README.md

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps


<a id="floor-udc-unbound"></a>
### Cycle with the USB controller unbound

Status
: done

Note
: Done 2026-11-17 (keeper-9): UDC a6f8800.usb unbound, cycle 15 bt-on: cxsd/aosd/ddr 0 -> 0. USB is not the holder. The rebind did not bring the lab link back (needed a hard reboot). research/deep-sleep/2026-11-17-floor-udc-unbound/README.md

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps


<a id="floor-aoss-knobs"></a>
### Write the qcom_aoss prevent_* knobs to off, then cycle

Status
: done

Note
: Done 2026-11-17 (keeper-9): knobs written 0 before cycle 15 bt-on: cx/ddr writes time out, 'ucore did not ack channel': the QMP link to the AOP is dead, so the knobs settle nothing; counters 0 -> 0. research/deep-sleep/2026-11-17-floor-aoss-knobs/README.md

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps


<a id="floor-suspend-late-dump"></a>
### A debug kernel that dumps held votes in late suspend

Status
: open

Note
: Only if the reads above leave the holder open: a debug patch (builder) with a pm notifier / syscore op that prints clk enable counts, regulator use counts and icc votes at dpm_suspend_late, out of tree; the keeper installs it as a kernel try and reads dmesg after the cycle.

Waits
: floor-read-holders and the subtractions above

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps


<a id="floor-research-sh0-aop"></a>
### Research: who holds the SH0 x=1,y=3 sleep vote, and why the AOP does not ack QMP

Status
: done

Note
: Answered 2026-11-17-sh0-and-aop-research; decision 2026-11-17-sh0-owner-by-tag; phone items floor-sh0-owner, floor-sh0-qup-tags, floor-aop-qmp-no-ack.

About
: deep-sleep

Opened
: 2026-11-17

Needs
: research


<a id="floor-research-validity"></a>
### Research: is SH0 x=1,y=3 the blocker at all - counter validity, clocks/GDSC, late-suspend state

Status
: done

Note
: Answered by research 2026-11-17-floor-research-validity and decision 2026-11-17-floor-read-the-entry; phone items floor-entry-trace, floor-irq-quiet; build item suspend-irq-quiet-check.

About
: deep-sleep

Opened
: 2026-11-17

Needs
: research


<a id="floor-entry-trace"></a>
### Read the suspend entry: RSC sleep flush, last-CPU idle state, IRQ delta (no kernel change)

Status
: done

Note
: Decision 2026-11-17-floor-read-the-entry. One cycle: way-back.sh cycle 15 bt-on, watchdog armed (BT-blocked cycles reset). Before and after: /proc/interrupts, every cpuN/cpuidle/stateN usage+time, pm_genpd idle_states of the cluster domain, wakeup_sources, suspend_stats, all qcom_stats nodes. During: tracefs events rpmh (rpmh_send_msg), power:cpu_idle, power:suspend_resume. Record a research row with: (1) is rpmh_send_msg state=sleep written after the last CPU_PM_ENTER, and its addr/data list; (2) the last CPU's idle state; (3) interrupts/s by source over the 15 s. Proven by: soc-sleeps stays the failing test; this item is done when the research row holds those three facts (not known yet until then).

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps

Rank
: 1


<a id="floor-research-aop-view"></a>
### Research: what the AOP sees on the sleep flush; standby current as the arbiter

Status
: done

Note
: Answered by research 2026-11-17-floor-aop-view-and-standby and decision 2026-11-17-standby-current-is-the-arbiter; phone items floor-genpd-rows-and-regulators, floor-usb-runtime-pm, floor-standby-current-cycle

About
: deep-sleep

Opened
: 2026-11-17

Needs
: research


<a id="sensors-without-crash"></a>
### Sensors kept: hexagonrpcd with a served version marker made lasting, three boots without an ADSP crash

Status
: done

Note
: proven by three boots, 0 ADSP crashes, motion-and-light and proximity-reads pass (research 2026-11-17-sensors-lasting-install-three-boots); suspend with the helper left to sensors-across-suspend (1 crash after a 10 s freeze, n=1)

About
: sensors

Opened
: 2026-11-11

Needs
: phone

Proof
: motion-and-light


<a id="standby-r2-reboot-why"></a>
### Why surya rebooted by itself during standby run r2

Status
: done

Note
: proven by research 2026-11-17-r2-reboot-was-the-fuse (pstore console, journal, r2 logs read); r3 waits on decision 2026-11-17-r3-waits-on-the-bluetooth-choice, which the surya coordinator takes

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps

Rank
: 0


<a id="sleep-irq157-quiet"></a>
### Quiet the Bluetooth UART wake irq 157 so Bluetooth-on standby is representative

Status
: done

Note
: proven by 4 bt-on 15 s cycles: no 'nobody cared', hci0 up, soc-sleeps read (cxsd/aosd 0). Cost: ADSP sensor_process crash after every suspend (4 of 4) - needs sensors stopped before suspend; reboot restored health

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps

Rank
: 3


<a id="sensors-proximity-cover-witnessed"></a>
### Witnessed: cover the proximity sensor at the ear, see the reading go near

Status
: open

Note
: Expect: monitor-sensor --proximity prints near: 1 when a hand covers the top bezel and near: 0 when removed; ask the author for go before running it

Waits
: the author: hand over the top of the phone

About
: sensors-proximity-in-calls

Opened
: 2026-11-17

Needs
: phone


<a id="sleep-wakes-for-calls"></a>
### Waking from deep sleep for calls and messages

Status
: open

Note
: On the floor reached above: the modem's IPCRTR glink wakeup enabled (/sys/bus/rpmsg/devices/4080000.remoteproc:glink-edge.IPCRTR.-1.-1/power/wakeup), ModemManager's quick suspend/resume quieting the modem before suspend, and Sxmo's post-wake hook putting the phone back to sleep when the wake was not a call or a message (as postmarketOS does on the OnePlus 6; still reported unreliable there, pmaports 4989). Needs a SIM card - the author's hands. Proven by: a witnessed test wakes-for-call, to be entered in tests (a call to the sleeping phone rings within 5 s; an SMS sent to it arrives), and soc-sleeps passing in the same boot.

Waits
: the SIM back in surya (the author took it out 2026-11-17) and a witness for the call

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: wakes-for-call

Rank
: 6


<a id="devlab-kernel-try-cmdline"></a>
### devlab kernel try NAME --cmdline: a one-shot kernel command line

Status
: open

Note
: lab-tools change (coordinator routing it): one-shot entry NAME-cmd falling back by itself like --dtb; needed for noirqdebug in r4

Waits
: low: r5 no longer needs noirqdebug (irq 157 stays enabled with the serial's wakeup off); wanted only as a convenience: kernel try --cmdline for the RUNNING release without reinstalling modules (devlab install refuses a cmdline-only entry for the running version)

About
: deep-sleep

Opened
: 2026-11-17

Needs
: build

Proof
: devlab kernel try NAME --cmdline noirqdebug boots with it in /proc/cmdline once, then stock/kept


<a id="suspend-irq-quiet-check"></a>
### Suite check suspend-irq-quiet: interrupts across one suspended cycle stay under a threshold (lab-tools)

Status
: done

Note
: A generic check in lab-tools health/suite/checks/ with its row in docs tests (ikb test): reads /proc/interrupts before and after one 15 s s2idle cycle and fails above the threshold, printing the top three sources. Fails today if floor-entry-trace shows a storm; threshold set from that reading, not guessed (not known yet).

2026-11-18: MOVED to lab-tools (docs backlog lab-tools/suspend-irq-quiet-check, rank 5, the lab-tools builder runs it). Not taken here; the keeper puts the built check on the phone when it lands.

About
: deep-sleep

Opened
: 2026-11-17

Proof
: suspend-irq-quiet


<a id="standby-test-in-lpoco-health"></a>
### The standby drain test lives in the health suite (lpoco-health) as a switchable test

Status
: open

Note
: The author (2026-11-17): the standby test belongs in the health suite under the lpoco roof, switchable (lpoco-health on/off), not a one-off script. Move sleep/standby-run.sh's measurement into a lpoco-health test: witness step 'unplug USB', start check that USB power is absent (refuse to score), >=60 min after a 10 min settle, logs per decision 2026-11-17-standby-drain-test. For the lpoco-health owner (lab-tools). Does not block r2.

Waits
: moved to lab-tools in docs (orchestration records it in the lab-tools build queue); not taken here

About
: deep-sleep

Opened
: 2026-11-17

Needs
: build


<a id="bt-suspend-proof"></a>
### Research: make the Bluetooth UART (QCA, serial@88c000, hci0) suspend-proof

Status
: done

Note
: Researched 2026-11-18: decision 2026-11-18-bt-suspend-way; steps queued as bt-trace-cycles, bt-sleep-cts-pulldown, bt-unbind-hook, bt-suspend-gate.

About
: deep-sleep

Opened
: 2026-11-18

Needs
: research


<a id="surya-unreachable-after-suspend"></a>
### surya unreachable after a real systemctl suspend: the author's power cycle, then the cause

Status
: done

Note
: Phone work is PARKED until it answers. When it does: read pstore/ramoops and journalctl -b -1 first (why it did not return: the 30 s fuse was defused for the try; sxmo autosleep still running?). Rules for any further real-suspend try: the watchdog ARMED through the suspend (way-back.sh fuse), sxmo autosleep stopped first, sensorspd restore via a delayed start (sleep hook start is refused while suspend.target is queued - research 2026-11-18-systemctl-suspend-leaves-sensors-stopped). Meanwhile research and build items go on without the phone.

2026-11-18: the author power-cycled it; surya answers again on 7.1.0-sm7150-calls+ (up 07:21Z). The next keeper reads pstore/ramoops and journalctl -b -1 first for the cause.

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Rank
: 0


<a id="lpoco-health-suspend-trace-hook"></a>
### lpoco-health suspend cycle: pre/post hooks or a --trace option (dyndbg, irq trace) so probes need no wrapper

Status
: open

Note
: sleep/bt-trace.sh is the stopgap probe to remove once this exists

About
: deep-sleep

Opened
: 2026-11-18

Needs
: build


<a id="bt-trace-cycles"></a>
### Bluetooth s2idle: 20x15 s and 3x120 s way-back cycles bt-on, wakeup ON, with hci_qca dyndbg and geni irq trace; read storm vs crash order

Status
: done

Note
: 20x15 s done: no crash, storm in 1 of 20 (research 2026-11-18-bt-trace-20x15-no-crash); proof bt-no-irq-storm not passed; 3x120 s impossible under the 30 s fuse - needs a longer-fuse way-back

2026-11-18 coordinator: ACCEPTED as done on research 2026-11-18-bt-trace-20x15-no-crash (20 x 15 s: no controller crash, irq 157 storm in 1 of 20 cycles). The 3 x 120 s cycles are dropped: the 30 s fuse cannot hold a 120 s sleep and a longer fuse is not worth building - long sleeps are covered by loops of 15 s cycles (as the standby run does). The stopgap sleep/bt-trace.sh goes when lpoco-health-suspend-trace-hook lands.

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: bt-no-irq-storm

Rank
: 1


<a id="bt-sleep-cts-pulldown"></a>
### One-shot dtb: CTS pull-down in qup-uart3-sleep like sc7180-trogdor; same cycles as bt-trace-cycles

Status
: open

Note
: 2026-11-18 tried once: dtb booted healthy, then the phone hung in the first 15 s bt-on cycle and did not return (research 2026-11-18-cts-pulldown-dtb-hangs); needs a power hold; then decide: read pstore/journal, or repeat once to tell a one-off from the dtb

2026-11-18 coordinator: NOT repeated now. One try hung the phone beyond the fuse; a repeat costs another power hold and tells little. bt-suspend-gate (no dtb change) is next; come back here only if the gate leaves the storm.

Waits
: a deeper decision: the pull-down dtb left the phone off USB past the 30 s fuse (one try, research 2026-11-18-cts-pulldown-dtb-hangs); not repeated - bt-suspend-gate first

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: bt-no-controller-crash

Rank
: 2


<a id="bt-suspend-gate"></a>
### sxmo autosleep gate: no rtcwake while hci0 is not UP or an rfkill is in D state

Status
: done

Note
: proven by the gate function on the phone: safe with hci0 UP, unsafe with hci0 down, safe again; devlab-usb-awake carries it (lab/devlab-usb-awake, provisioned by the flash overlay), test autosleep-bt-gate

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: bt-rfkill-not-stuck

Rank
: 2


<a id="sxmo-autosleep-off-lasting"></a>
### A lab phone must not idle-suspend: sxmo autosleep off through provisioning, with a health check

Status
: done

Note
: proven by autosleep-off.sh on the phone 2026-11-18 11:21Z: wake lock devlab-usb held, devlab-usb-awake active, suspends steady at 24 over 20 s. Follow-up: audio (sound-card, mic, call-audio-path) fails and adsp crashed 4x after the suspend loop - check on next boot.

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: soc-sleeps

Rank
: 1


<a id="surya-key-chatter-resin"></a>
### Phantom key edges on pm8941_resin/pwrkey: screen goes off during use

Status
: open

About
: deep-sleep

Opened
: 2026-11-18


<a id="devlab-usb-awake-hold-through-resume"></a>
### Provision the phone with the always-held devlab-usb-awake (PR 195): it still runs the 2026-11-10 script

Status
: done

Note
: proven by autosleep-wakelock-held; script on phone = repo main, service restarted, no reboot

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: autosleep-wakelock-held

Rank
: 1


<a id="screen-turns-off-by-itself"></a>
### The screen turns off by itself and back on - is it ours? (the author's question)

Status
: done

Note
: proven by autosleep-wakelock-held + autosleep-service-active pass (suite 2026-11-18); no suspend entry since 11:17:41 (20+ min, wake lock devlab-usb held); cause per research 2026-11-18-screen-blanks-by-itself: sxmo autosleep loop on USB, stopped by the wake lock

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: soc-sleeps

Rank
: 1


<a id="bt-unbind-hook"></a>
### Sleep hook: unbind 88c000.serial:0 from hci_uart_qca before suspend, bind after (never rfkill); same cycles plus BT audio reconnect

Status
: open

Note
: Step 3, only if steps 1-2 leave controller crashes. Hazard: BT-off s2idle hung twice; run with watchdog and ramoops armed.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: bt-hci0-up

Rank
: 3


<a id="sleep-fastrpc-helpers"></a>
### FastRPC helpers stopped across suspend; the sensors back

Status
: open

Note
: 2026-11-18 keeper try 4 (unattended per coordinator GO, fuse armed): phone did not return, no watchdog reset; needs the author's power cycle (attended window), then read /var/tmp/sus-try, pstore, journal. Not retried.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: motion-and-light

Rank
: 4


<a id="health-suspend-cycle-proof"></a>
### Proof of the health suite's suspend cycle on surya (lpoco-health suspend cycle --seconds 15)

Status
: open

Note
: Cites docs backlog health-suspend-cycle (lab-tools lpoco-v0.4.1, PR 125, done): the way-back cycle as a verb of the health suite. On surya: device.toml [health] suspend_guard = the kept-armed watchdog (way-back.sh fuse), suspend_quiet = the serial wakeup file (88c000.serial power/wakeup); then 'lpoco lab suite put now' and 'lpoco-health suspend cycle --seconds 15' (watchdog armed, sxmo autosleep stopped first, sensorspd stopped around it, USB attached, no unplug). Proof: soc-sleeps in that boot's report turns from skip to pass or fail (an honest number, not a skip). Window: the first keeper idle window after lab-machine #47 (lpoco host prepare now, family 0.4.1) is done - orchestration restarts devlab-watch@surya-lab and says so.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: soc-sleeps

Rank
: 4


<a id="sensors-proximity-in-calls"></a>
### Proximity blanks the screen at the ear in a call

Status
: open

Note
: Decided 2026-11-17 (research-sensor-hub, decision 2026-11-17-sensors-registry-kept-current). After sensors-without-crash. The sensor is surya's stk3a5x infrared one (not ultrasonic: nothing in the microphones or earpiece). Read it through iio-sensor-proxy (monitor-sensor --proximity) near and far; find how the shell on the phone (Sxmo) does its in-call proximity lock and make it read iio-sensor-proxy rather than an IIO sysfs file - a sxmo-deviceprofiles or sxmo-utils change for SSC phones; check the panel's calibration (huaxing 2.0, tianma 1.0 in the configs). Proven by proximity-reads after every boot, and once witnessed: in a call (call-echo), the author's hand over the top of the screen blanks it and lifting it brings it back.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

Opened
: 2026-11-17

Needs
: phone

Proof
: proximity-reads

Rank
: 12


<a id="floor-sh0-owner"></a>
### Find who holds the SH0 x=1,y=3 sleep vote and drop it

Status
: open

Note
: Paused 2026-11-17 by decision 2026-11-17-floor-read-the-entry: read the entry first (floor-entry-trace), then decide whether the SH0 owner hunt resumes.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps

Rank
: 15


<a id="bt-pairing"></a>
### Bluetooth pairs and carries audio: from partial to works

Status
: open

Note
: The author, 2026-11-17: bluetooth is partial (controller and powered pass). A works test: pair with a device the lab keeps, carry audio or a file; witnessed where a person must confirm.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

Opened
: 2026-11-17

Needs
: phone

Proof
: bt-pairs

Rank
: 40


<a id="volte-and-emergency"></a>
### VoLTE and emergency calls, to finish calls and messages

Status
: open

Note
: The author, 2026-11-17: confirm first whether today's working calls go over VoLTE (Germany has switched 3G off; read the modem's call and IMS state during the daily echo call). Emergency calls are proven without dialling an emergency number: the modem's emergency number list and its readiness, never a real 112 call.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

Opened
: 2026-11-17

Needs
: phone

Proof
: volte-call

Rank
: 50


<a id="verify-headphone-mic-earpiece"></a>
### Verify headphone, mic and earpiece status directly on hardware instead of relying on the secondhand pmaports note

Status
: open

Note
: The source only confirms mic/earpiece are broken as a group; headphone output specifically was never separately confirmed one way or the other.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

About
: audio-mic

Opened
: 2026-11-04

Needs
: phone

Rank
: 60


<a id="camera-identify-slots"></a>
### Ask each camera slot what it is

Status
: open

Note
: The first step of the cameras: a test device tree that only powers a slot (supplies, clock, reset), booted once as the second entry; then the chip's identity register read over its control bus. Turns reported sensor models into facts.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

About
: camera-rear

Opened
: 2026-11-11

Needs
: phone

Proof
: image-sensor

Rank
: 70


<a id="image-sensors"></a>
### Image sensors: described, then identified, then seen

Status
: open

Note
: Known (research/cameras.md): the pipeline and all three control buses are bound; no sensor is described, which alone is why the cameras are dark. The vendor's kernel gives the wiring of seven sensor slots - bus, lanes, supplies, pins, clock - and names no model. Next: power one slot at a time in a test device tree and ask the chip for its identity; describe fully what this kernel already has a driver for; a frame.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

About
: camera-rear

Opened
: 2026-11-11

Needs
: phone

Proof
: image-sensor

Rank
: 71


<a id="floor-aop-qmp-no-ack"></a>
### Why the AOP does not ack QMP sends (qcom_aoss_qmp c300000)

Status
: open

Note
: Lower rank (research 2026-11-17-sh0-and-aop-research: node equals sm8150/sc7180, serves only the aoss knobs, hypothesis 5). Read only: dump msgram descriptor and mailbox words (magic, version, mcore/ucore states, offset/size) before and after a send; count the AOP irq 389; trace aoss_send/aoss_send_done; whether the AOP changes the length word. Then one change at most. Not known yet: downstream irq-reg-base.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps


<a id="floor-genpd-rows-and-regulators"></a>
### Read all power-domain idle_states rows and regulator_summary users across one way-back cycle 15 bt-on (read-only)

Status
: open

Note
: Settles why the cluster S2idle column is 0 (wrong row/domain or a path that did not count) and lists the rails that stay on in suspend. Write the output into the cycle log. Watchdog armed.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps


<a id="floor-irq-quiet"></a>
### Silence what wakes the CPUs in suspend, one source per cycle

Status
: open

Note
: Only if floor-entry-trace shows interrupts through the cycle (Odin 2 was held by an SD-controller IRQ storm of ~30/s, armada#274). Take the top source from the delta, quiet it by a runtime step (driver unbind with the watchdog armed, or irq mask), one per cycle, judged by way-back.sh cycle 15 bt-on: the interrupt count falls and soc-sleeps is read again. Proven by: suspend-irq-quiet (below 50 interrupts in the suspended 15 s) passing, then soc-sleeps read.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: suspend-irq-quiet


<a id="floor-sh0-qup-tags"></a>
### If SH0 stays: the other TAG_ALWAYS QUP and crypto consumers, one per cycle

Status
: open

Note
: One-shot dtb per change: the serial toward SLAVE_LLCC (sm7150.dtsi ~1259), then the crypto engine (~460), then the rest of the QUP ALWAYS paths; each judged by the sleep-set flush and soc-sleeps. Skip when floor-sh0-owner removes SH0.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps


<a id="floor-standby-current-cycle"></a>
### Standby current: battery-only suspended cycle of 10 minutes, charge_counter delta over time

Status
: open

Note
: Needs the cable out for the window (the witness's hands) or the fuel gauge's discharge read while charging is held off; the RTC wakes the phone and the cycle log is read after. Pass: under 15 mA average; the number is recorded beside Droidian miatoll 9 mA. Same measure as sleep-standby-current.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: standby-current


<a id="floor-usb-runtime-pm"></a>
### Allow USB runtime PM (power/control auto on the HS PHY and the dwc3 controller) for one cycle and read counters and current

Status
: open

Note
: pmaports#4846: lowers draw slightly and keeps USB from holding CX. Needs the lab link to survive: keep the watchdog armed, one change per cycle.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps


<a id="bt-suspend-test-land"></a>
### tests/health/base/bt-suspend.sh in the suite, pushed to the phone with the runner

Status
: open

Note
: Landed with the research; the keeper puts it on the phone with lpoco lab suite put now.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: bt-hci0-up


<a id="surya-adsp-audio-after-suspend-loop"></a>
### adsp crashed 4x and sound-card, mic, call-audio-path fail after the suspend loop

Status
: open

Note
: 2026-11-18 20:29: the same no-sound-card state cured by an ADSP restart through remoteproc0, no reboot (log 2026-11-18-2035-adsp-audio-restart)

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

About
: audio-speaker

Opened
: 2026-11-18

Needs
: phone

Proof
: sound-card


<a id="first-real-boot"></a>
### Boot the current sm7150-mainline kernel on the phone via lab-agent and record dmesg + audio card list

Status
: open

Note
: The first real job: proves the whole lab-agent loop end to end on real hardware, and gives a verified baseline instead of secondhand notes.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

Opened
: 2026-11-04

Needs
: phone


<a id="phosh-usb"></a>
### Under Phosh the PC loses the phone over USB

Status
: open

Note
: After switching to Phosh (2026-11-09) the PC showed no USB device for the phone, so no SSH over USB; the user saw the same before, in an earlier Phosh try. Unclear yet: Phosh changing the USB gadget, or the cable (EarPods were being plugged in that evening). To check: lsusb on the PC and the gadget state on the phone (via wifi or the console) while in Phosh.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

Opened
: 2026-11-09

Needs
: phone


<a id="try-shells"></a>
### Try every mobile shell with working sound

Status
: open

Note
: Switched in place with surya-lab ui/switch.sh (postmarketOS UI packages, tinydm for all; no reflash, the sound fixes stay). Phosh: runs, stereo verified by ear 2026-11-09. Next: Plasma Mobile, GNOME Mobile; Sxmo was the starting shell. Settled 2026-11-11: parked until the shells are cut and sound is complete.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

Opened
: 2026-11-09

Needs
: phone


<a id="shell-free-base"></a>
### A shell-free base for hardware tests

Status
: open

Note
: Proposed by the author after a day of faults that a shell's policy turned into loops: test the base - sound, modem, suspend, storage - on a console-only system, with no desktop or shell deciding when things happen, as the reference; then test each shell as a layer on top, so a failure points at one or the other. The lab's checks already run without a display; the image and the conveyor are to follow. 

2026-11-17: the phone's health suite is layered - base checks first (hardware and system, no shell in the way), then the shell's - and each report line says its layer; on surya the base passes whole (29 of 29 outside the known gaps) under Sxmo. The console-only image is still to come.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

Opened
: 2026-11-10

Needs
: phone


<a id="surya-hand-check"></a>
### Checked by hand

Status
: open

Note
: Buttons verified by a person; vibration still to check (the first half-manual test). Settled 2026-11-11: checked by hand once; next: checked by the conveyor as scenes (agent access).

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

Opened
: 2026-11-10

Needs
: phone


<a id="adsp-handover-loop"></a>
### The audio processor signalling handover every second

Status
: open

Note
: Measured in the test kernel: 'Handover signaled, but it already happened' once a second from 11 s after boot (54 by 65 s), with or without audio. Also seen in a stock boot's crash memory. Likely an interrupt wired to the wrong signal of the audio processor; compare its interrupt mapping with the Android kernel.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

Opened
: 2026-11-11

Needs
: phone


<a id="surya-fastboot-serial"></a>
### surya's fastboot serial in its manifest, read from fastboot

Status
: open

Note
: devlab flash now refuses surya until surya-lab device.toml says [fastboot] serial and writes = true (lab-tools PR 79, decision 2026-11-17-fastboot-by-serial-writes-by-manifest). Next time surya sits in its bootloader, read fastboot devices (likely dc21014b, its soc0 serial 3693150539 in hex - not yet read from fastboot), then add [fastboot] serial and writes = true with the decision that allows flashing surya.

Waits
: surya answering again (parked 2026-11-18 after real-suspend try 4: not back, no watchdog reset; needs the author's power cycle - backlog surya-unreachable-after-try4)

Opened
: 2026-11-17

Needs
: phone


<a id="who-runs-rtcwake-99999999"></a>
### Who runs rtcwake -m mem -s 99999999 on the phone? (it replaced try 4's 15 s alarm)

Status
: done

Note
: proven by research 2026-11-18-who-runs-rtcwake-99999999: sxmo_autosuspend.sh -> sxmo_suspend.sh; devlab-usb lock holds it; tries keep the lock or take sxmo_not_suspendable

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: soc-sleeps

Rank
: 0


<a id="surya-unreachable-after-try4"></a>
### surya did not return from real suspend try 4: the author's power cycle, then read /var/tmp/sus-try, pstore, journalctl -b -1

Status
: done

Note
: Read-back done (research 2026-11-18-try4-read-back): fuse never bit; stray rtcwake -m mem -s 99999999 after the fuse marker; cause not decided by logs. Remaining: trace who ran that rtcwake; the fuse-bite-through-suspend proof (cycle probe) needs an attended window - no real systemctl suspend until then.

2026-11-18: READ (surya-lab PRs 216-217): no boot between 11:45 and the author's hold at 12:16, so the fuse never bit; the last journal lines show rtcwake -m mem -s 99999999 replacing the 15 s alarm; pstore empty. Next: who-runs-rtcwake-99999999, then the attended cycle probe.

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Rank
: 0


<a id="read-probe-drop-1358"></a>
### Read how the 13:58 probe drop ended (read only): reset that failed to boot, or a hang?

Status
: done

Note
: proven by research 2026-11-18-probe-drop-1358-read: a hang after clean resume, pretimeout without reset; read only

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: soc-sleeps

Rank
: 0


<a id="surya-lab-owner-and-watch"></a>
### surya-lab: an **Owner** line in AGENTS.md and [host] watch = true in device.toml

Status
: done

Note
: Owner line in AGENTS.md, [host] watch = true in device.toml; tad check green

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Rank
: 5


<a id="resume-stall-wcd9370-adsp"></a>
### Research: why a resume from s2idle stalls CPU1 (wcd9370 / ADSP resume errors, RCU stalls for minutes, no reset)

Status
: done

Note
: Answered by research 2026-11-18-resume-stall-how-it-stands and decision 2026-11-18-resume-stall-way; steps resume-stall-way-back, resume-stall-repro-attended, resume-stall-stop-clients.

About
: deep-sleep

Opened
: 2026-11-18

Needs
: research

Rank
: 1


<a id="resume-stall-way-back"></a>
### Stalled-resume way back: sysctl panic_on_rcu_stall=1, kernel.panic=5 on the phone

Status
: done

Note
: proven by way-back-panic-on-rcu-stall and way-back-panic-reboots-soon passing on the phone (kernel.panic_on_rcu_stall=1, kernel.panic=5) via /etc/sysctl.d/90-lpoco-way-back.conf, also in device.toml overlay. way-back-ramoops-present still fails: ramoops is not reserved in the dtb (0 iomem lines), so a panic is not kept across the reboot - a dt item

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: way-back-panic-on-rcu-stall

Rank
: 1


<a id="health-cycle-probe-attended"></a>
### Attended: way-back.sh cycle probe with the author present (proves the fuse bites on the real path, nothing suspended for long)

Status
: done

Note
: RUN 2026-11-18 13:57 with the author's go; read after his power hold: previous journal ends 'watchdog0: pretimeout event' 12:58:15, pstore empty - the fuse bit (reset), the phone did not reboot itself (research 2026-11-18-probe-previous-journal-pretimeout-then-silence). Open: why no self-boot after the bite - needs an attended window (fastboot/reset reason). No more unattended tries.

2026-11-18: DONE - it ran (13:57Z) and was read (research 2026-11-18-probe-drop-1358-read, resume-stall-wcd9370-adsp). Superseded by resume-stall-way-back and resume-stall-repro-attended.

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: soc-sleeps

Rank
: 1


<a id="resume-stall-repro-attended"></a>
### Attended repro: way-back.sh cycle 15 probe (no stop-sensors) with the sysctls set; read the panic's stack from pstore

Status
: open

Note
: Attended (the author present, fuse 30 s). Expected: ADSP crash after resume, stall, panic, reboot within ~40 s, pstore dmesg with CPU1's state. Record what CPU1 is stuck on as research; if no reboot comes, the stall hang is a total one: go to surya-kernel-pmic-wdt.

Waits
: resume-stall-way-back (sysctl way back first), then the author present

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: way-back-ramoops-present

Rank
: 2

Witness
: person


<a id="resume-stall-stop-clients"></a>
### Sleep hook: stop sensorspd/FastRPC helpers before, start after, also after a real systemctl suspend; 20 attended cycles, no ADSP crash

Status
: open

Note
: Merges with sleep-fastrpc-helpers (same hook); proof also: no 'fatal error received' and no 'IRQ sync failed to resume' in dmesg across the cycles. Decision 2026-11-18-resume-stall-way layer 2.

Waits
: resume-stall-repro-attended

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: bt-no-controller-crash

Rank
: 3


<a id="sleep-standby-current"></a>
### Standby current measured beside Android's

Status
: open

Note
: r4 SCORED: aborted/partial, unscorable (4 samples, median 120 mA, 63% asleep); aborted by irq 157 + BT SSR at 22:40:48; hang after = sxmo suspend loop on stuck BT SSR, rfkill D-state. Next r5: BT off in cycle, sxmo autosleep stopped, needs unplug. See research 2026-11-18-r4-aborted-partial-and-the-hang.

2026-11-18: r4 aborted/partial (unscorable: 4 clean samples). Bluetooth keeps ending the runs: irq 157 'nobody cached' + QCA controller crash (SSR) in a bt-on cycle; after the stop sxmo's autosleep kept rtcwake -m mem looping, rfkill procs stuck on the misc_open mutex, USB gone. r5 needs: BT off in cycles OR a suspend-proof Bluetooth, sxmo autosleep stopped, sensorspd stopped, the author's unplug.

Waits
: the author present to unplug, and a real way back (resume-stall-way-back, pmic wdt): r5 is not attempted before

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps

Rank
: 1

Witness
: person


<a id="surya-sxmo-suspend-series"></a>
### surya runs sxmo-utils from our fork (sxmo-utils@lab): suspend retries back off, the sensors daemon is stopped and started around each suspend

Status
: in-progress

Note
: 2026-11-18 package part DONE (no suspend): sxmo-utils 1.18.1_p20261118-r0 @lab installed on surya (all 8 sxmo-utils* subpackages; modemmanager, mmsd-tng, vvmd pinned in world first - the new -common no longer pulls them and apk would have purged them; world backup /root/world.before-sxmo-lab). Wake lock devlab-usb held throughout; suite healthy 44 pass 0 fail. Left: the two suspend tests (suspend-retry-backs-off, sensors-after-suspend), attended window only, fuse armed, after ramoops-reserved-dt. Packaging note for lab-tools: sxmo-utils-common should depend on modemmanager (or keep the deps of -r4).

Waits
: attended window with the author

About
: sensors

Opened
: 2026-11-18

Needs
: phone

Proof
: suspend-retry-backs-off,sensors-after-suspend

Rank
: 3

Witness
: person


<a id="ramoops-reserved-dt"></a>
### Reserve ramoops in the device tree so a way-back panic is kept (way-back-ramoops-present)

Status
: done

Note
: Proven by the phone, no dtb try needed: the ramoops node (4 MiB at 0x9d800000) is already in the live device tree and bound (pstore 'Registered ramoops', platform device 9d800000.ramoops). The test wrongly grepped /proc/iomem for 'ramoops'; iomem shows the region as 'reserved'. Test fixed to read the bound platform device; way-back-ramoops-present passes on 7.1.0-sm7150-calls+. NOT exercised: a panic actually kept across a reboot (pstore empty now) - that waits for resume-stall-repro-attended.

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: way-back-ramoops-present

Rank
: 0


<a id="surya-follows-template"></a>
### surya-lab follows the device template's device layer from docs (devicebase.toml pin 0.17.0, tables markers, [why] lines)

Status
: done

Note
: proven by tad check green (13 tables) and follow.sh --source docs v0.17.0 moving the pin 0.16.0 -> 0.17.0; device:begin/end markers added, devicebase.toml now source/version/own/[why]; device layer text identical to docs'

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Rank
: 4


<a id="surya-silent-after-sxmo-apk"></a>
### surya went silent after the sxmo-utils@lab install: asleep again? (read once it answers)

Status
: done

Note
: proven by journal: no suspend, uptime 4:40 unbroken, usb0 carrier lost 15:36 and back 17:47 (cable unplugged, as the author said); ModemManager and sxmo-utils installed; NM manages usb0 only as USB Networking; suite healthy 44 pass 0 fail

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Rank
: 0


<a id="drop-stale-generic-file"></a>
### Drop the stale root file 'generic' (device-template's old 'What a device base takes' header)

Status
: done

Note
: git rm generic; tad check green

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Rank
: 4


<a id="sxmo-config-migration"></a>
### sxmo says 'configs need migration' after the sxmo-utils@lab install: decide per file, record why, clear it

Status
: done

Note
: proven by sxmo_migrate.sh state: all configuration files up to date; see log 2026-11-18-2100-sxmo-config-migration

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Rank
: 5


<a id="pmic-loop-recovery"></a>
### After the PMIC bite: is S2 still enabled and is the reboot loop gone? Stop it, record the way back

Status
: done

Note
: proven by the phone 2026-11-18 19:13Z: after the author's full power-off from eOS recovery (30 s, USB out) surya booted calls+ and stayed up >2 min (loop gone); PMIC regmap 0-00: S2_CTL 0x856=0x01, S2_CTL2 0x857=0x00 (S2 disabled). Way back from a PMIC loop: power off from eOS recovery (pmOS reboots instead), wait 30 s USB out, boot; a power cycle clears S2. Open for upstreams: the series must stop S2 on stop/unbind, or a proof ends with S2 cleared. Next: way-back-pick-watchdog-by-identity.

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: soc-sleeps

Rank
: 0


<a id="surya-pmic-wdt-proof"></a>
### Prove the PMIC watchdog way back on surya: it bites unpetted, and its bark wakes a suspend with nothing else to wake it

Status
: open

Note
: Script https://github.com/linux-phone-oco/docs/blob/main/research/upstream-forks/2026-11-18/tests/pmic-wdt-way-back.sh (devlab phone put): check; first read PON_HLOS 0x854-0x858 and 0x810 through regmap debugfs (writable by HLOS? the bark bit?); bite 20 (dry run, nothing suspended), after the boot check says CARDRESET; then wake, with way-back.sh's APSS fuse armed as the second way back. Settles: HLOS writes the PMIC watchdog, the gen2 bark interrupt index (6 assumed), POFF_REASON1 bit 2, the bark waking through PDC. Proves docs upstream item pmic-wdt-wake-in-suspend; until it passes, keep_armed_in_suspend stays the lab's s2idle-only guard (it does not cover a real suspend: try 4).

2026-11-18: script: docs research/upstream-forks/2026-11-18/tests/pmic-wdt-way-back.sh. Attended if it can drop the only link (the try-4 class: name the dry run that proved the way back on that path first). Result (pass/fail with the run id) goes to the upstreams coordinator via the surya coordinator.

2026-11-18 CAUTION (from the upstreams lane, via the coordinator): on walleye the same PMIC watchdog series BIT, but the bite ended in a POWER-OFF, not a restart, and needed the author's hands (walleye decision 2026-11-18-walleye-pmic-bite-read-then-warm). Suspected: the S2_CTL hard-reset write does not take because the S2 enable is not cleared first. On surya: building, installing and booting the kernel as a one-shot try, and probing the driver read-only (registers? timeout? reset type) is FINE. Do NOT arm the PMIC watchdog to bite until the reset type is proven to RESTART; and then only with the author present and told what to expect (a power-off needing a power press is possible). Read the walleye decision first.

2026-11-18 from the upstreams coordinator (walleye decision 2026-11-18-walleye-no-pmic-bite-until-reset-type; walleye could not read the PON registers and parked): FIRST, read-only, as soon as the kernel with the series is booted once: READ PON S2_CTL (pm6150 PON base + 0x56) and S2_CTL2 (+0x57) - the driver writes 0x07 (hard reset) at probe. 0x07 = surya's bite should restart; 0x04 (shutdown) or anything else = it powers off. How: through the PMIC's regmap (debugfs regmap for the spmi pmic, or the pm6150 PON node's registers: find the base from the device tree / dmesg; no bite, no write). Send the raw values and how you read them to the surya coordinator at once (they go to the upstreams coordinator even if the bite is deferred): that fact decides 'a write that does not take' vs 'a different encoding'. The BITE itself: only with the author present to press power if needed.

LANE RULE (upstreams coordinator, 2026-11-18, after the bite loop): AFTER ANY PMIC BITE the next boot MUST be a kernel carrying pm8916_wdt (it finds S2 running, sets HW_RUNNING, and the core pets it) - never calls+ or another kernel; no driver can clear S2 after a bite itself (PMIC behaviour); otherwise a full power-off (eOS recovery, 30 s USB out) is the only way out. Every bite step boots back into the pmicwdt kernel. Series patch 6/6 (grenudi/linux topic/pmic-wdt-wake-in-suspend 8b2283da3) adds watchdog_stop_on_reboot/stop_on_unregister: an orderly reboot/shutdown/unbind clears S2. The next proof the series needs: pmic-wdt-wakes-in-suspend, ATTENDED, with the APSS fuse picked by identity (way-back-pick-watchdog-by-identity first).

Waits
: surya answering again (silent since ~17:50Z: not on USB, no address - after the sxmo-utils@lab install? the author's hands: cable/power; backlog surya-silent-after-sxmo-apk)

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: pmic-wdt-bites,pmic-wdt-wakes-in-suspend

Rank
: 2

Witness
: person


<a id="pmic-bite-then-pmicwdt-boot-check"></a>
### Bite, then boot the pmicwdt kernel: no loop, dyndbg shows S2 running at probe

Status
: open

Note
: Not urgent (upstreams coordinator): proves the lane rule. Steps: bite (PMIC wdt short timeout, unpetted) with the one-shot pmicwdt+ kernel at 8b2283da3 and dyndbg; then the next boot is the pmicwdt kernel again (NOT calls+): expect NO reboot loop; dmesg shows S2 running at probe (HW_RUNNING set, the core pets it); then an orderly reboot clears S2 (patch 6/6: stop_on_reboot). Result and the dmesg lines go to the upstreams coordinator (cover letter).

Waits
: an attended window (the author present with the eOS-recovery power-off as the way back), way-back-pick-watchdog-by-identity done, kernel rebuilt at 8b2283da3 (patch 6/6)

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: soc-sleeps

Rank
: 9

Witness
: person


<a id="way-back-pick-watchdog-by-identity"></a>
### way-back.sh picks the APSS watchdog by identity, not /dev/watchdog0

Status
: done

Note
: repo + dry run: way-back.sh picks qcom_wdt by parent 17c10000.watchdog (never an identity of PM8916), standby-run.sh defuses through it, health check way-back-apss-watchdog-by-identity; on kernel calls+ fuse 10 armed watchdog0 and defuse stopped it, seen; not yet run on pmicwdt+ (where the numbers swap)

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: soc-sleeps

Rank
: 1


<a id="kept-kernel-with-pmic-wdt"></a>
### The kept kernel carries the PMIC watchdog driver (patch 6/6): then the after-a-bite rule is unnecessary

Status
: open

Note
: The author (2026-11-18): the lane rule 'after any PMIC bite the next boot must carry pm8916_wdt' is a workaround kept in heads and briefs; make it unnecessary. Rebuild the kept kernel (7.1.0-sm7150-calls+ branch) WITH the PMIC watchdog series incl. patch 6/6 (grenudi/linux topic/pmic-wdt-wake-in-suspend 8b2283da3: stop_on_reboot/stop_on_unregister) and &pm6150_wdt enabled in the kept dtb, so every boot - the kept one included - finds S2 running after a bite and feeds or stops it. Steps: build (same recipe as pmicwdt+, one release name, e.g. 7.1.0-sm7150-calls+ rebuilt or 7.1.0-sm7150-calls2+), install, ONE one-shot try (boot-counted, no bite), health; only then promote it as the kept kernel (devlab/lpoco lab kernel keep? read its --help; the old kept one stays as the fallback entry). Proof: no PMIC wdt left unattended without a driver: the test 'kept kernel has pm8916_wdt' passes; then remove the WORKAROUND(kept-kernel-with-pmic-wdt) markers (the items surya-kernel-pmic-wdt, way-back-pick-watchdog-by-identity, way-back.sh). Attended window for the PROMOTION only (a bad kept kernel is the risk): the plain-words ask goes through the coordinator.

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: soc-sleeps

Rank
: 6

Witness
: person


<a id="surya-steps-claimed"></a>
### Claim surya's bring-up steps in its own base (ikb step), proven ones first

Status
: done

Note
: proven by 113 step claims in data/steps.json from suite run 20261118-191339: done 11, partial 2, failing 12, open 6, unknown 82

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Rank
: 0


<a id="surya-steps-map-history"></a>
### Map surya's history to bring-up steps: raise the 82 unknown (claim from older runs, research, log)

Status
: open

Note
: 2026-11-18 20:40 keeper: fresh suite run 20261118-203254 on kept calls+ (72 pass, 5 fail, 6 not measured; the 12 failing were already re-claimed in PR 293: 20 done / 4 partial / 1 failing / 6 open / 82 unknown). MAPPING: of the 82 unknown, 30 name a phone-suite proof and 52 a host-check / witness / build-check / research proof; NONE of those proof tests has a result in any of the 180 stored runs (checked by name), so nothing was claimed - no neighbour's test used. The 30 phone-suite steps (suspend, update, upkeep, gnss, camera, sim...) need a CHECK first (suspend-cycle, bt-suspend, sensors-after-suspend are on the deep-sleep items, parked to the attended window). Next: a builder item for suite checks of steps on goal daily-usable-phone with no check yet (sim-ready, shell-up, standby-current, pon-reason, suspend-cycle); witness steps wait for the author. Also seen: awake-wakelock-held/awake-service-active fail (lpoco-awake inactive, devlab-usb holds the lock: backlog surya-awake-from-package).

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Rank
: 0


<a id="surya-adsp-audio-boot-race"></a>
### A boot can come up with the ADSP lacking its audio services (no sound card): find why, make it self-heal

Status
: open

Note
: 2026-11-18 20:45 keeper: devlab-audio-heal unit written, on the phone, card-present path run (ok); restart path unproven by the script; cause not read. Left open.

About
: audio-speaker

Opened
: 2026-11-18

Needs
: phone

Proof
: sound-card

Rank
: 3


<a id="surya-awake-from-package"></a>
### The wake lock comes from the lpoco-awake package, not a hand-put script

Status
: done

Note
: proven by soc-sleeps precondition + suite 20261118-203654 on kept calls+: lpoco-awake.service enabled and active (awake-wakelock-held, awake-service-active pass), wake lock never dropped through the swap (both locks held, then lpoco-awake alone), devlab-usb-awake disabled and its script/unit removed (lab-pieces pass 'missing'); /etc/devlab-allow-autosleep never existed so nothing to move. Retired the stale autosleep-off check (repo and phone). No suspend, watchdog untouched.

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: soc-sleeps

Rank
: 1


<a id="sxmo-migration-diff"></a>
### Settle which way the 4 migrated sxmo configs differ: package newer or ours newer?

Status
: done

Note
: proven by read-only diff on the phone: plain backups == package defaults == live; .needs-migration are the old ones; research 2026-11-18-sxmo-migration-diff-read. Nothing changed on the phone.

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Rank
: 3


<a id="surya-kernel-pmic-wdt"></a>
### surya's kernel with the PMIC watchdog series (linux-phone-oco/linux topic/pmic-wdt-wake-in-suspend) and &pm6150_wdt enabled, wakeup-source

Status
: open

Note
: 2026-11-18 keeper (again): its last step (the bite) is attended only; not tried unattended; waits for the author at the phone.

Waits
: the attended session (one window, asked through the top coordinator; prerequisites: pmic-kernel-8b2283da3-build, step-checks, boot race)

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: pmic-wdt-bites

Rank
: 0

Witness
: person


<a id="pmic-kernel-8b2283da3-build"></a>
### Build the kept-kernel candidate with the PMIC watchdog series incl. patch 6/6 (8b2283da3): one-shot try, no bite

Status
: done

Note
: proven by one one-shot try of 7.1.0-sm7150-calls2+ (grenudi/linux 8b2283da3 on calls, pm6150_wdt on, huaxing dtb): booted in 72 s; dmesg pm8916-wdt probe ok, 'POFF reason 0x2 0x0', 'S2 reset control was 0x1'; watchdog never opened, no suspend, no bite; try health 2 fail (boot-warnings clk.c:1047 at 0.88 s in deferred_probe; bt-no-controller-crash 1 line), back on kept calls+ healthy 76 pass 0 fail (run 20261118-231104)

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Proof
: soc-sleeps

Rank
: 0


<a id="surya-step-checks"></a>
### Write health-suite checks for surya's daily-usable-phone steps that have no proof test

Status
: open

Note
: FIRST, from orchestration (the steps are live: https://linux-phone-oco.github.io/docs/en/linux-phones/steps.html; surya reads 0 of 23 for the goal 'Linux runs' while it runs mainline with a shell, a gadget and a health suite): claim the 'Linux runs' steps that the suite run ITSELF proves - kernel-builds, kernel-reaches-init, boot-image-packs, gadget-enumerates, shell-on-console, usb-network, rootfs-boots, health-suite-runs and the others of that goal's 23 (tad q bringup-chain in docs) - 'tad r step --step S --status done --proof <the suite check or the boot it rode> --run 20261118-203254 (or a newer run) --proven-on <the running kernel/image/dtb>'. KEEP THE BAR HONEST: claim only what that run shows (a check that passed in it, or a boot it demonstrably rode); anything the run does not show stays unknown/open with a note; no neighbour's proof. Then the cheap new checks below. Land; send the new counts to the surya coordinator (orchestration reruns feeds).

surya-steps-map-history (PR 294): none of the 82 unknown steps has its own proof test with a result in any stored run; 30 of them are phone-suite steps that need NEW checks first. Do: list the unknown steps on goal daily-usable-phone (tad q bringup-chain in docs, and the base's step_status), group by what a check needs (a shell test in tests/health/ - read how an existing one is built: tests/health/base/*.sh, the manifest), write the cheap ones first (read-only checks of a running thing: wifi connected, battery gauge reads, backlight, usb gadget, time sync, modem present, sxmo running...), put the suite, run it once, claim from that run id (done only with test + run). Skip the steps that need a human (witnessed tests) and record them as such (open + notes). One landing per group; no suspend, no risky state; wake lock held.

About
: deep-sleep

Opened
: 2026-11-18

Needs
: phone

Rank
: 1


<a id="calls2-vs-calls-fails"></a>
### Compare calls2+'s two suite fails against calls+ (boot-warnings clk.c:1047, one bt controller-crash line)

Status
: open

Note
: Before kept-kernel-with-pmic-wdt may promote calls2+ (7.1.0-sm7150-calls2+, PMIC wdt series incl. 6/6; surya-lab PR 312): its one-shot try ended with 2 suite fails: boot-warnings (clk.c:1047) and 1 bt controller-crash line - not yet compared with calls+. READ ONLY, no suspend, no bite: for each, is it also in calls+'s boots (the stored boot logs/suite runs of the kept kernel: tests/results, journal of earlier boots) - same warning at the same place and count? A bt controller-crash line in a boot with the pmic wdt kernel: new, or the known irq 157 / QCA SSR family (research 2026-11-18-bt-trace-20x15-no-crash)? Then say: PASS (same as calls+: not caused by the series) or NEW (caused by the series: say how and queue it for the upstreams lane). If you cannot tell from stored runs, boot calls+ one more time and read its boot-warnings (the kept kernel, no try needed: it is the running one) - and the suite once. Record; land; tell the surya coordinator.

About
: deep-sleep

Opened
: 2026-11-19

Needs
: phone

Proof
: soc-sleeps

Rank
: 0


<a id="host-check-stale-pieces"></a>
### lpoco host check reads 4 phone pieces STALE: reinstall or fix what device.toml declares

Status
: open

Note
: From patrol's 00:10 round: 'lpoco host check' reads surya's phone pieces as STALE against suite run 20261118-212534: devlab-audio-heal, devlab-usb-awake, the pd-mapper conf, the way-back sysctl. Some are expected: devlab-usb-awake was REPLACED by the lpoco-awake package (PR 296; its declaration in device.toml should be removed/retired - the check cries wolf for a piece that is gone); devlab-audio-heal is new (PR 299) and its script header changed (WORKAROUND mark, PR on main) so the phone's copy differs; the way-back sysctl may differ from device.toml's overlay (PR 244 + later). For EACH of the 4: diff the phone's installed file against main's source (read-only), say which side is newer; then either reinstall it through the provisioning (lpoco lab provision now / the suite put path - wake lock held, no suspend) or update/remove what surya-lab declares so the check reads clean. Re-run lpoco host check; record which of the 4 were real drift and which declarations were stale (the class: a declaration that outlives its piece). Land.

About
: deep-sleep

Opened
: 2026-11-19

Needs
: phone

Rank
: 1


<a id="surya-audio-cleanup"></a>
### Careful, read-first cleanup of ~/Projects/surya-audio (56 GB; /home is at 94%)

Status
: open

Note
: From orchestration (patrol): /home 94%, about 65 GB free; ~/Projects/surya-audio is 56 GB, the largest tree. ORDER: (1) MEASURE: du by top-level dir and by worktree/obj dir (du -sh, sorted), list git worktrees (git -C ~/Projects/surya-audio/linux worktree list) with status (clean?), branch, merged/pushed?, last use; list the kernel entries installed on the phone/ESP and which obj dir/release each came from (kept calls+, pmicwdt+, calls2+ ...). (2) PLAN in a research row BEFORE deleting: every path, its size, the proof it is unused (what references it: none/entry/keeper), and what regenerates it. (3) REMOVE ONLY what is provably unused: (a) build output dirs (obj-*) of kernel builds no installed entry, try, or kept kernel references, AND not needed to promote calls2+ (keep calls+'s and calls2+'s trees and objs until kept-kernel-with-pmic-wdt is done); (b) worktrees that are CLEAN (git status empty), whose branch is landed or pushed - use 'git worktree remove' (it refuses a dirty one; never rm -rf a worktree, never --force), then 'git worktree prune'; (c) regenerable caches (ccache/pip-less caches) if they exist and the next build only gets slower. NEVER: the kept kernel's and calls2+'s source+obj, the current try, any tree a running keeper uses (wt-surya-keeper-*, a lease held), the .git dirs, the dtb/vmlinuz/modules the entries were installed from (keep the artefacts needed to reinstall the kept kernel), anything with uncommitted work or an unpushed branch. Doubt = keep and list it. (4) Report what was freed (GB per category) and the free space of /home before and after to the surya coordinator; land the research row (the deletion list).

About
: deep-sleep

Opened
: 2026-11-19

Needs
: phone

Rank
: 2
