#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# ischroot=true hack
# Debtools provides ischroot as an utility to check whether running inside a chroot environment.
# Some install steps use this to avoid behaviour that errors inside a chroot (e.g. checking
# filesystem mountpoints). Currently, inside the build-docker.sh environment, ischroot
# returns 2 (= cannot check) instead of 0 (= inside chroot), breaking these steps.
#
# This workaround replaces ischroot with /usr/bin/true, and undoes this change before finalising
# the image.
#
# Copyright (c) 2025 Analog Devices, Inc.
# Author: Ioan Dragomir <ioan.dragomir@analog.com>

if [ "${HACK_ISCHROOT_TRUE}" = y ]; then

	# Replace /usr/bin/ischroot with a link to /usr/bin/true, backing up to ischroot.original to be able to undo this later
	mv ${BUILD_DIR}/usr/bin/ischroot ${BUILD_DIR}/usr/bin/ischroot.original
	ln -s /usr/bin/true ${BUILD_DIR}/usr/bin/ischroot

	# Check the change works
	chroot ${BUILD_DIR} <<<ischroot && echo "chroot hack works: ischroot returns 0" || {
		echo "chroot hack failed: ischroot returned $? inside chroot, instead of 0. This may break later build steps. (e.g. raspi-firmware)"
		exit 1
	}

fi

