#!/bin/bash -e

install -m 755 files/os-release	"${ROOTFS_DIR}/usr/lib/"

OS_RELEASE=$(cat "${ROOTFS_DIR}/etc/debian_version")
sed -i 's/os_release/$OS_RELEASE/g' "${ROOTFS_DIR}/usr/lib/os-release"
