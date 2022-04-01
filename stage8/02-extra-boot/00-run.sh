#!/bin/bash -e
if [[ ! -z ${EXTRA_BOOT} ]]; then
	wget -r -q --show-progress -nH --cut-dirs=5 -np -R "index.html*" "-l inf" "${EXTRA_BOOT}" -P "${STAGE_WORK_DIR}/rootfs/boot"
else
	rm -f latest_boot_partition.tar.gz
	wget https://swdownloads.analog.com/cse/boot_partition_files/master/latest_boot_partition.tar.gz
	tar xfv latest_boot_partition.tar.gz -C $STAGE_WORK_DIR/rootfs/boot
	rm -f latest_boot_partition.tar.gz
fi
