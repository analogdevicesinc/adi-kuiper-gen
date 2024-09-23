#!/bin/bash

sed -i "/replace_or_add dtoverlay.*/a\replace_or_add hw_session_id $(echo -n $(cat /sys/block/mmcblk0/device/cid) \
    | sha1sum | awk '{print $1}')" $(which iiod_context.sh) && $(which iiod_context.sh)

cat /boot/BOOT.BIN /boot/devicetree.dtb /boot/uImage | sha1sum | awk '{print $1}'> /root/eval/release_boot_hash