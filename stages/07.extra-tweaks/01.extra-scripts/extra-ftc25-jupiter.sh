#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

mkdir -p /home/analog

cp -r stages/07.extra-tweaks/01.extra-scripts/ftc25-jupiter /home/analog

sed -i 's/analog/ftc25-jupiter/g' /etc/hostname
sed -i 's/analog/ftc25-jupiter/g' /etc/hosts
