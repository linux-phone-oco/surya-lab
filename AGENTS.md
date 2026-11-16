# surya-lab - notes for agents

The device lab for the Xiaomi POCO X3 NFC (surya, Huaxing panel): flashing, provisioning, switching
shells, tests. Everything runs on the lab machine (via lab-agent), never in an agent's own sandbox.

- **Talking to the phone**: always through `lib/phone.sh` - `phone_find` (USB 172.16.42.1 first,
  then the Wi-Fi address kept in `~/.config/surya-lab/phone-wifi-address`), `phone_sh` / `phone_root`
  with the commands as a script on standard input (no nested quoting), `phone_put`, `phone_reboot`.
- **Secrets** stay on the lab machine, mode 600, never in this repository: `~/.config/surya-lab/`
  (`wifi-ssid`, `wifi-password`).
- **Images**: the stock Sxmo reference is `~/Projects/surya-audio/image-fresh-stock/...img` and its
  device tree's sha256 starts `a43d069d0a49adcd`. Check a device tree's fingerprint before trusting a
  flash: a "reference" image once carried an old WCD test device tree (no sound card).
- **Flashing** (`flash/flash.sh`) bakes in the sound fixes; no depmod from the PC (it made Plasma
  boot-loop). The first boot of a fresh image is slow (it resizes the storage) - not a hang.
- **After a flash**: `devlab provision now` (packages over the PC's connection, then Wi-Fi), then
  `devlab suite put now --runner ...` (lab-tools' README): from then on the phone checks its own health
  120 s after every boot, by the manifest's `[health]` and its own checks in `tests/health/`.
  `tests/run.sh` and `tests/to-docs.sh` are the older way, from the lab, until gathering replaces them.
- **Hardware testing** on Sxmo: the lightest shell, nothing in the way.
- **A script that changes state needs explicit intent**: an argument it cannot run without
  (flash.sh IMAGE, build-dtbs.sh KERNEL_DIR) or a verb (devlab provision now). Run by accident, it must
  print its usage and change nothing. CI checks every script (syntax, shellcheck errors) on each PR.
- **Test kernels**: `devlab kernel install NAME ...` then `devlab kernel try NAME` (linux-phone-oco/lab-tools,
  reading device.toml) - proven live. One try by boot counting
  (proven on surya: the try is counted down on the ESP, and the next boot is stock by itself); a
  stalled initramfs saves its log to the ESP after 5 minutes and reboots (`log NAME` reads it).
  Never `pmos.debug-shell` on an unattended try: it halts the boot until someone continues it.
