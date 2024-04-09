#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

repos=$(ls ${BUILD_DIR}/usr/local/src/ | tr '\n' ' ')

chroot "${BUILD_DIR}" << EOF
	echo -n "ADI repositories in Kuiper ${TARGET_ARCHITECTURE}:\n\n" >> /${ADI_REPOS}
	for r in ${repos}; do
		cd "/usr/local/src/\${r}"
	
		if [ \$(git rev-parse --is-inside-work-tree 2>/dev/null) ]; then
			echo "Repo   : \${r}" >> "/${ADI_REPOS}"
   			echo "Branch : \$(git branch | cut -d' ' -f2)" >> "/${ADI_REPOS}"
   			echo -n "Git_sha: \$(git rev-parse --short HEAD)\n\n" >> "/${ADI_REPOS}"
   		fi
	done
EOF

# Copy log file to Docker volume
cp "${BUILD_DIR}/${ADI_REPOS}" "/kuiper-volume/${ADI_REPOS}"

