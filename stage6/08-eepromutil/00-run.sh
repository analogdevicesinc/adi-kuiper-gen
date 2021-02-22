#!/bin/bash -e

on_chroot << EOF

mkdir -p "home/${FIRST_USER_NAME}"
pushd "home/${FIRST_USER_NAME}"

[ -d "hats" ] || {
    git clone https://github.com/raspberrypi/hats.git -b "master"
}

pushd hats
pushd eepromutils

make && sudo make install

popd 1> /dev/null # pushd eepromutils
popd 1> /dev/null # pushd hats
popd 1> /dev/null # pushd home/analog

rm -rf hats/

EOF
