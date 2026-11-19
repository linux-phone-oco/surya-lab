<!-- Generated from data/ by tad. Do not edit by hand. -->

# Sources

<a id="src-linux-hci-qca"></a>
### drivers/bluetooth/hci_qca.c (mainline)

Url
: https://github.com/torvalds/linux/blob/master/drivers/bluetooth/hci_qca.c

By
: Linux Bluetooth maintainers

Takes
: qca_suspend: sets QCA_SUSPENDING, sends IBS SLEEP_IND, waits 200 ms for the chip's own SLEEP_IND, returns -ETIMEDOUT otherwise (suspend then refuses); qca_wakeup follows the serial's power/wakeup


<a id="src-linux-qcom-geni-serial"></a>
### drivers/tty/serial/qcom_geni_serial.c (mainline)

Url
: https://github.com/torvalds/linux/blob/master/drivers/tty/serial/qcom_geni_serial.c

By
: Linux Qualcomm maintainers

Takes
: the isr returns IRQ_NONE while uport->suspended (a level irq asserted then is a 'nobody cared' storm); dedicated wake irq from a second interrupt; runtime/system suspend path


<a id="src-linux-sc7180-trogdor-uart3"></a>
### sc7180-trogdor.dtsi &uart3 and qup_uart3_sleep (mainline)

Url
: https://github.com/torvalds/linux/blob/master/arch/arm64/boot/dts/qcom/sc7180-trogdor.dtsi

By
: Google/Qualcomm (Chromebook DTs)

Takes
: the one mainline QCA UART Bluetooth that sleeps in s2idle by design: interrupts-extended with tlmm 41 EDGE_FALLING, pinctrl sleep (CTS pull-down matching the module, RTS pull-down = chip may wake the system, TX and RX pull-up), wcn3991-bt


<a id="src-steamos-2845-qca-uart-resume"></a>
### SteamOS issue 2845: QCA2066 Bluetooth times out after S4

Url
: https://github.com/valvesoftware/steamos/issues/2845

By
: SteamOS users

Takes
: unbinding only the serdev from hci_uart_qca before sleep and binding after is a working user-space workaround when the controller loses state; IBS wake byte accepted but 0x0c01 times out -110


<a id="src-archwiki-bluetooth-s2idle"></a>
### ArchWiki Bluetooth: Bluetooth immediately waking up suspend-to-idle devices

Url
: https://wiki.archlinux.org/title/Bluetooth

By
: Arch community

Takes
: on s2idle systems the controller stays enabled and its traffic wakes the system; the usual remedy is bluetoothctl power off before sleep and on after


<a id="src-regmap-irq-sync-unlock"></a>
### drivers/base/regmap/regmap-irq.c (regmap_irq_sync_unlock)

Url
: https://github.com/torvalds/linux/blob/63fdb511c27afcebce797e3db580b3534ddfa639/drivers/base/regmap/regmap-irq.c

By
: Linux kernel

Takes
: The message 'IRQ sync failed to resume: N' is pm_runtime_get_sync() on the codec failing inside an irq mask/unmask; -16 is -EBUSY, so the codec's runtime PM could not resume while its parent chain was down


<a id="src-wcd937x-sdw-runtime-pm"></a>
### sound/soc/codecs/wcd937x-sdw.c (runtime resume, regcache sync)

Url
: https://github.com/torvalds/linux/blob/63fdb511c27afcebce797e3db580b3534ddfa639/sound/soc/codecs/wcd937x-sdw.c

By
: Linux kernel

Takes
: Mainline wcd9370 resume is only a regcache sync; no ADSP-restart handling, no system-sleep ops - so a crash of the ADSP under it has no mainline answer


<a id="src-q6v5-pas-adsp-ssr"></a>
### drivers/remoteproc/qcom_q6v5_pas.c (adsp crash handling)

Url
: https://github.com/torvalds/linux/blob/63fdb511c27afcebce797e3db580b3534ddfa639/drivers/remoteproc/qcom_q6v5_pas.c

By
: Linux kernel

Takes
: A fatal error of the ADSP is handled as a recovery (stop, reload, start) while the audio drivers above it stay bound


<a id="uapi-boot-loader-spec-boot-counting"></a>
### UAPI.1 The Boot Loader Specification - Boot counting

Url
: https://uapi-group.org/specifications/specs/boot_loader_specification/

By
: UAPI Group

Takes
: The boot loader decrements 'tries left' each time it boots an entry, before the OS runs; an entry at 0 is 'bad' and sorts after all others; the counter is a file rename on the ESP.


<a id="nura-wiki-initramfs-inspecting"></a>
### Initramfs/Inspecting (postmarketOS wiki, Nura mirror)

Url
: https://wiki.nura.eco/wiki/Initramfs/Inspecting

By
: postmarketOS

Takes
: pmos.debug-shell halts the boot and opens a shell on the USB serial gadget (CONFIG_USB_CONFIGFS_ACM) and telnet 172.16.42.1; that is the only built-in initramfs channel, and it stops the boot.


<a id="kernel-doc-ramoops"></a>
### Ramoops oops/panic logger (kernel documentation)

Url
: https://docs.kernel.org/admin-guide/ramoops.html

By
: Linux kernel

Takes
: Ramoops keeps console/panic records in reserved RAM; they survive a reset that keeps DRAM powered and are read from pstore on the next boot.


<a id="systemd-system-conf-rebootwatchdog"></a>
### systemd-system.conf(5): RuntimeWatchdogSec, RebootWatchdogSec

Url
: https://www.freedesktop.org/software/systemd/man/systemd-system.conf.html

By
: systemd

Takes
: RebootWatchdogSec (default 10 min) arms the hardware watchdog in systemd-shutdown, the second phase of a reboot, so a stuck reboot is reset; no effect without a watchdog device.
