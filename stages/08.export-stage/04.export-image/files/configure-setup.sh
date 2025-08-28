#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

show_help() {

cat << EOF
Usage:
  sudo $(basename "$0") [OPTIONS] [ARGUMENTS]

Description:
  Script that prepares Kuiper image to boot on a carrier board.

Arguments:
  eval-board	Name of the project
  carrier	Carrier board name

Options:
  -h, --help	Show this help message

Example:
  sudo $(basename "$0") ad4003 zed
EOF

	echo -e "\n\nAvailable projects in your Kuiper image:\n"

	{
		# Print header
		echo -e "ADI Eval Board\tCarrier"

		# Print projects and boards
		find /boot -type f -name "*.json" | while read -r file; do
			jq -r '
			.projects[]?
			| select(has("name") and has("board"))
			| [.name, .board]
			| @tsv
			' "$file"
		done
	} | column -t -s $'\t'
}

# Check if the script is run as root
if [ "$(id -u)" != "0" ] ; then
	echo "This script must be run as root"
	exit 1
fi

# Handle -h / --help first
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	show_help
	exit 0
fi

# Validate positional arguments
if [[ $# -lt 2 ]]; then
	echo -e "Error: Missing arguments.\n" >&2
	show_help
	exit 2
fi

ADI_EVAL_BOARD=${1}
CARRIER=${2}
BOOTLOADER_DEV=${3:-"/dev/mmcblk0p3"}

if [[ ! -z "${ADI_EVAL_BOARD}"  && ! -z "${CARRIER}" ]]; then

	# Extract project description from .json by selecting the project set in the configuration file
	PROJECT_DESCRIPTION=$(find /boot -type f -name "*.json" \
		-exec jq -c '.projects[]? | select(.name=="'${ADI_EVAL_BOARD}'" and .board=="'${CARRIER}'")' {} + \
		| head -n 1)

	# Check if project exists
	if [[ -z "${PROJECT_DESCRIPTION}" ]]; then
		echo "Cannot find project ${ADI_EVAL_BOARD} for board ${CARRIER}. Setup not configured."
	else
		# Extract kernel path from the project description
		kernel=$(echo "$PROJECT_DESCRIPTION" | jq -r '.kernel')

		# Copy kernel to Kuiper boot directory
		cp -v ${kernel} /boot
		if [ $? -ne 0 ]; then
			echo "Something went wrong while copying the kernel. Boot partition can't be configured."
			exit
		fi

		# Extract paths with boot files from the project description
		paths=$(echo "$PROJECT_DESCRIPTION" | jq -r '.files[].path')

		# Add the correct prefix for all paths and copy them to Kuiper boot directory
		cp -v $paths /boot
		if [ $? -ne 0 ]; then
			echo "Something went wrong while copying boot files. Boot partition can't be configured."
			exit
		fi

		# Check if project platform is Intel
		if [[ ! -z $(echo "$PROJECT_DESCRIPTION" | jq 'select(.platform == "intel")') ]]; then

			# Create folder if it doesn't exist and move copied extlinux.conf to extlinux folder
			mkdir -p /boot/extlinux/ && mv -v /boot/extlinux.conf /boot/extlinux/

			# Extract preloader file from the project description
			preloader=$(echo "$PROJECT_DESCRIPTION" | jq -r '.preloader')

			# Write preloader file to corresponding image partition
			dd if=${preloader} of=${BOOTLOADER_DEV} status=progress
			if [ $? -ne 0 ]; then
				echo "Something went wrong while copying the preloader. Boot partition can't be configured."
				exit
			fi
		fi
		echo "Successfully prepared boot partition for running project ${ADI_EVAL_BOARD} on ${CARRIER}."
	fi
else
	echo "Setup won't be configured because setup variables are null."
fi

