#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# AD-R1M build step
#
# Copyright (c) 2025 Analog Devices, Inc.
# Author: Ioan Dragomir <ioan.dragomir@analog.com>

if [ "${CONFIG_AD_R1M}" = y ]; then

	# Add udev rules for UART aliases (slcan, CRSF), GPIO permissions
	install -m 644 "${BASH_SOURCE%%/run.sh}"/files/99-ad-r1m-uarts.rules "${BUILD_DIR}/etc/udev/rules.d/"
	install -m 644 "${BASH_SOURCE%%/run.sh}"/files/60-com.rules          "${BUILD_DIR}/etc/udev/rules.d/"

	# Add chrony config allowing EVAL-ADTF3175D ToF camera module to sync its clock to ours
	install -m 644 "${BASH_SOURCE%%/run.sh}"/files/chrony-allow-aditof.conf "${BUILD_DIR}/etc/chrony/conf.d/"

	# Add ADRD4161 SLCAN firmware image, upload script
	install -m 755 -d                                            "${BUILD_DIR}/opt/adrd4161-fw"
	install -m 755 "${BASH_SOURCE%%/run.sh}"/files/adrd4161-fw/* "${BUILD_DIR}/opt/adrd4161-fw"

	# Add custom kernel, modules, bootfiles
	# Packaged as tar archive with contents of /boot and /lib/modules/...
	tar -xpf "${BASH_SOURCE%%/run.sh}"/files/ad-r1m-kernel.tar.gz -C "${BUILD_DIR}/" --keep-directory-symlink
	install -m 644 "${BASH_SOURCE%%/run.sh}"/files/config.txt        "${BUILD_DIR}/boot/firmware/"
	install -m 644 "${BASH_SOURCE%%/run.sh}"/files/cmdline.txt       "${BUILD_DIR}/boot/firmware/"

	# Change hostname to ad-r1m
	sed -i s/analog/ad-r1m/g "${BUILD_DIR}/etc/hostname"
	sed -i s/analog/ad-r1m/g "${BUILD_DIR}/etc/hosts"

	# Add application management scripts
	ANALOG_UID=$(chroot "${BUILD_DIR}" <<<"id -u analog")
	install -o $ANALOG_UID -m 755 "${BASH_SOURCE%%/run.sh}"/files/user_scripts/* "${BUILD_DIR}/home/analog/"

	# Add systemctl unit to start robot at boot time. Needs to be enabled manually
	install -m 644 "${BASH_SOURCE%%/run.sh}"/files/ros_app.service "${BUILD_DIR}/etc/systemd/system/"

else
        echo "AD-R1M specific setup won't be done because CONFIG_AD_R1M is set to 'n'. Are you on the right adi-kuiper-gen branch?"
fi

