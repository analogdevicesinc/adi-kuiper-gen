#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2024 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

mkdir -p /home/analog

# Install Debian packages for general exercises
apt install -y picocom mosquitto-clients evince

# Copy custom files for multiple exercises
cp -r stages/07.extra-tweaks/01.extra-scripts/ftc25-pi5 /home/analog
mv /home/analog/ftc25-pi5/booklet.pdf /home/analog
mv /home/analog/ftc25-pi5/powerpoint.pdf /home/analog

chown -R analog:analog /home/analog/ftc25-pi5

# Install Visual Studio Code
wget -O vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64"
echo "n" | dpkg -i vscode.deb
rm vscode.deb

echo 'alias code="code --use-inmemory-secretstorage"' >> /etc/bash.bashrc

# Install Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sed -i 's/analog/ftc25-pi5/g' /etc/hostname
sed -i 's/analog/ftc25-pi5/g' /etc/hosts
