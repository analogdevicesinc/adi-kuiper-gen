#!/bin/bash -e

on_chroot << EOF

pip install pyadi-iio

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
