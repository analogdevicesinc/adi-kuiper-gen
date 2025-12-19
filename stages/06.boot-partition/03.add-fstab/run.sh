#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

install -v -m 644 "${BASH_SOURCE%/run.sh}"/files/fstab "${BUILD_DIR}/etc/fstab"
install -v -m 644 "${BASH_SOURCE%/run.sh}"/files/README.txt "${BUILD_DIR}/boot/"
