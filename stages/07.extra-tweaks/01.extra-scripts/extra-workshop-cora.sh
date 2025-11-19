#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

mkdir /adxl355

# Copy boot files
mkdir /boot/zynq-coraz7s-adxl355
cp stages/07.extra-tweaks/01.extra-scripts/workshop-cora/BOOT.BIN /boot/zynq-coraz7s-adxl355
cp stages/07.extra-tweaks/01.extra-scripts/workshop-cora/devicetree.dtb /boot/zynq-coraz7s-adxl355
cp stages/07.extra-tweaks/01.extra-scripts/workshop-cora/uImage /boot/zynq-common
cp stages/07.extra-tweaks/01.extra-scripts/workshop-cora/uEnv.txt /boot/zynq-common
cp stages/07.extra-tweaks/01.extra-scripts/workshop-cora/zynq.json /boot/zynq-common

# Install Debian packages
apt install -y nsnake kbd bc

# Install Python packages
pip3 install pynput keyboard --break-system-packages --no-input

# Copy exercises and examples
cp stages/07.extra-tweaks/01.extra-scripts/workshop-cora/leds.sh /
cp stages/07.extra-tweaks/01.extra-scripts/workshop-cora/game.py /

# Copy Linux headers and ADXL355 driver
unzip stages/07.extra-tweaks/01.extra-scripts/workshop-cora/linux-headers-6.1.0.zip
cp -r linux-headers-6.1.0 /usr/src/
rm -r linux-headers-6.1.0

cp stages/07.extra-tweaks/01.extra-scripts/workshop-cora/adxl355.h /adxl355/
cp stages/07.extra-tweaks/01.extra-scripts/workshop-cora/adxl355_spi.c /adxl355/

# Copy shutdown service
cp stages/07.extra-tweaks/01.extra-scripts/workshop-cora/shutdown-cora.service /etc/systemd/system/
systemctl enable shutdown-cora.service


sed -i 's/analog/workshop-cora/g' /etc/hostname
sed -i 's/analog/workshop-cora/g' /etc/hosts
