#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

# Copy shutdown service
cp stages/07.extra-tweaks/01.extra-scripts/ftc25-pi4/shutdown-pi4.service /etc/systemd/system/
systemctl enable shutdown-pi4.service

sed -i 's/analog/ftc25-pi4/g' /etc/hostname
sed -i 's/analog/ftc25-pi4/g' /etc/hosts
