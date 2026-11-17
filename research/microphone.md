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

## What the vendor's GPL sources say

- The pin functions of the SoundWire pins agree with mainline's corrected table (gpio19 func3, gpio20
  func2, gpio22/23 func2) - [vendor-sm6150-lpi-dtsi].
- The reset (LPI gpio24) is driven **high** in the vendor's active pin state and low only in its sleep
  state. Our device tree's active state says `output-low`: whenever that state is (re)applied, the
  codec is held in reset. A lead for step 4, not yet tested.
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

Test the reset lead first (active state `output-high`, as the vendor has it), with the bus-level
SoundWire writes and the controllers' status logged at card registration; then capture.
