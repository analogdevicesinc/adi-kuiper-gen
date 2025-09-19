#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2025 Analog Devices, Inc.
# Author: Ioan Dragomir <ioan.dragomir@analog.com>

if [ "${CONFIG_OPENOCD}" = y ]; then
	# Clone openocd
	git clone --depth 1 --recurse-submodules --shallow-submodules https://github.com/openocd-org/openocd.git "${BUILD_DIR}"/usr/local/src/openocd

	# Add max32662 config
	install -m 644 ${BASH_SOURCE%%/run.sh}/files/max32662.cfg ${BUILD_DIR}/usr/local/src/openocd/tcl/target/

	# Build and install openocd
chroot "${BUILD_DIR}" <<EOF	
	cd /usr/local/src/openocd

        ./bootstrap && ./configure ${CONFIG_OPENOCD_CONFIGURE_ARGS} && make -j $NUM_JOBS && make install
EOF

else
	echo "Openocd won't be installed because CONFIG_OPENOCD is set to 'n'."
fi

