#!/bin/bash -e

on_chroot << EOF
git clone https://github.com/analogdevicesinc/linux_image_ADI-scripts

pushd linux_image_ADI-scripts
chmod +x adi_update_tools.sh
./adi_update_tools.sh

popd

rm -rf linux_image_ADI-scripts
EOF
