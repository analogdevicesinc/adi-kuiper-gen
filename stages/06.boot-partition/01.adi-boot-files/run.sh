#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

SERVER="https://swdownloads.analog.com"
XILINX_INTEL_SPATH="cse/boot_partition_files"
XILINX_INTEL_ARCHIVE_NAME="latest_boot_partition.tar.gz"
XILINX_INTEL_PROPERTIES="latest_boot.txt"

if [ "${CONFIG_XILINX_INTEL_BOOT_FILES}" = y ]; then
	echo "Download Xilinx and Intel boot files"

	# Check if Xilinx and Intel boot files should be downloaded from ADI repository, Artifactory or Software downloads
	if [ "${USE_ADI_REPO_CARRIERS_BOOT}" == y ]; then
		# extract the carriers release
		carriers_package_release=${RELEASE_XILINX_INTEL_BOOT_FILES/_/.}
		
		# install package from adi-repo
chroot "${BUILD_DIR}" << EOF
		apt-get install adi-carriers-boot-${carriers_package_release}
EOF

	elif [[ ! -z ${ARTIFACTORY_XILINX_INTEL} ]]; then
		wget -r -q --progress=bar:force:noscroll -nH --cut-dirs=5 -np -R "index.html*" "-l inf" ${ARTIFACTORY_XILINX_INTEL} -P "${BUILD_DIR}/boot"
	else
		# Get Xilinx and Intel boot files
		wget --progress=bar:force:noscroll "$SERVER/$XILINX_INTEL_SPATH/$RELEASE_XILINX_INTEL_BOOT_FILES/$XILINX_INTEL_ARCHIVE_NAME"
		if [ $? -ne 0 ]; then
			echo -e "\nDownloading $SERVER/$XILINX_INTEL_SPATH/$RELEASE_XILINX_INTEL_BOOT_FILES/$XILINX_INTEL_ARCHIVE_NAME failed - Aborting."  1>&2
  			exit 1
		fi
		
		# Get Xilinx Intel properties file corresponding to boot files
		wget --progress=bar:force:noscroll "$SERVER/$XILINX_INTEL_SPATH/$RELEASE_XILINX_INTEL_BOOT_FILES/$XILINX_INTEL_PROPERTIES"
		if [ $? -ne 0 ]; then
			echo -e "Downloading $SERVER/$XILINX_INTEL_SPATH/$RELEASE_XILINX_INTEL_BOOT_FILES/$XILINX_INTEL_PROPERTIES failed - Aborting."  1>&2
  			exit 1
		fi
		
		# Compute the checksum for the downloaded archive
		checksum_latest_boot=$(md5sum $XILINX_INTEL_ARCHIVE_NAME | cut -d' ' -f1)
	
		# Extract the checksum of the archive from XILINX_INTEL_PROPERTIES file
		checksum_current_boot=$(sed -n 3p $XILINX_INTEL_PROPERTIES | cut -d' ' -f2)

		# Check if the archive was downloaded correctly and then extract files
		if [ $checksum_latest_boot = $checksum_current_boot ]; then
			tar xf $XILINX_INTEL_ARCHIVE_NAME -C "${BUILD_DIR}"/boot --no-same-owner
		else
			echo "Something went wrong while downloading the boot files - Aborting."
			exit 1
		fi
		
		rm $XILINX_INTEL_ARCHIVE_NAME
		rm $XILINX_INTEL_PROPERTIES
	fi
else
	echo "Xilinx and Intel boot files won't be installed because CONFIG_XILINX_INTEL_BOOT_FILES is set to 'n'."
fi
