#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

if [ "${CONFIG_GNURADIO}" = y ]; then

# Install Gnuradio 3.10.5
chroot "${BUILD_DIR}" << EOF
	apt-get install -y gnuradio gnuradio-dev --no-install-recommends
EOF

else
	echo "Gnuradio won't be installed because CONFIG_GNURADIO is set to 'n'."
fi
