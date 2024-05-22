#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

if [ "${CONFIG_DESKTOP}" = y ]; then

chroot "${BUILD_DIR}" << EOF
	# Enable autologin for analog user
	sed -i "s/#autologin-user=/autologin-user=analog/g" /etc/lightdm/lightdm.conf
	sed -i "s/#autologin-user-timeout=0/autologin-user-timeout=0/g" /etc/lightdm/lightdm.conf
	sed -i "s/#logind-check-graphical=false/logind-check-graphical=true/g" /etc/lightdm/lightdm.conf
	
	# Create only one workspace
	sed -i "s/^workspace_count=.*$/workspace_count=1/g" /usr/share/xfwm4/defaults
	
	echo "export CHROMIUM_FLAGS=\"\$CHROMIUM_FLAGS --password-store=basic\"" >> /etc/chromium.d/default-flags
EOF

else
	echo "XFCE desktop environment won't be installed because CONFIG_DESKTOP is set to 'n'."
fi
