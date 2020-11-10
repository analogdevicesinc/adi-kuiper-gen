#!/bin/bash -e

on_chroot << EOF
git clone https://github.com/analogdevicesinc/linux_image_ADI-scripts

pushd linux_image_ADI-scripts
chmod +x adi_update_tools.sh
./adi_update_tools.sh 2019_R2

popd

EOF
