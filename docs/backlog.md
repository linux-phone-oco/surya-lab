<!-- Generated from data/ by tad. Do not edit by hand. -->

# Backlog

<a id="first-real-boot"></a>
### Boot the current sm7150-mainline kernel on the phone via lab-agent and record dmesg + audio card list

Status
: open

Note
: The first real job: proves the whole lab-agent loop end to end on real hardware, and gives a verified baseline instead of secondhand notes.

Opened
: 2026-11-04

Needs
: phone


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


<a id="try-shells"></a>
### Try every mobile shell with working sound

Status
: open

Note
: Switched in place with surya-lab ui/switch.sh (postmarketOS UI packages, tinydm for all; no reflash, the sound fixes stay). Phosh: runs, stereo verified by ear 2026-11-09. Next: Plasma Mobile, GNOME Mobile; Sxmo was the starting shell. Settled 2026-11-11: parked until the shells are cut and sound is complete.

Opened
: 2026-11-09

Needs
: phone


<a id="phosh-usb"></a>
### Under Phosh the PC loses the phone over USB

Status
: open

Note
: After switching to Phosh (2026-11-09) the PC showed no USB device for the phone, so no SSH over USB; the user saw the same before, in an earlier Phosh try. Unclear yet: Phosh changing the USB gadget, or the cable (EarPods were being plugged in that evening). To check: lsusb on the PC and the gadget state on the phone (via wifi or the console) while in Phosh.

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

Opened
: 2026-11-11

Needs
: phone


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


<a id="surya-hand-check"></a>
### Checked by hand

Status
: open

Note
: Buttons verified by a person; vibration still to check (the first half-manual test). Settled 2026-11-11: checked by hand once; next: checked by the conveyor as scenes (agent access).

Opened
: 2026-11-10

Needs
: phone


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


<a id="bt-pairing"></a>
### Bluetooth pairs and carries audio: from partial to works

Status
: open

Note
: The author, 2026-11-17: bluetooth is partial (controller and powered pass). A works test: pair with a device the lab keeps, carry audio or a file; witnessed where a person must confirm.

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

Opened
: 2026-11-17

Needs
: phone

Proof
: volte-call

Rank
: 50


<a id="sensors-proximity-in-calls"></a>
### Proximity blanks the screen at the ear in a call

Status
: open

Note
: Decided 2026-11-17 (research-sensor-hub, decision 2026-11-17-sensors-registry-kept-current). After sensors-without-crash. The sensor is surya's stk3a5x infrared one (not ultrasonic: nothing in the microphones or earpiece). Read it through iio-sensor-proxy (monitor-sensor --proximity) near and far; find how the shell on the phone (Sxmo) does its in-call proximity lock and make it read iio-sensor-proxy rather than an IIO sysfs file - a sxmo-deviceprofiles or sxmo-utils change for SSC phones; check the panel's calibration (huaxing 2.0, tianma 1.0 in the configs). Proven by proximity-reads after every boot, and once witnessed: in a call (call-echo), the author's hand over the top of the screen blanks it and lifting it brings it back.

Opened
: 2026-11-17

Needs
: phone

Proof
: proximity-reads

Rank
: 12


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


<a id="surya-fastboot-serial"></a>
### surya's fastboot serial in its manifest, read from fastboot

Status
: open

Note
: devlab flash now refuses surya until surya-lab device.toml says [fastboot] serial and writes = true (lab-tools PR 79, decision 2026-11-17-fastboot-by-serial-writes-by-manifest). Next time surya sits in its bootloader, read fastboot devices (likely dc21014b, its soc0 serial 3693150539 in hex - not yet read from fastboot), then add [fastboot] serial and writes = true with the decision that allows flashing surya.

Opened
: 2026-11-17

Needs
: phone


<a id="verify-headphone-mic-earpiece"></a>
### Verify headphone, mic and earpiece status directly on hardware instead of relying on the secondhand pmaports note

Status
: open

Note
: The source only confirms mic/earpiece are broken as a group; headphone output specifically was never separately confirmed one way or the other.

