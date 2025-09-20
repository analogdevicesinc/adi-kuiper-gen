# SPDX-License-Identifier: BSD-3-Clause
#
# ischroot=true hack
# Cleans up after 03.system-tweaks/90.hack-ischroot-true
#
# Copyright (c) 2025 Analog Devices, Inc.
# Author: Ioan Dragomir <ioan.dragomir@analog.com>

if [ "${HACK_ISCHROOT_TRUE}" = "y" ]; then
	mv "${BUILD_DIR}"/usr/bin/ischroot.original "${BUILD_DIR}"/usr/bin/ischroot
fi

