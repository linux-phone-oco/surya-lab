#!/bin/sh
# Kept for old notes: flash.sh with a device tree under test.
#   flash-dtb.sh IMAGE UBOOT DTB
exec "$(dirname "$0")/flash.sh" "${1:?usage: flash-dtb.sh IMAGE UBOOT DTB}" "${2:?}" "${3:?}"
