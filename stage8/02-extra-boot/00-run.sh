#!/bin/bash -e

if [ -n ${EXTRA_BOOT} ]; then
	wget -r -nH --cut-dirs=4 -np -R "index.html*" -l2 "${EXTRA_BOOT}" -P "${STAGE_WORK_DIR}/rootfs/boot"
fi
