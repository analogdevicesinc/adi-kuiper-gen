#!/bin/bash -e

on_chroot << EOF

pip3 install pyadi-iio
pip3 install git+https://github.com/analogdevicesinc/pyadi-dt.git
echo "export LD_LIBRARY_PATH=\"${LD_LIBRARY_PATH}:/usr/local/lib\"" >> /home/analog/.bashrc
ldconfig
EOF
