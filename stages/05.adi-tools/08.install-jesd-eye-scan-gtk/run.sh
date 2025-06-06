#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

if [ "${CONFIG_JESD_EYE_SCAN_GTK}" = y ]; then

chroot "${BUILD_DIR}" << EOF
	cd /usr/local/src

	# Clone jesd-eye-scan-gtk
	git clone -b ${BRANCH_JESD_EYE_SCAN_GTK} ${GITHUB_ANALOG_DEVICES}/jesd-eye-scan-gtk.git
		
	# Install jesd-eye-scan-gtk
	cd jesd-eye-scan-gtk && make -j $NUM_JOBS && make install
EOF

else
	echo "JESD Eye Scan GTK won't be installed because CONFIG_JESD_EYE_SCAN_GTK is set to 'n'."
fi
