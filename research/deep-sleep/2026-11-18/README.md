# bt-suspend-proof: material

Read 2026-11-18 from mainline (torvalds/linux master): hci_qca.c qca_suspend (200 ms wait for the chip's SLEEP_IND, -ETIMEDOUT refuses the suspend), qcom_geni_serial.c isr (`if (uport->suspended) return IRQ_NONE`), sc7180-trogdor.dtsi &uart3 + qup_uart3_sleep. The live surya node was read from /sys/firmware/devicetree (serial@88c000: interrupts-extended, pinctrl default+sleep, qcom,wcn3998-bt; sleep: CTS bus-hold, RTS pull-down, TX pull-up, RX pull-up). Row: 2026-11-18-bt-suspend-how-it-stands.
