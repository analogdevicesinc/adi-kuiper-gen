#!/bin/bash -e

on_chroot << EOF
   wget https://downloads.sourceforge.net/project/gtkdatabox/gtkdatabox-1/gtkdatabox-1.0.0.tar.gz
   tar xvf gtkdatabox-1.0.0.tar.gz

   pushd gtkdatabox-1.0.0
   ./configure
   make install
   popd

   rm -rf gtkdatabox-1.0.0.tar.gz

   [ -d "linux_image_ADI-scripts" ] || {
	git clone https://github.com/analogdevicesinc/linux_image_ADI-scripts -b main
   }

   pushd linux_image_ADI-scripts
   chmod +x adi_update_tools.sh
   ./adi_update_tools.sh 2022_R2
   popd

EOF
