#!/bin/bash -e

on_chroot << EOF
   wget https://downloads.sourceforge.net/project/gtkdatabox/gtkdatabox-1/gtkdatabox-1.0.0.tar.gz
   tar xvf gtkdatabox-1.0.0.tar.gz
   cd gtkdatabox-1.0.0
   ./configure
   make install


[ -d "linux_image_ADI-scripts" ] || {
	git clone https://github.com/analogdevicesinc/linux_image_ADI-scripts
}

pushd linux_image_ADI-scripts
chmod +x adi_update_tools.sh
./adi_update_tools.sh next_stable

popd

EOF
