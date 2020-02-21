#!/bin/bash -e

on_chroot << EOF

git clone https://github.com/analogdevicesinc/gr-iio.git
pushd gr-iio
cmake .
make -j $NUM_JOBS
sudo make install
popd
ldconfig

rm -rf gr-iio
EOF
