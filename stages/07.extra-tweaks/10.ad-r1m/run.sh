#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# AD-R1M build step
#
# Copyright (c) 2025 Analog Devices, Inc.
# Author: Ioan Dragomir <ioan.dragomir@analog.com>

if [ "${CONFIG_AD_R1M}" = y ]; then
	cp -r "${BASH_SOURCE%%/run.sh}"/ad_r1m_ros2 "${BUILD_DIR}/home/analog/ad_r1m_ros2"
	chown -R 1000:1000 "${BUILD_DIR}/home/analog/ad_r1m_ros2"

	# Remove cmdline so it is replaced with proper one
	rm "${BUILD_DIR}/boot/firmware/cmdline.txt"

	chroot "${BUILD_DIR}" <<EOF
	cd /home/analog/ad_r1m_ros2/platform/rpi5/host_setup
	bash -x ./install.sh
EOF

else
        echo "AD-R1M specific setup won't be done because CONFIG_AD_R1M is set to 'n'. Are you on the right adi-kuiper-gen branch?"
fi


