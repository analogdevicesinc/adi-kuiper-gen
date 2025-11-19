#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

# Install Debian packages
apt install -y picocom

# Install Visual Studio Code
wget -O vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64"
echo "n" | dpkg -i vscode.deb
rm vscode.deb

echo 'alias code="code --use-inmemory-secretstorage"' >> /etc/bash.bashrc

# Add custom NetworkManager connection profile
install -m 600 stages/07.extra-tweaks/01.extra-scripts/workshops/"Wired connection 2" /etc/NetworkManager/system-connections/

# Install Python packages
apt install -y libopenblas-dev ninja-build python3-dev python3-matplotlib python3-numpy
apt install -y --no-install-recommends thonny

# Build and install pyadi-iio
mkdir -p /home/analog/automation_workshop
cd /home/analog/automation_workshop

# Clone pyadi
git clone -b swiot https://github.com/constmonica/pyadi-iio.git

# Install pyadi
# --break-system-packages is needed in Debian 12 Bookworm to install packages with apt and pip in the same environment
cd pyadi-iio && yes | pip install . --break-system-packages

chmod a+w examples/workshop/exercise_2.py
chmod a+w examples/workshop/exercise_3.py
chmod a+w examples/workshop/pid_control.py

# Set hostname
sed -i 's/analog/workshops/g' /etc/hostname
sed -i 's/analog/workshops/g' /etc/hosts
