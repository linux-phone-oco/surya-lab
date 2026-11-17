# The microphones: why the codec falls off its buses

Measured on the phone on 2026-11-17 by the bring-up session, in one-off test kernels tried through
`devlab kernel try` (7.1.0-rc3-sm7150-wcd: the sm7150-mainline kernel with the WCD9375 described in the
device tree and the LPASS pin-mux fix, plus experiment switches). Records of the earlier work:
`~/Projects/surya-audio/wcd-boots/` on the lab machine.

## The chain

Main microphone -> WCD9375 (ADC1) -> TX SoundWire bus (controller `62ed0000`, v1.5) -> LPASS TX macro
(DEC0) -> the DSP's `TX_CODEC_DMA_TX_3` -> `MultiMedia2`. The codec is one chip with two SoundWire
interfaces: TX (device `sdw:3:0:0217:010a:00:3`, which also carries the codec's register map) and RX
(`sdw:2:...:00:4`, on controller `62ef0000`).

## What was seen, step by step

1. **Capture fails at prepare.** Recording from `MultiMedia2` fails with `-EIO`: the TX controller reads
   nothing back from the codec (`swrm_wait_for_rd_fifo_avail err read underflow`, reading `DPN_PortCtrl`
   of port 1, address `0x102`), preceded by `SWR CMD error` interrupts. The check `mic-records` (in
   `tests/health/base/microphone.sh`) measures this after every boot.
2. **Not the clock-stop path.** The buses suspend about 3 s after binding and resume for the capture. A
   controller that does a full reset and re-enumeration on every resume (switch `resume_reset`) fails the
   same way, right after resuming.
3. **Not suspend at all.** With the controllers refusing runtime suspend (switch `stay_awake`), capture
   still fails. The SoundWire debug log shows why: about 20-80 ms after the codec enumerated and bound,
   **both of its interfaces report UNATTACHED in the same 100 microseconds**, and come back only as a
   device at number 0 that is never enumerated again. From then on every command to the codec goes
   unanswered.
4. **When.** In four boots the drop came 0.4-1.2 ms after the sound card registered (the moment
   `input: POCO X3 Headset Jack` is printed), while its distance from the codec's reset pulse varied
   (55-81 ms). Card registration is the trigger.
5. **Not headset detection.** The machine driver arms the codec's headset detection (MBHC) about 25 ms
   before the drop. With it never armed (switch `no_mbhc`), the drop happens all the same.
6. **Not a register write, a supply or a GPIO.** Tracing every regmap write, every regulator and GPIO
   event and the LPASS clocks across the window: the codec probe's last writes (chip id `0x5`, i.e.
   WCD9375; sleep control, bias, micbias test, interrupt masks) end about 20 ms before the drop, and
   nothing at all is traced in the 17 ms before it. What the trace cannot see: the SoundWire
   controllers' own registers (MMIO, not regmap), bus-level writes to the codec's SoundWire control
   registers (`sdw_write`, not regmap), regmap writes made while a map is cache-only, and messages to
   the DSP.

