#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

# Find cloned repositories and save info about them to log file
chroot "${BUILD_DIR}" << EOF
	repos=\$(find /usr/local/src -type d -name ".git" -exec dirname {} \;)
	echo -n "ADI repositories in Kuiper ${TARGET_ARCHITECTURE}:\n\n" >> /${ADI_REPOS}
	for r in \${repos}; do
		cd "\${r}"
		echo "Repo   : \$(git remote get-url origin)" >> "/${ADI_REPOS}"
		tag=\$(git describe --tags --exact-match 2>/dev/null) && echo "Tag    : \$tag" >> "/${ADI_REPOS}" || (branch=\$(git rev-parse --abbrev-ref HEAD); echo "Branch : \$branch") >> "/${ADI_REPOS}"
		echo -n "Git_sha: \$(git rev-parse --short HEAD)\n\n" >> "/${ADI_REPOS}"
	done
EOF

# Copy log file to Docker volume
cp "${BUILD_DIR}/${ADI_REPOS}" "/kuiper-volume/${ADI_REPOS}"

