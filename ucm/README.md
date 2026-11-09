# UCM profile for surya

`Xiaomi/surya/HiFi.conf` makes the speaker stereo: two amplifiers share one I2S line, the TAS2564 at
0x4d (top, labelled Left in the device tree) takes the left channel, the TAS2562 at 0x4c (bottom,
Right) the right one, and the speaker device has two channels.

It needs the kernel fix on `linux-phone-oco/linux` branch `fix/tas2562-i2s-slot-length`: without
it the amplifiers expect 32-bit slots on a link that sends 16-bit ones, and the right channel is
silent. The packaged profile is mono, so only the bottom speaker plays.

Install: copy over `/usr/share/alsa/ucm2/Xiaomi/surya/HiFi.conf` (keep the original), then reboot or
restart PipeWire and WirePlumber. Verified 2026-11-09: a left-only tone from the top speaker, a
right-only tone from the bottom one, through PipeWire. Meant for upstream alsa-ucm-conf.
