#!/bin/bash -e

LIBM2K_BRANCH="v0.8.0"
GRIIO_BRANCH="upgrade-3.8" # let this to 'upgrade-3.8' since GNU Radio is 3.8.2
GRM2K_BRANCH="maint-3.8" # let this to 'maint-3.8' since GNU Radio installed in Kuiper is 3.8.2
LIBSIGROKDECODE_BRANCH="master"

SCOPY_RELEASE="v1.4.1" # latest scopy release from 03 August 2022
SCOPY_ARCHIVE=Scopy-${SCOPY_RELEASE}-Linux-arm.zip
SCOPY=https://github.com/analogdevicesinc/scopy/releases/download/${SCOPY_RELEASE}/${SCOPY_ARCHIVE}

ARCH=arm
JOBS=-j${NUM_JOBS}

on_chroot << EOF
build_gnuradio() {

	[ -d "volk" ] || {
		git clone --recursive https://github.com/gnuradio/volk.git
		mkdir -p volk/build
	}

	pushd volk/build
	cmake -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/bin/python3 ../
	make ${JOBS}
	make install
	ldconfig
	popd 1> /dev/null # volk/build
	rm -rf volk/

	#uncomment next lines is case you need a non-default version (default for bullseye: 3.8.2)
	apt-get update
	#add-apt-repository ppa:gnuradio/gnuradio-releases-3.10
	#apt-get update

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
	[ -f "Scopy.flatpak" ] || {
		wget ${SCOPY}
		unzip ${SCOPY_ARCHIVE}
		flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
		flatpak install Scopy.flatpak --assumeyes
		rm -rf ${SCOPY_ARCHIVE}
	}
	echo "alias scopy='flatpak run org.adi.Scopy'" >> /root/.bashrc
	echo "alias scopy='flatpak run org.adi.Scopy'" >> /home/analog/.bashrc
}

install_scopy
build_gnuradio
build_libm2k
build_griio
build_grm2k
ldconfig
EOF