About
: audio-mic

Opened
: 2026-11-04

Needs
: phone

Rank
: 60


<a id="sleep-wakes-for-calls"></a>
### Waking from deep sleep for calls and messages

Status
: open

Note
: On the floor reached above: the modem's IPCRTR glink wakeup enabled (/sys/bus/rpmsg/devices/4080000.remoteproc:glink-edge.IPCRTR.-1.-1/power/wakeup), ModemManager's quick suspend/resume quieting the modem before suspend, and Sxmo's post-wake hook putting the phone back to sleep when the wake was not a call or a message (as postmarketOS does on the OnePlus 6; still reported unreliable there, pmaports 4989). Needs a SIM card - the author's hands. Proven by: a witnessed test wakes-for-call, to be entered in tests (a call to the sleeping phone rings within 5 s; an SMS sent to it arrives), and soc-sleeps passing in the same boot.

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


<a id="camera-identify-slots"></a>
### Ask each camera slot what it is

Status
: open

Note
: The first step of the cameras: a test device tree that only powers a slot (supplies, clock, reset), booted once as the second entry; then the chip's identity register read over its control bus. Turns reported sensor models into facts.

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


<a id="sleep-fastrpc-helpers"></a>
### FastRPC helpers stopped across suspend; the sensors back

Status
: open

Note
: 2026-11-17 keeper-8: the probe of sensors-and-the-mask (research 2026-11-17-sensorspd-probe-still-writes) shows the DSP still writes the registry with the configs current - crash-loop at start, so there is nothing to measure across a suspend until hexagonrpcd serves writes (sensors-registry-writes). Plan when sensors are up: measure whether they keep streaming after a resume with sensorspd stopped by its Conflicts=suspend.target; restart it after resume (unit WantedBy=suspend.target, After=) only if not; rootpd stays masked; way-back.sh cycle 15 bt-on, one change at a time. Proof: after a measured sleep in one boot, motion-and-light, soc-sleeps and no-processor-crashes pass.

Waits
: sensors-registry-writes: with the helper unmasked the DSP crash-loops at start (probe 2026-11-17), so the sensors cannot be up to measure across a suspend

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


<a id="floor-sh0-owner"></a>
### Find who holds the SH0 x=1,y=3 sleep vote and drop it

Status
: open

Note
: Paused 2026-11-17 by decision 2026-11-17-floor-read-the-entry: read the entry first (floor-entry-trace), then decide whether the SH0 owner hunt resumes.

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


<a id="floor-sh0-qup-tags"></a>
### If SH0 stays: the other TAG_ALWAYS QUP and crypto consumers, one per cycle

Status
: open

Note
: One-shot dtb per change: the serial toward SLAVE_LLCC (sm7150.dtsi ~1259), then the crypto engine (~460), then the rest of the QUP ALWAYS paths; each judged by the sleep-set flush and soc-sleeps. Skip when floor-sh0-owner removes SH0.

Waits
: floor-sh0-owner

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps


<a id="floor-aop-qmp-no-ack"></a>
### Why the AOP does not ack QMP sends (qcom_aoss_qmp c300000)

Status
: open

Note
: Lower rank (research 2026-11-17-sh0-and-aop-research: node equals sm8150/sc7180, serves only the aoss knobs, hypothesis 5). Read only: dump msgram descriptor and mailbox words (magic, version, mcore/ucore states, offset/size) before and after a send; count the AOP irq 389; trace aoss_send/aoss_send_done; whether the AOP changes the length word. Then one change at most. Not known yet: downstream irq-reg-base.

Waits
: floor-sh0-owner

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps


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


<a id="floor-irq-quiet"></a>
### Silence what wakes the CPUs in suspend, one source per cycle

Status
: open

