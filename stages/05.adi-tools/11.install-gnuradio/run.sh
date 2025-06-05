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

	# Set the Python path to deb packages when launching GNURadio from both terminal and GUI
	sed -i 's|^Exec=gnuradio-companion|Exec=env PYTHONPATH=/usr/lib/python3/dist-packages:\$PYTHONPATH gnuradio-companion|' /usr/share/applications/gnuradio-grc.desktop
	echo "alias gnuradio-companion='PYTHONPATH=/usr/lib/python3/dist-packages:\$PYTHONPATH gnuradio-companion'" >> /etc/bash.bashrc

EOF

else
	echo "Gnuradio won't be installed because CONFIG_GNURADIO is set to 'n'."
fi
