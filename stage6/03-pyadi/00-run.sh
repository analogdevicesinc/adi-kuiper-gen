#!/bin/bash -e

on_chroot << EOF

pip3 install git+https://github.com/analogdevicesinc/pyadi-iio.git
pip3 install git+https://github.com/analogdevicesinc/pyadi-dt.git
echo "export LD_LIBRARY_PATH=\"${LD_LIBRARY_PATH}:/usr/local/lib\"" >> /home/analog/.bashrc
ldconfig
EOF
