#!/bin/bash -e

on_chroot << EOF

pip3 install pyadi-iio
pip3 install git+https://github.com/analogdevicesinc/pyadi-dt.git
echo "export PYTHONPATH=\"${PYTHONPATH}:/usr/local/lib/python3/dist-packages:/lib/python3.9/site-packages\"" >> /home/analog/.bashrc
echo "export LD_LIBRARY_PATH=\"${LD_LIBRARY_PATH}:/usr/local/lib\"" >> /home/analog/.bashrc
ldconfig
EOF
