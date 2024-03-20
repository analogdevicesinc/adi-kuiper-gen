#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

set -e
source config

# Declare ANSI escape codes to color the output in the terminal
MAGENTA="`tput setaf 5`"
RESET="`tput sgr0`"

export LOG_FILE="kuiper-volume/build.log"
export GITHUB_ANALOG_DEVICES="https://github.com/analogdevicesinc"
export ADI_REPOS="ADI_repos_git_info.txt"
export TARGET_ARCHITECTURE=${TARGET_ARCHITECTURE:-armhf}
export BUILD_DIR=${TARGET_ARCHITECTURE}_rootfs
export IMG_FILE="image_"$(date +%Y-%m-%d)"-ADI-Kuiper-Linux-$TARGET_ARCHITECTURE.img" 
export NUM_JOBS=${NUM_JOBS:-$(nproc)}

export CONFIG_DESKTOP=${CONFIG_DESKTOP:-n}
export CONFIG_LIBIIO=${CONFIG_LIBIIO:-n}
export CONFIG_PYADI=${CONFIG_PYADI:-n}
export CONFIG_LIBM2K=${CONFIG_LIBM2K:-n}
export CONFIG_LIBAD9166_IIO=${CONFIG_LIBAD9166_IIO:-n}
export CONFIG_LIBAD9361_IIO=${CONFIG_LIBAD9361_IIO:-n}
export CONFIG_IIO_OSCILLOSCOPE=${CONFIG_IIO_OSCILLOSCOPE:-n}
export CONFIG_IIO_FM_RADIO=${CONFIG_IIO_FM_RADIO:-n}
export CONFIG_FRU_TOOLS=${CONFIG_FRU_TOOLS:-n}
export CONFIG_SCOPY=${CONFIG_SCOPY:-n}
export CONFIG_GNURADIO=${CONFIG_GNURADIO:-n}
export CONFIG_GRM2K=${CONFIG_GRM2K:-n}
export CONFIG_JESD_EYE_SCAN_GTK=${CONFIG_JESD_EYE_SCAN_GTK:-n}
export CONFIG_COLORIMETER=${CONFIG_COLORIMETER:-n}
export CONFIG_RPI_BOOT_FILES=${CONFIG_RPI_BOOT_FILES:-n}
export CONFIG_XILINX_INTEL_BOOT_FILES=${CONFIG_XILINX_INTEL_BOOT_FILES:-n}
export EXPORT_SOURCES=${EXPORT_SOURCES:-n}

export CONFIG_LIBIIO_CMAKE_ARGS=${CONFIG_LIBIIO_CMAKE_ARGS:-""}
export CONFIG_LIBM2K_CMAKE_ARGS=${CONFIG_LIBM2K_CMAKE_ARGS:-""}
export CONFIG_LIBAD9166_IIO_CMAKE_ARGS=${CONFIG_LIBAD9166_IIO_CMAKE_ARGS:-""}
export CONFIG_LIBAD9361_IIO_CMAKE_ARGS=${CONFIG_LIBAD9361_IIO_CMAKE_ARGS:-""}
export CONFIG_IIO_OSCILLOSCOPE_CMAKE_ARGS=${CONFIG_IIO_OSCILLOSCOPE_CMAKE_ARGS:-""}
export CONFIG_GRM2K_CMAKE_ARGS=${CONFIG_GRM2K_CMAKE_ARGS:-""}

export BRANCH_LIBIIO=${BRANCH_LIBIIO:-main}
export BRANCH_PYADI=${BRANCH_PYADI:-main}
export BRANCH_LIBM2K=${BRANCH_LIBM2K:-main}
export BRANCH_LIBAD9361_IIO=${BRANCH_LIBAD9361_IIO:-main}
export BRANCH_LIBAD9166_IIO=${BRANCH_LIBAD9166_IIO:-main}
export BRANCH_IIO_OSCILLOSCOPE=${BRANCH_IIO_OSCILLOSCOPE:-main}
export BRANCH_IIO_FM_RADIO=${BRANCH_IIO_FM_RADIO:-main}
export BRANCH_FRU_TOOLS=${BRANCH_FRU_TOOLS:-main}
export BRANCH_JESD_EYE_SCAN_GTK=${BRANCH_JESD_EYE_SCAN_GTK:-main}
export BRANCH_COLORIMETER=${BRANCH_COLORIMETER:-main}
export BRANCH_GRM2K=${BRANCH_GRM2K:-main}
export RELEASE_XILINX_INTEL_BOOT_FILES=${RELEASE_XILINX_INTEL_BOOT_FILES:-2022_r2}
export BRANCH_RPI_BOOT_FILES=${BRANCH_RPI_BOOT_FILES:-rpi-6.1.y}

