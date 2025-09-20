#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Undoes 02.set-locale-and-timezone/90.hack-dpkg-unsafe-io
#
# Copyright (c) 2025 Analog Devices, Inc.
# Author: Ioan Dragomir <ioan.dragomir@analog.com>

if [ "${HACK_DPKG_UNSAFE_IO}" = y ]; then
	rm "${BUILD_DIR}"/etc/dpkg/dpkg.cfg.d/unsafe-io
fi

