#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

chroot "${BUILD_DIR}" << EOF
	cd /usr/local/src

	# Clone linux_image_ADI-scripts
	git clone -b kuiper2.0 ${GITHUB_ANALOG_DEVICES}/linux_image_ADI-scripts.git

	# Install linux_image_ADI-scripts
	cd linux_image_ADI-scripts && make -j $NUM_JOBS
EOF

