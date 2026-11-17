<!-- Generated from data/ by tad. Do not edit by hand. -->

# Parts

### Row 1

Component
: audio-speaker

Status
: works

Evidence
: 20261117-185149

Notes
: Stereo, both speakers, verified by ear on 2026-11-09 through PipeWire (left-only tone from the top speaker, right-only from the bottom). Needs two fixes not yet upstream: the tas2562 amplifier driver set 32-bit I2S slots on a link clocked for 16-bit, so the right channel fell outside the frame (kernel patch on linux-phone-oco/linux branch fix/tas2562-i2s-slot-length); and the packaged UCM profile is mono with no amplifier channel setup (stereo profile in surya-lab ucm/). Also needs the ADSP sensors service off (adsp-sensor-crash-loop). Both fixes are installed on the test phone, over package files a system update would replace. Measured 2026-11-11 with a microphone placed at the bottom: the right channel is the bottom speaker (7 dB louder there).

Updated
: 2026-11-11

Judged
: works

Measured
: adsp-running pass (present) 20261117-185149, amp-channels pass (present) 20261117-185149, amp-volume-0x4c pass (present) 20261117-185149, amp-volume-0x4d pass (present) 20261117-185149, default-output pass (present) 20261117-185149, sound-card pass (present) 20261117-185149, speaker-stereo pass (present) 20261117-185149

Measured run
: 20261117-185149


### Row 2

Component
: audio-headphone

Status
: unknown

Evidence
: 20261117-185149

Notes
: The headset jack's detector is present. Sound through it needs a person and a pair of headphones: a witnessed test, not done yet.

Updated
: 2026-11-11

Judged
: unknown

Measured
: jack-detector pass (present) 20261117-185149

Measured run
: 20261117-185149


### Row 3

Component
: audio-mic

Status
: works

Evidence
: 20261117-185149

Notes
: Both microphones work on mainline (2026-11-17): the bottom one on WCD9375 ADC1, the top one on ADC2 at INP3, through the TX SoundWire bus and the DSP's TX_CODEC_DMA_TX_3, with the UCM profile's Mic and TopMic. The phone proves it after every boot: a soft 1 kHz beep through its speaker (-6 dBFS at 20%, which the author heard and approved) is found by each microphone through the sound server, 40-60 dB above the noise. Runs on the kept kernel linux-phone-oco/linux test/surya-mic (four WCD9375 fixes, PRs 3-6, queued for sm7150-mainline). The headset microphone is not yet tried.

Updated
: 2026-11-17

Judged
: works

Measured
: mic-hears-speaker pass (works) 20261117-185149, mic-records pass (present) 20261117-185149, mic-top-hears-speaker pass (works) 20261117-185149

Measured run
: 20261117-185149


### Row 4

Component
: audio-earpiece

Status
: works

Evidence
: 20261117-185149

Notes
: The earpiece is the top speaker: the TAS2564 at 0x4d (left of the stereo pair), not the WCD9375's EAR amplifier, which is silent (the author listened, 2026-11-17). The UCM profile's Earpiece device plays through it alone at -18 dB, both channels mixed. The phone proves it after every boot: earpiece-heard - a soft tone through the Earpiece found by the top microphone, 50 dB above the noise.

Updated
: 2026-11-17

Judged
: works

Measured
: earpiece-heard pass (works) 20261117-185149

Measured run
: 20261117-185149


### Row 5

Component
: camera-front

Status
: broken

Evidence
: 20261117-185149

Notes
: The camera pipeline and its three control buses work; the phone's description lists no image sensor, which alone is why the cameras are dark. The vendor's kernel gives the wiring of seven sensor slots and names no model. Next: power a slot and ask the chip what it is (surya-lab, research/cameras.md).

Updated
: 2026-11-11

Judged
: broken

Measured
: image-sensor fail (present) 20261117-185149

Measured run
: 20261117-185149


### Row 6

Component
: camera-rear

Status
: broken

Evidence
: 20261117-185149

Notes
: The camera pipeline and its three control buses work; the phone's description lists no image sensor, which alone is why the cameras are dark. The vendor's kernel gives the wiring of seven sensor slots and names no model. Next: power a slot and ask the chip what it is (surya-lab, research/cameras.md).

Updated
: 2026-11-11

Judged
: broken

Measured
: image-sensor fail (present) 20261117-185149

Measured run
: 20261117-185149


### Row 7

Component
: display-panel

Status
: works

Evidence
: 20261117-185149

Notes
: Video-mode panel fixes and panel regulator/variant support landed (6.7.4, 6.13.2).

Updated
: 2026-11-04

Judged
: works

Measured
: backlight pass (present) 20261117-185149, panel-connected pass (present) 20261117-185149

Measured run
: 20261117-185149


### Row 8

Component
: touchscreen

Status
: works

Evidence
: 20261117-185149

Notes
: nt36xxx touchscreen driver rewrite for xiaomi-surya landed (6.7.4).

Updated
: 2026-11-04

Judged
: works

Measured
: touch-device pass (present) 20261117-185149

Measured run
: 20261117-185149


### Row 9

Component
: haptics

Status
: works

Evidence
: 20261117-185149

Notes
: awinic,aw8624 haptics driver added (6.2.0).

