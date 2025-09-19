#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# Install Docker in Kuiper Linux image
# https://docs.docker.com/engine/install/debian/
#
# Copyright (c) 2025 Analog Devices, Inc.
# Author: Ioan Dragomir <ioan.dragomir@analog.com>

if [ "${CONFIG_DOCKER}" = y ]; then
	# Add Docker's official GPG key:
	install -m 0755 -d "${BUILD_DIR}/etc/apt/keyrings"
	wget -q https://download.docker.com/linux/debian/gpg -O "${BUILD_DIR}/etc/apt/keyrings/docker.asc"
	chmod a+r "${BUILD_DIR}/etc/apt/keyrings/docker.asc"

	# Add the repository to Apt sources:
	echo \
	  "deb [arch=${TARGET_ARCHITECTURE} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
	  ${DEBIAN_VERSION} stable" > "${BUILD_DIR}/etc/apt/sources.list.d/docker.list"

	# Install the Docker packages:
chroot "${BUILD_DIR}" << EOF
	apt-get update
	apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	usermod -aG docker analog
EOF

else
        echo "Docker won't be installed because CONFIG_DOCKER is set to 'n'."
fi

