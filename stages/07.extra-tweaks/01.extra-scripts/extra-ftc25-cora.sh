#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

mkdir -p /home/analog/ftc25-cora

# Copy boot files
mkdir /boot/zynq-coraz7s-adxl355
cp stages/07.extra-tweaks/01.extra-scripts/ftc25-cora/BOOT.BIN /boot/zynq-coraz7s-adxl355
cp stages/07.extra-tweaks/01.extra-scripts/ftc25-cora/devicetree.dtb /boot/zynq-coraz7s-adxl355
cp stages/07.extra-tweaks/01.extra-scripts/ftc25-cora/uImage /boot/zynq-common
cp stages/07.extra-tweaks/01.extra-scripts/ftc25-cora/uEnv.txt /boot/zynq-common
cp stages/07.extra-tweaks/01.extra-scripts/ftc25-cora/zynq.json /boot/zynq-common

# Install Debian packages
apt install -y nsnake kbd bc

# Install Python packages
pip3 install pynput keyboard --break-system-packages --no-input

# Copy exercises and examples
cp stages/07.extra-tweaks/01.extra-scripts/ftc25-cora/leds.sh /usr/local/bin/
cp stages/07.extra-tweaks/01.extra-scripts/ftc25-cora/game.py /home/analog/ftc25-cora

# Copy Linux headers and ADXL355 driver
unzip stages/07.extra-tweaks/01.extra-scripts/ftc25-cora/linux-headers-6.1.0.zip
cp -r linux-headers-6.1.0 /usr/src/
rm -r linux-headers-6.1.0

cp stages/07.extra-tweaks/01.extra-scripts/ftc25-cora/adxl355.h /home/analog/ftc25-cora
cp stages/07.extra-tweaks/01.extra-scripts/ftc25-cora/adxl355_spi.c /home/analog/ftc25-cora

# Copy shutdown service
cp stages/07.extra-tweaks/01.extra-scripts/ftc25-cora/shutdown-cora.service /etc/systemd/system/
systemctl enable shutdown-cora.service


sed -i 's/analog/ftc25-cora/g' /etc/hostname
sed -i 's/analog/ftc25-cora/g' /etc/hosts