7. **Found: ASoC holds the codec in reset whenever it is idle.** A function trace (with stacks) of
   `pinctrl_commit_state` showed `snd_soc_bind_card` committing a pin state 0.24 ms before both
   interfaces went UNATTACHED: ASoC puts every inactive component into its **sleep** pin state (at
   card registration and after every stream) and back to default when a stream opens. The codec
   node's sleep state drives the active-low reset (LPI gpio24) **low**. In the boot where the
   default state drove it high, the codec came back at stream open, re-enumerated, and capture
   prepared. Fix: no sleep state on the codec node - the reset belongs to the driver through
   `reset-gpios` (linux-phone-oco/linux PR #4, `dt/surya-wcd9375-reset-no-sleep`). With it the
   codec never drops off (0 UNATTACHED events in a whole boot) and capture prepares without errors.
8. **The pin table, again.** The SoundWire pin fix of 2026-11-11 is now a commit on the real base
   (PR #3, `fix/sm7150-lpass-lpi-swr-data-mux`). That driver counts pins from 0x62b52000, 18 after
   the vendor's count (the first 18 belong to the sensor DSP), so vendor gpio19/23 are its gpio1/5.
   The same shifted-SM8250 origin makes the DMIC pins wrong too (vendor: gpio26-29 are DMIC clock
   and data at **function 1**; the table has them at function 2, and spells one group `gpi26`).
9. **Capture yields exact zeros.** Once the bus held, a recording first rings for ~0.5 s
   (-1774 settling to 0: the decimator's start-up transient) and then is exactly 0 - with a 1 kHz
   tone on the speaker too. A real ADC is never exactly 0, so no microphone data flows yet. The
   check `mic-records` now judges only the last half second (it passed falsely on the transient
   once).
10. **Which microphones.** The vendor's surya board (`sdmmagpie-qrd-overlay.dts`) records the
   built-in microphones as **digital mics** - TX DMIC1-3, powered from WCD mic bias 1 (DMIC1) and 3
   (DMIC2, DMIC3) - and only the headset mic as analog (AMIC2 -> ADC2). The ADC1 route tried first
   was the wrong input.
11. **This ADSP rejects the VA capture port.** Mainline records DMICs on SM8250-class SoCs through the
   VA macro (`VA_CODEC_DMA_TX_0`); on surya the DSP refuses that AFE port (0xb021, error 3), so the
   DMICs must go through the TX macro's decimators into `TX_CODEC_DMA_TX_3`, as the vendor does. The
   DMIC clocks, though, are generated in the VA macro's registers (the vendor's TX macro writes
   them); mainline only starts them from VA widgets. With an experiment switch that runs the VA DMIC
   clocks (divider 2, 2.4 MHz) and DMIC pins at function 1, the TX path still read exact zeros for
   DMIC0-3 - as it did for ADC1. The zeros therefore sit between the TX decimators and the DSP's
   TX DMA (or in the decimator enable), not only at the microphones. That is the next step.

12. **What was pushed was not what ran.** Building the fixes on the real branches showed that the WCD
   device tree on `feat/surya-wcd937x-mic-headphone` (as pushed on 2026-11-05/09) was never the tree
   proven on the phone: its SoundWire controllers sat at 0x62630000/0x62610000 (the hardware, and the
   vendor's `swrm-io-base`, say 0x62ed0000/0x62ef0000), its port tables differed, its macros asked
   for a DCODEC vote that this DSP rejects (`AFE_CMD_REMOTE_LPASS_CORE_HW_VOTE_REQUEST` error 3 -> the
   VA macro fails, the card defers), and the reset was declared active-high and muxed to
   `cdc_pdm_rx`. The tree that ran lived only in `~/Projects/surya-audio/kernel-rc3/src-wcd`. Now
   committed: PR #5 (`dt/sm7150-lpass-soundwire-nodes`: addresses, ports, no DCODEC vote) and PR #4
   (`dt/surya-wcd9375-reset-no-sleep`: polarity, mux, no sleep state), with PR #3 (pin mux).
13. **The branch kernel is healthy.** `test/surya-mic` = the tas2562 fixes + PRs #3, #5, #4, tried on
   2026-11-17 03:52 UTC: healthy (29 pass, the known gaps), the sound card with the WCD9375, the headset
   jack detector present for the first time, stereo speakers as before, 0 UNATTACHED, no SoundWire or
   vote errors. `mic-records` fails honestly (exact zeros) - the next fault.

14. **DMICs on the branch kernel, still zeros.** An experiment commit on `test/surya-mic` (not for
   upstream): DMIC pins at mux 1 in the pin table (gpio8-11 here = vendor gpio26-29), DMIC pin states
   on the VA macro, `qcom,dmic-sample-rate = <2400000>`, TX DMIC0-3 routed to mic bias 1/1/3/3, and the
   VA macro switch that starts the DMIC clocks (divider index 2). Every DMIC through TX DEC0 reads
   exact zeros. With the branch's LPI driver (only the 14 pins after the sensor DSP's block, runtime PM
   on each access) the pin dump could be read during a capture: the DMIC clock pin read as a static
   output-high in every sample, the data pin static too - no clock reached the pin. Freeing the clock
   pin of `output-high` (the vendor does set it) changed nothing. Two readings remain open: the VA
   block's DMIC clock generator does not run with only the TX path active (it may need the VA MCLK
   path the vendor clocks from TX - `bolero_mclk_mux_tbl`), or this pin's DMIC clock is not at mux 1
   on this driver's view of the hardware. A read-only feature-research session was asked for
   (orchestration) on how SM6150/SM7125/SM7150 boards record their microphones on open stacks.
15. **Reading LPI pins safely.** The hang of 02:15 UTC came with the old 32-pin driver, which mapped
   the sensor DSP's pins 0-17 (0x62b40000-0x62b51fff); dumping them faults the bus. The branch driver
   maps from 0x62b52000 and reads were fine during a capture. Never dump LPI pins on a kernel whose LPI
   driver maps the SSC range.

16. **Which reset question each note answered.** Three different questions about the codec's reset
   were asked, and the record reads consistently only when they are kept apart:
   - *The active level* (2026-11-11, before the pin-mux fix, in the draft to sm7150-mainline): driving
     the reset pin high or holding it as a GPIO low gave the same failure - "not the reset pin" meant
     only this; the failure then was the TX bus clash, fixed by the pin mux.
   - *The sleep state* (2026-11-17, step 7): ASoC selects the codec's sleep pin state whenever it is
     idle, and that state drove the reset low - the cause of the drop at card registration.
   - *The polarity and mux on the branch* (2026-11-17, step 12): the pushed device tree declared the
     reset active-high and muxed it to `cdc_pdm_rx`. Fixed together with the sleep state in PR #4.

## What the vendor's GPL sources say

- The pin functions of the SoundWire pins agree with mainline's corrected table (gpio19 func3, gpio20
  func2, gpio22/23 func2) - [vendor-sm6150-lpi-dtsi].
- The reset (LPI gpio24) is driven **high** in the vendor's active pin state and low only in its sleep
  state. Our device tree's active state says `output-low`: whenever that state is (re)applied, the
  codec is held in reset. It was the sleep state that mattered: see step 7.
- Supplies: L10A and BOB always on, L15A (buck) only when a headphone/earpiece path runs; mainline
  turns all four on at probe - [vendor-sm6150-audio-overlay].
- Nothing in the vendor's headset detection touches reset, supplies or SoundWire; its insertion
  debounce is 256 ms - [lineage-sm6150-wcd937x].

## A caution learned the hard way

Reading the LPASS pin controller through debugfs (`/sys/kernel/debug/gpio`, `pinctrl/.../pins`) while
the LPASS clocks are off stalls the bus: the phone hung on 2026-11-17 at about 02:15 UTC and needed a
person's hand. Read LPI pins only with the macros held awake, or not at all.

## Also seen: the audio services missing at boot

On 3 of 8 boots that night (stock and test kernels alike) the audio DSP came up but never announced its
audio services, so no sound card; restarting the DSP (`remoteproc0` stop/start) brought the card back
each time. See the docs backlog item `audio-cold-boot-race`.

## Next

Find why the TX decimators deliver zeros: compare the TX macro register writes during a capture with the vendor tx-macro sequence (decimator enable, HPF, TX path control, codec DMA channel), then the DMIC route (pins at function 1, VA DMIC clocks, mic bias 1/3).
