#!/bin/bash -e

on_chroot << EOF

# Install latest release tag of pyadi-iio
pip3 install pyadi-iio
# If you want to switch the installation from last release tag to latest main, use next line
#pip3 install git+https://github.com/analogdevicesinc/pyadi-iio.git

pip3 install git+https://github.com/analogdevicesinc/pyadi-dt.git
echo "export LD_LIBRARY_PATH=\"${LD_LIBRARY_PATH}:/usr/local/lib\"" >> /home/analog/.bashrc
ldconfig
EOF
