#!/bin/bash -e

ADITOF_SDK_BRANCH=master

on_chroot << EOF

mkdir -p "home/${FIRST_USER_NAME}"
mkdir -p "home/${FIRST_USER_NAME}/Desktop"
mkdir -p "home/${FIRST_USER_NAME}/workspace"

#pushd "home/${FIRST_USER_NAME}"

#mkdir -p workspace/github
#pushd workspace/github

#[ -d "aditof_sdk" ] || {
#    git clone https://github.com/analogdevicesinc/aditof_sdk.git -b "${ADITOF_SDK_BRANCH}"
#}

#pushd aditof_sdk

#./scripts/raspberrypi3/setup.sh -y -na -ur -es -j "${NUM_JOBS}" -b build -d deps_source_code -i deps_installed

#popd 1> /dev/null # pushd aditof_sdk
#popd 1> /dev/null # pushd workspace/github
#popd 1> /dev/null # pushd "home/${FIRST_USER_NAME}"

#mkdir -p "home/${FIRST_USER_NAME}/Desktop"
#pushd "home/${FIRST_USER_NAME}/Desktop"

#touch aditof-demo.sh
#echo '#!/bin/bash' >> aditof-demo.sh
#echo "cd /home/${FIRST_USER_NAME}/workspace/github/aditof_sdk/build/examples/aditof-demo" >> aditof-demo.sh
#echo './aditof-demo' >> aditof-demo.sh
#chmod +x aditof-demo.sh

sudo chown -R ${FIRST_USER_NAME}:${FIRST_USER_NAME} "/home/${FIRST_USER_NAME}/workspace"
sudo chown -R ${FIRST_USER_NAME}:${FIRST_USER_NAME} "/home/${FIRST_USER_NAME}/Desktop"

#popd 1> /dev/null # pushd "home/${FIRST_USER_NAME}/Desktop"

EOF
