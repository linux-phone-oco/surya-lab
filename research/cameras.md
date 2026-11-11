# The cameras: what is known, what is not, and the way in

Measured on the phone and read from sources on 2026-11-11. Nothing here was changed on the phone.

## What the phone shows (mainline kernel 7.1.0-rc3-sm7150)

- The image pipeline (`qcom-camss`, `ace0000.camss`) is bound; it offers 10 video nodes.
- All three camera control buses are bound and enabled: `cci@ac4a000` (two buses) and `cci@ac4b000` (one).
- **No image sensor is described**: the buses have no children and the pipeline's four ports have no
  endpoints. That alone is why every camera is dark.
- The phone's description (`sm7150-xiaomi-surya.dtsi`) already defines two camera supplies -
  `camera_vdig` and `camera_mipi_switch_en` - and enables the buses, and stops there.
- This kernel carries three sensor drivers: `ov13b10`, `ov8856`, `s5k3l6xx` (the last two as modules).
- A sibling on the same chip, `sm7150-xiaomi-davinci.dtsi`, does describe a camera: a model to follow.

## What the vendor's kernel says

Source: `LineageOS/android_kernel_xiaomi_surya`, branch `lineage-22.2`,
`arch/arm64/boot/dts/qcom/sdmmagpie-camera-sensor-idp.dtsi` (the chip's name inside Qualcomm's Android
sources is *sdmmagpie*). Seven sensor slots, all enabled:

| slot | control bus | data lanes (csiphy) | supplies | pins | clock |
|---|---|---|---|---|---|
| 0 | 0 | 0 | vio, vdig | tlmm 14, 25, 66 | 19.2 MHz |
| 1 | 1 | 2 | vio | tlmm 13, 93 | 19.2 MHz |
| 2 | 1 | 1 | vio, vdig | tlmm 13, 23; pm6150 gpio 3 | 19.2 MHz |
| 3 | 0 | 1 | vio | tlmm 16, 24; pm6150 gpio 3 | 19.2 MHz |
| 4 | 0 | 2 | vio (vana, vdig commented out) | tlmm 15, 64, 57 | 19.2 MHz |
| 5 | 1 | 3 | vio, vdig | tlmm 15, 72, 88 | 19.2 MHz |
| 6 | 1 | 2 | vio, vana, vdig | tlmm 15; pm8009 gpio 4 | 24 MHz |

In each row the first pin is the sensor's clock and the others its reset and enable lines, as the
vendor's file orders them.

## What is not known

- **Which sensor model sits in which slot.** The vendor's kernel does not name them: its camera
  software, outside the kernel, does. Models reported for this phone elsewhere are hearsay until a
  chip answers with its own identity.
- Which slots are populated on this phone at all: the file is the chip's reference layout with the
  vendor's changes, and has more slots than the phone has cameras.
- Whether any of the three drivers this kernel carries matches a sensor that is present.

## The way in

1. For one slot at a time, describe only its supplies, clock and reset - no driver - in a test device
   tree, booted as the second entry and tried once, as every experiment on this phone is.
2. With the slot powered, ask the chip on its control bus for its identity register. That turns
   hearsay into a fact, slot by slot.
3. Where an identified sensor has a driver in this kernel, describe it fully, after the sibling
   phone's example, and capture one frame.
4. Where it has none, the work is a driver - recorded as its own step, with the sensor named.
