#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

CONFIG_DESKTOP=$1

# Comment package installation from sources.list
sed -i 's/deb /#deb /' /etc/apt/sources.list

# Uncomment sources installation from raspi.list in order to download sources for RPI boot files and wifi firmware (in case they were set to be installed)
sed -i 's/#deb-src /deb-src /' /etc/apt/sources.list.d/raspi.list

apt update
cd /deb-src-rpi
apt-get --download-only source raspberrypi-bootloader
if [ ${CONFIG_DESKTOP} = y ]; then
	apt-get --download-only source firmware-brcm80211
fi

# Archive with compression level 6 (on a scale from 1 to 9 representing the trade-off between compression ratio and speed)
zip -r -6 "deb-src-rpi.zip" *
find . -not -name "deb-src-rpi.zip" -delete

# Comment sources installation from raspi.list
sed -i 's/deb-src /#deb-src /' /etc/apt/sources.list.d/raspi.list

# Uncomment package installation from sources.list
sed -i 's/#deb /deb /' /etc/apt/sources.list

apt update
