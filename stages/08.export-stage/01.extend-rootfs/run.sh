#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

# 2025-09-19 ioan: bodge to speed up builds on rpi, see corresponding step in 01.bootstrap/run.sh  
echo > "${BUILD_DIR}"/etc/dpkg/dpkg.cfg.d/unsafe-io

install -m 755 "${BASH_SOURCE%%/run.sh}"/files/extend-rootfs-once "${BUILD_DIR}/etc/init.d/"

# Enable extend-rootfs-oncer service to run at first boot
chroot "${BUILD_DIR}" << EOF
	systemctl enable extend-rootfs-once
EOF
