#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2025 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

mkdir -p kuiper-volume/licensing
mkdir -p ${BUILD_DIR}/licensing/copyright
mount --bind kuiper-volume/licensing ${BUILD_DIR}/licensing

chroot "${BUILD_DIR}" << EOF
	bash stages/08.export-stage/03.generate-license/run-chroot.sh
EOF

cp -r stages/08.export-stage/03.generate-license/img/ kuiper-volume/licensing

umount ${BUILD_DIR}/licensing

rm -r "${BUILD_DIR}/stages"
rm -r "${BUILD_DIR}/licensing"
