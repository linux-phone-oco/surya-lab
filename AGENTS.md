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
- **After a flash**: `provision/provision.sh` (packages over the PC's connection, then Wi-Fi), then
  `tests/run.sh` and `tests/to-docs.sh` to file the results into linux-phone-oco/docs.
- **Hardware testing** on Sxmo: the lightest shell, nothing in the way.
