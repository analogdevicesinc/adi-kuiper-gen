#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.

# Stamp the image identity so a Kuiper image is reliably recognizable both
# offline (by Kuiper Imager) and on the running device. One set of facts, sourced
# from the build environment, rendered into three artifacts:
#
#   - boot/kuiper-release.json : machine-readable manifest on the FAT32 BOOT
#     partition. FAT32 is the only filesystem readable on Linux/Windows/macOS
#     without extra drivers, and it is trivial to parse straight out of an .img,
#     so this is the contract Kuiper Imager keys on to recognize the image.
#   - /etc/kuiper-release      : the same facts in os-release (shell) format for
#     on-device tooling (`. /etc/kuiper-release`). We own this file; Debian's
#     base-files never touches it.
#   - /etc/os-release          : the Kuiper keys appended as vendor extensions.

SCHEMA_VERSION=1
KUIPER_GENERATION=2

mkdir -p "${BUILD_DIR}/boot"

# 1) On-device identity file (the source of truth on the image).
cat > "${BUILD_DIR}/etc/kuiper-release" << EOF
KUIPER_NAME="ADI Kuiper Linux"
KUIPER_GENERATION=${KUIPER_GENERATION}
KUIPER_SCHEMA_VERSION=${SCHEMA_VERSION}
KUIPER_VERSION="${KUIPER_VERSION}"
KUIPER_BUILD_DATE="${BUILD_DATE}"
KUIPER_COMMIT="${KUIPER_COMMIT}"
KUIPER_ARCH="${TARGET_ARCHITECTURE}"
KUIPER_VARIANT="${KUIPER_VARIANT}"
KUIPER_DEBIAN_VERSION="${DEBIAN_VERSION}"
KUIPER_DEBIAN_SNAPSHOT="${DEBIAN_SNAPSHOT}"
EOF

# 2) Append the Kuiper keys to /etc/os-release as vendor extensions. On Debian
# /etc/os-release is a symlink to ../usr/lib/os-release (owned by base-files);
# replace it with a real file first so our keys survive a base-files upgrade.
# Trade-off: the Debian fields then become a static snapshot that will not track
# point releases - acceptable, and /etc/kuiper-release stays authoritative.
osr="${BUILD_DIR}/etc/os-release"
if [ -L "${osr}" ]; then
	cp --remove-destination "$(readlink -f "${osr}")" "${osr}"
fi
{
	echo ""
	echo "# --- ADI Kuiper Linux identity (see /etc/kuiper-release) ---"
	cat "${BUILD_DIR}/etc/kuiper-release"
} >> "${osr}"

# 3) Machine-readable manifest on the BOOT partition (Kuiper Imager contract).
# jq renders the JSON with correct escaping; empty values (e.g. an unset Debian
# snapshot) are emitted as "" so every field is always present for the consumer.
jq -n \
	--argjson schema_version "${SCHEMA_VERSION}" \
	--argjson kuiper_generation "${KUIPER_GENERATION}" \
	--arg version "${KUIPER_VERSION}" \
	--arg build_date "${BUILD_DATE}" \
	--arg commit "${KUIPER_COMMIT}" \
	--arg arch "${TARGET_ARCHITECTURE}" \
	--arg variant "${KUIPER_VARIANT}" \
	--arg debian_version "${DEBIAN_VERSION}" \
	--arg debian_snapshot "${DEBIAN_SNAPSHOT}" \
	'{$schema_version, $kuiper_generation, $version, $build_date, $commit, $arch, $variant, $debian_version, $debian_snapshot}' \
	> "${BUILD_DIR}/boot/kuiper-release.json"

echo "Image identity: Kuiper ${KUIPER_GENERATION} ${KUIPER_VERSION} (${TARGET_ARCHITECTURE}/${KUIPER_VARIANT}) built ${BUILD_DATE}"
