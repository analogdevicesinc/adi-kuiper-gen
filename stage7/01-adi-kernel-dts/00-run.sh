#!/bin/bash
set -e

rm -rf ${STAGE_WORK_DIR}/rootfs/boot/kernel*.img ${STAGE_WORK_DIR}/rootfs/boot/bcm*.dtb ${STAGE_WORK_DIR}/rootfs/boot/overlays
rm -rf ${STAGE_WORK_DIR}/rootfs/lib/modules/*

if [[ ! -z ${RPI_BOOT} ]]; then
	wget -r -q --show-progress -nH --cut-dirs=5 -np -R "index.html*" "-l inf" "${RPI_BOOT}" -P "${STAGE_WORK_DIR}/rootfs/boot"
	tar -xvf "${STAGE_WORK_DIR}/rootfs/boot/rpi_modules.tar.gz" -C "${STAGE_WORK_DIR}/rootfs/lib/modules" --no-same-owner
	rm -rf "${STAGE_WORK_DIR}/rootfs/boot/rpi_modules.tar.gz"
else
	rm -f rpi_latest_boot.tar.gz
	wget https://swdownloads.analog.com/cse/linux_rpi/rpi-5.10.y/rpi_latest_boot.tar.gz
	tar -xvf rpi_latest_boot.tar.gz -C ${STAGE_WORK_DIR}/rootfs/boot --no-same-owner
	rm -f rpi_latest_boot.tar.gz

	rm -f rpi_modules.tar.gz
	wget https://swdownloads.analog.com/cse/linux_rpi/rpi-5.10.y/rpi_modules.tar.gz
	tar -xvf rpi_modules.tar.gz -C ${STAGE_WORK_DIR}/rootfs/lib/modules --no-same-owner
	rm -f rpi_modules.tar.gz
fi