export USE_ADI_REPO_RPI_BOOT=${USE_ADI_REPO_RPI_BOOT:-n}
export USE_ADI_REPO_CARRIERS_BOOT=${USE_ADI_REPO_CARRIERS_BOOT:-n}

# Check if architecture is supported
if [[ ! ${TARGET_ARCHITECTURE} = armhf && ! ${TARGET_ARCHITECTURE} = arm64 ]]; then
	echo "Unsupported architecture ${TARGET_ARCHITECTURE}"
	exit 1
fi

# Save logs with timestamps in build.log
exec > >(TZ=UTC-3 ts '[%b %d %H:%M:%S]' | tee -ia "${LOG_FILE}") 2>&1

echo "${LIGHT_BLUE}Building Kuiper with Debian ${DEBIAN_VERSION} for architecture ${TARGET_ARCHITECTURE}${RESET}"

# Install packages considering config file
install_packages() {
chroot "${BUILD_DIR}" << EOF
	if [ -e "${1}"/packages ]
	then
		xargs -a "${1}"/packages apt-get install --no-install-recommends -y
	elif ([ -e "${1}"/packages-desktop-with-recommends ] && [ "${CONFIG_DESKTOP}" = y ])
	then
		xargs -a "${1}"/packages-desktop-with-recommends apt-get install -y
	elif ([ -e "${1}"/packages-libiio ] && [ "${CONFIG_LIBIIO}" = y ])
	then
		xargs -a "${1}"/packages-libiio-with-recommends apt-get install -y
		xargs -a "${1}"/packages-libiio apt-get install --no-install-recommends -y
	elif ([ -e "${1}"/packages-pyadi-with-recommends ] && [ "${CONFIG_PYADI}" = y ])
	then
		xargs -a "${1}"/packages-pyadi-with-recommends apt-get install -y
	elif ([ -e "${1}"/packages-iio-oscilloscope ] && [ "${CONFIG_IIO_OSCILLOSCOPE}" = y ])
	then
		xargs -a "${1}"/packages-iio-oscilloscope apt-get install --no-install-recommends -y
	elif ([ -e "${1}"/packages-libm2k ] && [ "${CONFIG_LIBM2K}" = y ])
	then
		xargs -a "${1}"/packages-libm2k apt-get install --no-install-recommends -y
	elif ([ -e "${1}"/packages-fru-tools ] && [ "${CONFIG_FRU_TOOLS}" = y ])
	then
		xargs -a "${1}"/packages-fru-tools apt-get install --no-install-recommends -y
	elif ([ -e "${1}"/packages-jesd-eye-scan-gtk ] && [ "${CONFIG_JESD_EYE_SCAN_GTK}" = y ])
	then
		xargs -a "${1}"/packages-jesd-eye-scan-gtk apt-get install --no-install-recommends -y
	elif ([ -e "${1}"/packages-colorimeter ] && [ "${CONFIG_COLORIMETER}" = y ])
	then
		xargs -a "${1}"/packages-colorimeter apt-get install --no-install-recommends -y
	fi
EOF
}
export -f install_packages

# Run every 'run.sh' script inside 'stages' directory and install corresponding packages.
# 'find' command is used to search in every directory inside 'stages' and locate every 'run.sh' in alphanumeric order.
# The packages are located in '00.install-packages' directory in every substage.
for script in $(find stages -type f -name run.sh | sort); do
	echo "${MAGENTA}Start stage ${script:7:-7}${RESET}"
	
	if [ -e "${script%%/run.sh}"/00.install-packages ]; then
		install_packages "${script%%/run.sh}"/00.install-packages
	fi
	
	bash -e ${script}
	echo "End stage ${script:7:-7}"
done
