#!/bin/bash -e

on_chroot << EOF

sed 's/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/g' config.txt
sed 's/#dtparam=spi=on/dtparam=spi=on/g' config.txt
echo "dtoverlay=rgpio=on" | tee -a config.txt
echo "enable_uart=1" | tee -a config.txt
echo "dtoverlay=disable-bt" | tee -a config.txt

EOF
