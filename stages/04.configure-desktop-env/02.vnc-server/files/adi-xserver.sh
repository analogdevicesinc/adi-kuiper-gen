#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

# Check if the system has a display output
if dmesg | grep -q "\[drm\]"; then
	# Remove dummy display
	rm -f /usr/share/X11/xorg.conf.d/xorg.conf
else
	# Enable dummy display
	enable_dummy_display.sh
	
	# Start an X server as user 'analog'
	su - analog -c "startxfce4 -- :0"
	
	# Export the display port
	export DISPLAY=:0
fi
