#!/bin/bash -e

on_chroot << EOF

pip3 install pyadi-iio
echo "export PYTHONPATH=\"${PYTHONPATH}:/lib/python3.7/site-packages\"" >> /home/analog/.bashrc

git clone https://github.com/analogdevicesinc/libm2k.git
pushd libm2k
cmake -DENABLE_PYTHON=ON -DENABLE_EXCEPTIONS=TRUE -Bbuild -H.
pushd build
make -j $NUM_JOBS
sudo make install
popd
popd
ldconfig

rm -rf libm2k
EOF
