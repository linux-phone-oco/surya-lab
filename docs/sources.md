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
