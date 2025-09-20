#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# By default, dpkg fsync's between every package, which hurts performance on flash storage twofold, by:
#   1. Taking more time, especially on slower media such as SD cards (e.g. when building from a raspberry pi)
#   2. Wasting flash write cycles and degrading storage devices' lifetime
#
# This hack adds force-unsafe-io to dpkg's flags during the image build to speed up IO.
#
# Initial tests show a ~2x speedup in build steps dominated by package installations.
#
# Refs:
# - https://unix.stackexchange.com/a/7242/166657
# - https://linux.debian.devel.narkive.com/FbvTuwqu/a-2025-newyear-present-make-dpkg-force-unsafe-io-the-default
#
# Copyright (c) 2025 Analog Devices, Inc.
# Author: Ioan Dragomir <ioan.dragomir@analog.com>

if [ "${HACK_DPKG_UNSAFE_IO}" = y ]; then
	# Speed up builds on rpi, where normally dpkg fsync's often and wastes a lot of time. This should be deleted at the end.
	echo force-unsafe-io > "${BUILD_DIR}"/etc/dpkg/dpkg.cfg.d/unsafe-io
fi

