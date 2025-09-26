#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Monica Constandachi <monica.constandachi@analog.com>
# Author: Larisa Radu <larisa.radu@analog.com>

# Add custom NetworkManager connection profiles
install -m 600 "${BASH_SOURCE%%/run.sh}/files/eth0-linklocal"	"${BUILD_DIR}/etc/NetworkManager/system-connections/"
install -m 600 "${BASH_SOURCE%%/run.sh}/files/eth0-dhcp"	"${BUILD_DIR}/etc/NetworkManager/system-connections/"

chroot "${BUILD_DIR}" << EOF
	# Link files that enable Predictable Network Interface names to null
	ln -sf /dev/null /etc/systemd/network/99-default.link
	ln -sf /dev/null /etc/systemd/network/73-usb-net-by-mac.link
EOF
