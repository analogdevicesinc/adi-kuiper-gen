#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

BOOTLOADER_DEV=$1

if [ "${CONFIG_XILINX_INTEL_BOOT_FILES}" = y ]; then
	if [[ ! -z "${ADI_EVAL_BOARD}"  && ! -z "${CARRIER}" ]]; then
	
		# Extract project description from kuiper.json by selecting the project set in the configuration file
		PROJECT_DESCRIPTION=$(cat ${BUILD_DIR}/boot/kuiper.json \
					| jq '."projects"'              \
					| jq '.[] | select(.name=="'${ADI_EVAL_BOARD}'" and .board=="'${CARRIER}'")')
		
		# Check if project exists
		if [[ -z "${PROJECT_DESCRIPTION}" ]]; then
			echo "Cannot find project ${ADI_EVAL_BOARD} for board ${CARRIER}. Setup not configured."
		else
			# Extract kernel path from the project description
			kernel=$(echo "$PROJECT_DESCRIPTION" | jq -r '.kernel')
			
			# Copy kernel to Kuiper boot directory
			cp -v ${BUILD_DIR}${kernel} ${BUILD_DIR}/boot
			if [ $? -ne 0 ]; then
				echo "Something went wrong while copying the kernel. Boot patition can't be configured."
				exit
			fi
			
			# Extract paths with boot files from the project description
			paths=$(echo "$PROJECT_DESCRIPTION" | jq -r '.files' | jq '.[]' | jq -r '.path')
			
			# Add the correct prefix for all paths and copy them to Kuiper boot directory
			paths=${paths//\/boot/${BUILD_DIR}\/boot}
			cp -v $paths ${BUILD_DIR}/boot
			if [ $? -ne 0 ]; then
				echo "Something went wrong while copying boot files. Boot patition can't be configured."
				exit
			fi
			
			# Check if project platform is Intel
			if [[ ! -z $(echo "$PROJECT_DESCRIPTION" | jq 'select(.platform == "intel")') ]]; then
			
				# Move copied extlinux.conf to extlinux folder
				mv -v ${BUILD_DIR}/boot/extlinux.conf ${BUILD_DIR}/boot/extlinux/
				
				# Extract preloader file from the project description
				preloader=$(echo "$PROJECT_DESCRIPTION" | jq -r '.preloader')
				
				# Write preloader file to corresponding image partition
				dd if=${BUILD_DIR}${preloader} of=${BOOTLOADER_DEV} status=progress
				if [ $? -ne 0 ]; then
					echo "Something went wrong while copying the preloader. Boot patition can't be configured."
					exit
				fi
			fi	
			echo "Successfully prepared boot partition for running project ${ADI_EVAL_BOARD} on ${CARRIER}."
		fi
	else
		echo "Setup won't be configured because setup variables are null."
	fi
else
	echo "Setup won't be configured because Xilinx and Intel boot files were not installed."
fi
