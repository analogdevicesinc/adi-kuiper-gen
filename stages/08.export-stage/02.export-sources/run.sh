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


	######################## ADI git sources ######################## 
	
	for repo in $(ls "${BUILD_DIR}/usr/local/src"); do
		echo ${repo}
		zip -r -6 /kuiper-volume/sources/adi-git/${repo}.zip ${BUILD_DIR}/usr/local/src/${repo}/*
	done

	######################## ADI boot sources ######################## 

	# Check if Xilinx and Intel boot files were downloaded or installed via ADI APT Package Repository
	if [[ "${CONFIG_XILINX_INTEL_BOOT_FILES}" = y && "${USE_ADI_REPO_CARRIERS_BOOT}" = n ]]; then
		# Extract SHAs for Linux and HDL boot files in order to download the sources of the binaries from the same commit they were built.
		LINUX_SHA=$(sed -n 9p "${BUILD_DIR}/boot/$XILINX_INTEL_PROPERTIES" |cut -d"'" -f2)
		HDL_SHA=$(sed -n 5p "${BUILD_DIR}/boot/$XILINX_INTEL_PROPERTIES" |cut -d"'" -f2)
		wget --progress=bar:force:noscroll -O /kuiper-volume/sources/adi-boot/linux_${RELEASE_XILINX_INTEL_BOOT_FILES}.zip \
		https://github.com/analogdevicesinc/linux/archive/${LINUX_SHA}.zip
		wget --progress=bar:force:noscroll -O /kuiper-volume/sources/adi-boot/hdl_${RELEASE_XILINX_INTEL_BOOT_FILES}.zip \
		https://github.com/analogdevicesinc/hdl/archive/${HDL_SHA}.zip
	fi

	# Check if RPI boot files were downloaded or installed via ADI APT Package Repository
	if [[ "${CONFIG_RPI_BOOT_FILES}" = y && "${USE_ADI_REPO_RPI_BOOT}" = n ]]; then
		if [[ ! -z ${ARTIFACTORY_RPI} ]]; then
			RPI_SHA=$(sed -n 2p "${BUILD_DIR}/boot/$RPI_ARTIFACTORY_PROPERTIES" |cut -d'=' -f2)
		else
			RPI_SHA=$(sed -n 6p "${BUILD_DIR}/boot/$RPI_PROPERTIES" |cut -d'=' -f2)
		fi
		wget --progress=bar:force:noscroll -O /kuiper-volume/sources/adi-boot/rpi_"${BRANCH_RPI_BOOT_FILES}".zip \
		https://github.com/analogdevicesinc/linux/archive/${RPI_SHA}.zip
	fi
	

    	######################## Debootstrap package source ########################

	# Download debootstrap sources
	DEBOOTSTRAP_VERSION=$(debootstrap --version | cut -d' ' -f 2)
	wget -vO /kuiper-volume/sources/debootstrap/debootstrap.zip \
	https://salsa.debian.org/installer-team/debootstrap/-/archive/debian/${DEBOOTSTRAP_VERSION}/debootstrap-debian-${DEBOOTSTRAP_VERSION}.zip
	
	
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

else
	echo "Sources won't be exported because EXPORT_SOURCES is set to 'n'."
fi
