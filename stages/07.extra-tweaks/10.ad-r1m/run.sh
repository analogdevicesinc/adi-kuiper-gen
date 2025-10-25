#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# AD-R1M build step
#
# Copyright (c) 2025 Analog Devices, Inc.
# Author: Ioan Dragomir <ioan.dragomir@analog.com>

if [ "${CONFIG_AD_R1M}" = y ]; then
	AD_R1M_ROS2_REPO=https://github.com/adi-innersource/adrd_demo_ros2
	AD_R1M_ROS2_BRANCH=ftc2025

	git clone $AD_R1M_ROS2_REPO -b $AD_R1M_ROS2_BRANCH "${BUILD_DIR}/home/analog/ad_r1m_ros2"

	# Moved all install steps to the ad_r1m_ros2 repo to keep them in sync with relevant higher level software changes
	chroot "${BUILD_DIR}" /bin/bash -x /home/analog/ad_r1m_ros2/platform/rpi5/host_setup/install.sh
else
        echo "AD-R1M specific setup won't be done because CONFIG_AD_R1M is set to 'n'. Are you on the right adi-kuiper-gen branch?"
fi


