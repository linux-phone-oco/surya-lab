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