Updated
: 2026-11-04

Judged
: works

Measured
: vibrator pass (present) 20261117-185149

Measured run
: 20261117-185149


### Row 10

Component
: modem-data

Status
: works

Evidence
: 20261117-185149

Notes
: Mobile data works on mainline with a SIM (2026-11-17, Vodafone.de, LTE): tqftpserv >= 1.2 (from Alpine edge until v3.24 carries it) lets the modem finish starting, and a NetworkManager gsm connection with no APN uses the network's default. The phone proves it after every boot: mobile-data - three pings and a 100 kB download over the modem's interface. surya-lab provisions both (packages tqftpserv@edge, lab/mobile.nmconnection).

Updated
: 2026-11-17

Judged
: works

Measured
: mobile-data pass (works) 20261117-124832, modem-registered pass (works) 20261117-124915, modem-running pass (present) 20261117-185149, modem-seen pass (present) 20261117-185149

Measured run
: 20261117-185149


### Row 11

Component
: modem-calls

Status
: works

Evidence
: 20261117-185149

Notes
: Calls work both ways on mainline (2026-11-17, Vodafone.de network, 1&1 SIM): q6voice (from pulpoff/linux-surya, sdm845-mainline's drivers) in the kept kernel, a Voice Call UCM verb with earpiece and speaker, q6voiced and an uplink capture service. The phone proves it once a day: call-echo calls an echo line, plays a tone and hears it come back. The author heard the echo line's announcement on the earpiece.

Updated
: 2026-11-17

Judged
: works

Measured
: call-audio-path pass (present) 20261117-185149, call-echo pass (works) 20261117-094741

Measured run
: 20261117-185149


### Row 12

Component
: modem-sms

Status
: works

Evidence
: 20261117-094741

Notes
: SMS works both ways on mainline (2026-11-17, Vodafone.de network): the phone texts its own number and receives it in seconds; the author saw it arrive. Proven once a day by sms-loopback (surya-lab tests/health/base).

Updated
: 2026-11-17

Judged
: works

Measured
: sms-loopback pass (works) 20261117-094741

Measured run
: 20261117-094741


### Row 13

Component
: wifi

Status
: works

Evidence
: 20261117-185149

Notes
: Joins a network, holds an address, and its gateway answers - checked after every start. Speed and the 5 GHz band are not measured.

Updated
: 2026-11-11

Judged
: works

Measured
: wifi-connected pass (works) 20261117-185149, wifi-interface pass (present) 20261117-185149, wifi-reaches-gateway pass (works) 20261117-185149

Measured run
: 20261117-185149


### Row 14

Component
: bluetooth

Status
: partial

Evidence
: 20261117-185149

Notes
: The adapter is powered and hears nearby devices (five on 2026-11-11) - checked after every start. Pairing, and sound over Bluetooth, have not been tried.

Updated
: 2026-11-11

Judged
: partial

Measured
: bt-controller pass (present) 20261117-185149, bt-powered pass (present) 20261117-185149

Measured run
: 20261117-185149


### Row 15

Component
: nfc

Status
: unknown

Evidence
: 20261117-185149

Notes
: The controller is seen by the kernel. No tool on the phone reads a tag yet.

Updated
: 2026-11-11

Judged
: unknown

Measured
: nfc-device pass (present) 20261117-185149

Measured run
: 20261117-185149


### Row 16

Component
: fingerprint

Status
: broken

Evidence
: 20261117-185149

Notes
: No fingerprint reader is exposed by the kernel.

Updated
: 2026-11-11

Judged
: broken

Measured
: reader-exposed fail (present) 20261117-185149

Measured run
: 20261117-185149


### Row 17

Component
: sensors

Status
: broken

Evidence
: 20261117-185149

Notes
: No motion, light or proximity sensor is exposed to the system. The sensor hub's service is masked on purpose: with it running, the audio processor crashed at every suspend.

Updated
: 2026-11-11

Judged
: broken

Measured
: motion-and-light fail (present) 20261117-185149, proximity-reads fail (present) 20261117-185149

Measured run
: 20261117-185149


### Row 18

Component
: usb-otg

Status
: works

Evidence
: 20261117-185149

Notes
: OTG support added (6.13.2).

Updated
: 2026-11-04

Judged
: works

Measured
: usb-awake pass (works) 20261117-185149, usb-role pass (present) 20261117-185149

Measured run
: 20261117-185149


### Row 19

Component
: fastboot

Status
: works

Notes
: Required for Nura to be installable at all, and for lab-agent's own boot-and-test loop.

Updated
: 2026-11-04

Judged
: works


### Row 20

Component
: deep-sleep

Status
: broken

Evidence
: 20261117-185149

Notes
: Not measured yet: on USB the lab keeps the phone awake, and it has not suspended in a measured boot. Read 2026-11-17 without a suspend: the SoC's sleep counters work (CX collapse 0, AOSS sleep 0), the audio DSP never slept, and the device tree asks for SC7180's cluster parameters, not surya's. The path: decision 2026-11-17-deep-sleep-measured-s2idle; the steps are the sleep-* backlog items.

Updated
: 2026-11-17

Judged
: unknown

Measured
: soc-sleeps fail (works) 20261117-185149

Measured run
: 20261117-185149
