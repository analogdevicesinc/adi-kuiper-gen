#!/bin/bash -e

LIBIIO_BRANCH=master
LIBAD9361_BRANCH=master
LIBM2K_BRANCH=master
GRIIO_BRANCH=upgrade-3.8
GNURADIO_FORK=gnuradio
GNURADIO_BRANCH=maint-3.8
GRSCOPY_BRANCH=master
GRM2K_BRANCH=master
QWT_BRANCH=qwt-6.1-multiaxes
QWTPOLAR_BRANCH=master
LIBSIGROK_BRANCH=master
LIBSIGROKDECODE_BRANCH=master

SCOPY_RELEASE=v1.3.0-rc2
SCOPY_ARCHIVE=scopy-${SCOPY_RELEASE}-Linux-arm.flatpak.zip
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
	make
	make test
	make install

	ldconfig

	popd 1> /dev/null

	[ -d "gnuradio" ] || {
		git clone https://github.com/gnuradio/gnuradio.git
		mkdir -p gnuradio/build
	}

	pushd gnuradio/build
	git checkout maint-3.8

	cmake -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/bin/python3 -DENABLE_INTERNAL_VOLK=OFF ../ 
	make ${JOBS}
	make install

	popd 1> /dev/null

	rm -rf volk/
	rm -rf gnuradio/
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

build_libsigrokdecode() {
	echo "### Building libsigrokdecode - branch $LIBSIGROKDECODE_BRANCH"

	[ -d "libsigrokdecode" ] || {
		git clone https://github.com/sigrokproject/libsigrokdecode.git -b "${LIBSIGROKDECODE_BRANCH}" "libsigrokdecode"
		mkdir -p "libsigrokdecode/build-${ARCH}"
	}

	pushd "libsigrokdecode"

	./autogen.sh
	pushd "build-${ARCH}"

	../configure --disable-all-drivers --enable-bindings --enable-cxx
	make $JOBS install
	DESTDIR=${STAGE_WORK_DIR} make $JOBS install

	popd 1> /dev/null
	popd 1> /dev/null

	rm -rf libsigrokdecode/
}

install_scopy() {
	[ -f "Scopy.flatpak" ] || {
		wget ${SCOPY}
		unzip ${SCOPY_ARCHIVE}
		flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
		flatpak install Scopy.flatpak --assumeyes
		mkdir -p /usr/local/share/scopy
		wget https://raw.githubusercontent.com/analogdevicesinc/scopy/86ddd9dce67b2d90e7e52801d6bf730859153c4f/resources/icon_big.svg
		mv icon_big.svg /usr/local/share/scopy/icon.svg
	}
	echo "
	[Desktop Entry]
	Version=1.1	
	Type=Application
	Encoding=UTF-8
	Name=Scopy
	Comment=ADI
	Icon=/usr/local/share/scopy/icon.svg
	Exec=flatpak run org.adi.Scopy
	Terminal=false
	Categories=Science" > /usr/share/applications/Scopy.desktop
	echo "alias scopy='flatpak run org.adi.Scopy'" >> /root/.bashrc
	echo "alias scopy='flatpak run org.adi.Scopy'" >> /home/analog/.bashrc
}

install_scopy
build_gnuradio
build_libm2k
build_griio
build_grm2k
build_libsigrokdecode

EOF
