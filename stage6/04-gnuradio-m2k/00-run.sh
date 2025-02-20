#!/bin/bash -e

LIBM2K_BRANCH="v0.9.0"
GRIIO_BRANCH="upgrade-3.8"
GRM2K_BRANCH="maint-3.8"
LIBSIGROKDECODE_BRANCH="master"

export SCOPY_RELEASE=v2.0.0-beta-rc2
export SCOPY_ARCHIVE=Scopy-${SCOPY_RELEASE}-Linux-armhf-AppImage.zip
export SCOPY_PATH=https://github.com/analogdevicesinc/scopy/releases/download/${SCOPY_RELEASE}/${SCOPY_ARCHIVE}
export SCOPY=Scopy-${SCOPY_RELEASE}-Linux-armhf

ARCH=arm
JOBS=-j${NUM_JOBS}

# Add desktop file and icon for Scopy
install -d "${ROOTFS_DIR}/usr/local/share/scopy/icons/"
install -d "${ROOTFS_DIR}/usr/local/share/applications/"
cp files/scopy.desktop "${ROOTFS_DIR}/usr/local/share/applications/"
cp files/scopy.png     "${ROOTFS_DIR}/usr/local/share/scopy/icons/scopy.png"

on_chroot << EOF
install_gnuradio() {

	echo "### Installing gnuradio"
	apt install gnuradio -y
	ldconfig
}

build_libm2k() {
	echo "$LIBM2K_BRANCH"
	echo "### Building libm2k - branch ${LIBM2K_BRANCH}"

	[ -d "libm2k" ] || {
		git clone https://github.com/analogdevicesinc/libm2k.git -b "${LIBM2K_BRANCH}" "libm2k"
		mkdir "libm2k/build-${ARCH}"
	}

	pushd "libm2k/build-${ARCH}"

	cmake	"${CMAKE_OPTS}" \
		-DENABLE_PYTHON=ON\
		-DENABLE_CSHARP=OFF\
		-DENABLE_EXAMPLES=ON\
		-DENABLE_TOOLS=ON\
		-DINSTALL_UDEV_RULES=ON ../

	make $JOBS
	make ${JOBS} install

	popd 1> /dev/null

	rm -rf libm2k/
}

build_griio() {
	echo "### Building gr-iio - branch $GRIIO_BRANCH"

	[ -d "gr-iio" ] || {
		git clone https://github.com/analogdevicesinc/gr-iio.git -b "${GRIIO_BRANCH}" "gr-iio"
		mkdir "gr-iio/build-${ARCH}"
	}

	pushd "gr-iio/build-${ARCH}"

	cmake "${CMAKE_OPTS}" ../

	make $JOBS
	make $JOBS install

	popd 1> /dev/null

	rm -rf gr-iio/

	# Update gnu-radio-grc.desktop
	sed -i 's/Exec=/Exec=env PYTHONPATH=\/usr\/local\/lib\/python3\/dist-packages:\/lib\/python3.9\/site-packages /g' "/usr/share/applications/gnuradio-grc.desktop"

}

build_grm2k() {
	echo "### Building gr-m2k - branch $GRM2K_BRANCH"

	[ -d "gr-m2k" ] || {
		git clone https://github.com/analogdevicesinc/gr-m2k.git -b "${GRM2K_BRANCH}" "gr-m2k"
		mkdir "gr-m2k/build-${ARCH}"
	}

	pushd "gr-m2k/build-${ARCH}"

	cmake "${CMAKE_OPTS}" ../

	make $JOBS
	make $JOBS install

	popd 1> /dev/null

	rm -rf gr-m2k/
}

install_scopy() {

	# Install Scopy 2
	wget -q ${SCOPY_PATH}
	unzip ${SCOPY_ARCHIVE} && mv ${SCOPY}/* . && rm ${SCOPY_ARCHIVE}
	chmod +x ${SCOPY}.AppImage
	mv ${SCOPY}.AppImage /usr/local/bin

	sed -i 's/<name>/${SCOPY}.AppImage/g' /usr/local/share/applications/scopy.desktop

	echo "alias scopy='/usr/local/bin/${SCOPY}.AppImage'" >> /etc/bash.bashrc
	echo "alias Scopy='/usr/local/bin/${SCOPY}.AppImage'" >> /etc/bash.bashrc
}

install_scopy
install_gnuradio
build_libm2k
build_griio
build_grm2k
ldconfig
EOF
