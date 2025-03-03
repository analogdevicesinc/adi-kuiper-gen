#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

if [ "${CONFIG_LINUX_SCRIPTS}" = y ]; then

chroot "${BUILD_DIR}" << EOF
	cd /usr/local/src

	# Clone linux_image_ADI-scripts
	git clone -b ${BRANCH_LINUX_SCRIPTS} ${GITHUB_ANALOG_DEVICES}/linux_image_ADI-scripts.git

	# Install linux_image_ADI-scripts
	cd linux_image_ADI-scripts && make -j $NUM_JOBS
EOF

else
	echo "linux_image_ADI-scripts won't be installed because CONFIG_LINUX_SCRIPTS is set to 'n'."
fi
