#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

HELP="To enable VNC on a board that has a display port, you only need to install the service. This is the default approach in the script. \
	\nTo enable VNC on a board that doesn't have a display port, you need to install the xorg.conf file that contains a dummy display. \
	\nYou can do this by uncommenting line 21. \
	\nOnce you have installed the dummy display, your desktop environment might not start if you switch to a board that has a display port. \
	\nIn order to go back to the initial configuration, you only need to delete /usr/share/X11/xorg.conf.d/xorg.conf file and reboot. \
	\n \
	\nThe VNC password is: analog"

if [ "${CONFIG_DESKTOP}" = y ]; then

# Add x11vnc service
install -m 644 "${BASH_SOURCE%%/run.sh}"/files/x11vnc.service "${BUILD_DIR}/lib/systemd/system/"

# Add xserver service
install -m 644 "${BASH_SOURCE%%/run.sh}"/files/xserver.service "${BUILD_DIR}/lib/systemd/system/"

# Add xserver script
install -m 755 "${BASH_SOURCE%%/run.sh}"/files/adi-xserver.sh	 "${BUILD_DIR}/usr/bin/"

# Add dummy display
#install -m 644 "${BASH_SOURCE%%/run.sh}"/files/xorg.conf	"${BUILD_DIR}/usr/share/X11/xorg.conf.d/"

install -d "${BUILD_DIR}/home/analog/.vnc"

chroot "${BUILD_DIR}" << EOF
	# Add VNC password
	x11vnc -storepasswd analog /home/analog/.vnc/passwd
	chmod 644 /home/analog/.vnc/passwd
	
	# Allow anybody to start the X server
	sed -i "s/allowed_users=console/allowed_users=anybody/g" /etc/X11/Xwrapper.config
	
	# Enable VNC and xserver services to run automatically at every boot
	systemctl enable x11vnc
	systemctl enable xserver
EOF

else
	echo "VNC won't be installed because CONFIG_DESKTOP is set to 'n'."
fi