Note
: Only if floor-entry-trace shows interrupts through the cycle (Odin 2 was held by an SD-controller IRQ storm of ~30/s, armada#274). Take the top source from the delta, quiet it by a runtime step (driver unbind with the watchdog armed, or irq mask), one per cycle, judged by way-back.sh cycle 15 bt-on: the interrupt count falls and soc-sleeps is read again. Proven by: suspend-irq-quiet (below 50 interrupts in the suspended 15 s) passing, then soc-sleeps read.

Waits
: floor-entry-trace

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: suspend-irq-quiet


<a id="suspend-irq-quiet-check"></a>
### Suite check suspend-irq-quiet: interrupts across one suspended cycle stay under a threshold (lab-tools)

Status
: open

Note
: A generic check in lab-tools health/suite/checks/ with its row in docs tests (ikb test): reads /proc/interrupts before and after one 15 s s2idle cycle and fails above the threshold, printing the top three sources. Fails today if floor-entry-trace shows a storm; threshold set from that reading, not guessed (not known yet).

About
: deep-sleep

Opened
: 2026-11-17

Needs
: build

Proof
: suspend-irq-quiet


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


<a id="floor-genpd-rows-and-regulators"></a>
### Read all power-domain idle_states rows and regulator_summary users across one way-back cycle 15 bt-on (read-only)

Status
: open

Note
: Settles why the cluster S2idle column is 0 (wrong row/domain or a path that did not count) and lists the rails that stay on in suspend. Write the output into the cycle log. Watchdog armed.

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: soc-sleeps


<a id="floor-usb-runtime-pm"></a>
### Allow USB runtime PM (power/control auto on the HS PHY and the dwc3 controller) for one cycle and read counters and current

Status
: open

Note
: pmaports#4846: lowers draw slightly and keeps USB from holding CX. Needs the lab link to survive: keep the watchdog armed, one change per cycle.

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

About
: deep-sleep

Opened
: 2026-11-17

Needs
: phone

Proof
: standby-current


<a id="sensors-without-crash"></a>
### Sensors kept: hexagonrpcd with a served version marker made lasting, three boots without an ADSP crash

Status
: open

Note
: Re-shaped 2026-11-17 by the fallback's success (research 2026-11-17-sns-reg-version-served): the mtime route alone left the DSP writing (probe), but hexagonrpcd of PR #27 plus the 62-line patch surya-lab/patches/hexagonrpcd-sns-reg-version.patch ran sensorspd 150 s with 0 crashes and gave accelerometer, light, proximity and compass through iio-sensor-proxy. To do: build that daemon as a package or a flash step (static aarch64 by hand so far, meson is not on the lab), a state root made from the package tree (config, registry, sns_reg.conf, dsp, acdb, socinfo; registry also copied to sensors/persist/registry/registry; owner fastrpc), a drop-in for hexagonrpcd-adsp-sensorspd with -R STATE and the unit unmasked in device.toml (rootpd stays masked), the helper across suspend (sensors-across-suspend), 'sensors' out of [health] gaps. One try per boot: a restart loop can leave the sensor PD unusable until reboot. Proven by three boots in a row with motion-and-light and proximity-reads passing, no-processor-crashes passing and the microphone and call checks unchanged. Then upstream (sensors-upstream; the patch to shape for hexagonrpc #19/#29).

About
: sensors

Opened
: 2026-11-11

Needs
: phone

Proof
: motion-and-light


<a id="sleep-standby-current"></a>
### Standby current measured beside Android's

Status
: in-progress

Note
: r2 armed 2026-11-17 20:08Z (unit standby-r2, /var/tmp/standby-r2): waits for the cable to be pulled, then 10 min settle + 60 min measure; then a keeper reads samples.tsv and records the figure

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


<a id="standby-test-in-lpoco-health"></a>
### The standby drain test lives in the health suite (lpoco-health) as a switchable test

Status
: open

Note
: The author (2026-11-17): the standby test belongs in the health suite under the lpoco roof, switchable (lpoco-health on/off), not a one-off script. Move sleep/standby-run.sh's measurement into a lpoco-health test: witness step 'unplug USB', start check that USB power is absent (refuse to score), >=60 min after a 10 min settle, logs per decision 2026-11-17-standby-drain-test. For the lpoco-health owner (lab-tools). Does not block r2.

About
: deep-sleep

Opened
: 2026-11-17

Needs
: build
