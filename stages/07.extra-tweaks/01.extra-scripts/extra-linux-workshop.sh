#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

mkdir /adxl355
mkdir -p /home/analog

# Copy boot files
cp stages/07.extra-tweaks/01.extra-scripts/linux-workshop/BOOT.BIN /boot/
cp stages/07.extra-tweaks/01.extra-scripts/linux-workshop/devicetree.dtb /boot/
cp stages/07.extra-tweaks/01.extra-scripts/linux-workshop/uImage /boot/
cp stages/07.extra-tweaks/01.extra-scripts/linux-workshop/uEnv.txt /boot/

# Install Debian packages
apt install -y nsnake kbd bc

# Install Python packages
pip3 install pynput keyboard --break-system-packages --no-input

# Copy exercises and examples
cp stages/07.extra-tweaks/01.extra-scripts/linux-workshop/leds.sh /
cp stages/07.extra-tweaks/01.extra-scripts/linux-workshop/game.py /

# Copy Linux headers and ADXL355 driver
unzip stages/07.extra-tweaks/01.extra-scripts/linux-workshop/linux-headers-6.1.0.zip
cp -r linux-headers-6.1.0 /usr/src/
rm -r linux-headers-6.1.0

cp stages/07.extra-tweaks/01.extra-scripts/linux-workshop/adxl355.h /adxl355/
cp stages/07.extra-tweaks/01.extra-scripts/linux-workshop/adxl355_spi.c /adxl355/
cp stages/07.extra-tweaks/01.extra-scripts/linux-workshop/adxl355_spi.ko /home/analog
