#!/bin/bash -e

if [ -n ${EXTRA_BOOT} ]; then
	wget -r -nH --cut-dirs=5 -np -R "index.html*" "-l${EXTRA_BOOT_DIR_DEPTH}" "${EXTRA_BOOT}" -P "${STAGE_WORK_DIR}/rootfs/boot"
fi
