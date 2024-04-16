#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

install -m 755 "${BASH_SOURCE%%/run.sh}"/files/extend-rootfs-once "${BUILD_DIR}/etc/init.d/"

# Enable extend-rootfs-oncer service to run at first boot
chroot "${BUILD_DIR}" << EOF
	systemctl enable extend-rootfs-once
EOF
