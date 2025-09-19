#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

XILINX_INTEL_PROPERTIES="VERSION.txt"
RPI_PROPERTIES="rpi_archives_properties.txt"
RPI_ARTIFACTORY_PROPERTIES="rpi_git_properties.txt"

if [ "${EXPORT_SOURCES}" = y ]; then

	mkdir -p kuiper-volume/sources/debootstrap
	mkdir -p kuiper-volume/sources/deb-src
	mkdir -p kuiper-volume/sources/deb-src-rpi
	mkdir -p kuiper-volume/sources/adi-git
	mkdir -p kuiper-volume/sources/adi-boot
	mkdir -p kuiper-volume/sources/pip-src


	######################## ADI git sources ######################## 
	
	for repo in $(ls "${BUILD_DIR}/usr/local/src"); do
		echo ${repo}
		zip -r -6 /kuiper-volume/sources/adi-git/${repo}.zip ${BUILD_DIR}/usr/local/src/${repo}/*
	done

	######################## ADI boot sources ######################## 

	# Check if Xilinx and Intel boot files were downloaded or installed via ADI APT Package Repository
	if [[ "${CONFIG_XILINX_INTEL_BOOT_FILES}" = y && "${USE_ADI_REPO_CARRIERS_BOOT}" = n ]]; then
		# Extract SHAs for Linux and HDL boot files in order to download the sources of the binaries from the same commit they were built.
		LINUX_SHA=$(sed -n 9p "${BUILD_DIR}/boot/firmware/$XILINX_INTEL_PROPERTIES" |cut -d"'" -f2)
		HDL_SHA=$(sed -n 5p "${BUILD_DIR}/boot/firmware/$XILINX_INTEL_PROPERTIES" |cut -d"'" -f2)
		wget --progress=bar:force:noscroll -O /kuiper-volume/sources/adi-boot/linux_${RELEASE_XILINX_INTEL_BOOT_FILES}.zip \
		https://github.com/analogdevicesinc/linux/archive/${LINUX_SHA}.zip
		wget --progress=bar:force:noscroll -O /kuiper-volume/sources/adi-boot/hdl_${RELEASE_XILINX_INTEL_BOOT_FILES}.zip \
		https://github.com/analogdevicesinc/hdl/archive/${HDL_SHA}.zip
	fi

	# Check if RPI boot files were downloaded or installed via ADI APT Package Repository
	if [[ "${CONFIG_RPI_BOOT_FILES}" = y && "${USE_ADI_REPO_RPI_BOOT}" = n ]]; then
		if [[ ! -z ${ARTIFACTORY_RPI} ]]; then
			RPI_SHA=$(sed -n 2p "${BUILD_DIR}/boot/firmware/$RPI_ARTIFACTORY_PROPERTIES" |cut -d'=' -f2)
		else
			RPI_SHA=$(sed -n 6p "${BUILD_DIR}/boot/firmware/$RPI_PROPERTIES" |cut -d'=' -f2)
		fi
		wget --progress=bar:force:noscroll -O /kuiper-volume/sources/adi-boot/rpi_"${BRANCH_RPI_BOOT_FILES}".zip \
		https://github.com/analogdevicesinc/linux/archive/${RPI_SHA}.zip
	fi
	

    	######################## Debootstrap package source ########################

	sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources
	apt update

	cd kuiper-volume/sources/debootstrap/

	# Download debootstrap sources
	apt-get --download-only source debootstrap
	
	cd /
	
	######################## Debian packages sources ########################
	
	mkdir "${BUILD_DIR}/deb-src"
	mount --bind /kuiper-volume/sources/deb-src "${BUILD_DIR}/deb-src"
	
chroot "${BUILD_DIR}" << EOF
	bash stages/08.export-stage/02.export-sources/01.deb-src-chroot/run-chroot-deb.sh
EOF
	umount "${BUILD_DIR}/deb-src"
	rm -r "${BUILD_DIR}/deb-src"
	
	
	######################## Raspberry Pi OS sources ########################
	
	if [[ "${CONFIG_RPI_BOOT_FILES}" = y ]]; then
		mkdir "${BUILD_DIR}/deb-src-rpi"
		mount --bind /kuiper-volume/sources/deb-src-rpi "${BUILD_DIR}/deb-src-rpi"

chroot "${BUILD_DIR}" << EOF
		bash stages/08.export-stage/02.export-sources/01.deb-src-chroot/run-chroot-rpi.sh "${CONFIG_DESKTOP}"
EOF
		umount "${BUILD_DIR}/deb-src-rpi"
		rm -r "${BUILD_DIR}/deb-src-rpi"
	fi

	######################## Pip packages sources ########################

	mkdir "${BUILD_DIR}/pip-src"
	mount --bind /kuiper-volume/sources/pip-src "${BUILD_DIR}/pip-src"

# --format=freeze: install only one version of the package
# --no-binary :all: : downloads only sources, not precompiled weels
# --no-deps: does not download dependencies
# --no-build-isolation: avoid virtual environments
# || true: ensures that the script continues running even if the pip command is not installed, a package has missing or broken dependencies, or if the required wheels cannot be found
chroot "${BUILD_DIR}" << EOF
	pip list --format=freeze | xargs -I {} /usr/bin/python3 -m pip download {} --no-binary :all: --no-deps --no-build-isolation -d /pip-src/ || true
EOF

	umount "${BUILD_DIR}/pip-src"
	rm -r "${BUILD_DIR}/pip-src"

else
	echo "Sources won't be exported because EXPORT_SOURCES is set to 'n'."
fi
