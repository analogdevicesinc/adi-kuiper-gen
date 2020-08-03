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

ARCH=arm
JOBS=-j4

on_chroot << EOF
build_gnuradio() {

	[ -d "volk" ] || {
		git clone https://github.com/gnuradio/volk.git
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

	cmake -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/bin/python3 \
		-DENABLE_INTERNAL_VOLK=OFF -DENABLE_GR_ZEROMQ=OFF \
		-DENABLE_GR_WAVELET=OFF -DENABLE_GR_VOCODER=OFF \
		-DENABLE_GR_VIDEO_SDL=OFF -DENABLE_GR_TRELLIS=OFF \
		-DENABLE_GR_DTV=OFF -DENABLE_GR_FEC=OFF ../
	make ${JOBS}
	make install

	popd 1> /dev/null
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
		-DINSTALL_UDEV_RULES=OFF ../

	make $JOBS
	make ${JOBS} install

	popd 1> /dev/null
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
}

build_grscopy() {
	echo "### Building gr-scopy - branch $GRSCOPY_BRANCH"

	[ -d "gr-scopy" ] || {
		git clone https://github.com/analogdevicesinc/gr-scopy.git -b "${GRSCOPY_BRANCH}" "gr-scopy"
		mkdir "gr-scopy/build-${ARCH}"
	}

	pushd "gr-scopy/build-${ARCH}"

	cmake ${CMAKE_OPTS} ../

	make $JOBS
	make $JOBS install

	popd 1> /dev/null
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
}

build_qwt() {
	echo "### Building qwt - branch $QWT_BRANCH"

	[ -d "qwt" ] || {
		git clone https://github.com/osakared/qwt.git -b "${QWT_BRANCH}" "qwt"
	}

	pushd "qwt"

	# Fix prefix
	sed -i "s+\/usr\/local\/qwt-.*+\/usr\/local+g" qwtconfig.pri

	# Disable components that we won't build
	sed -i "s/^QWT_CONFIG\\s*+=\\s*QwtMathML$/#/g" qwtconfig.pri
	sed -i "s/^QWT_CONFIG\\s*+=\\s*QwtDesigner$/#/g" qwtconfig.pri
	sed -i "s/^QWT_CONFIG\\s*+=\\s*QwtExamples$/#/g" qwtconfig.pri

	qmake qwt.pro
	make $JOBS
	make install

	popd 1> /dev/null
}

build_qwtpolar() {
	echo "### Building qwtpolar - branch $QWTPOLAR_BRANCH"

	[ -d "qwtpolar" ] || {
		mkdir -p "qwtpolar"
	}
	pushd "qwtpolar"

	wget https://downloads.sourceforge.net/project/qwtpolar/qwtpolar/1.1.1/qwtpolar-1.1.1.tar.bz2
	tar -xf qwtpolar-1.1.1.tar.bz2

	pushd qwtpolar-1.1.1
	curl -o qwtpolar-qwt-6.1-compat.patch https://raw.githubusercontent.com/analogdevicesinc/scopy-flatpak/master/qwtpolar-qwt-6.1-compat.patch
	patch -p1 < qwtpolar-qwt-6.1-compat.patch
	sed -i 's/\/usr\/local\/qwtpolar-.*/\/usr\/local/g' qwtpolarconfig.pri
	sed -i 's/QWT_POLAR_CONFIG     += QwtPolarExamples/ /g' qwtpolarconfig.pri
	sed -i 's/QWT_POLAR_CONFIG     += QwtPolarDesigner/ /g' qwtpolarconfig.pri
	qmake qwtpolar.pro
	make $JOBS
	make install

	popd 1> /dev/null
	popd 1> /dev/null
}

build_gnuradio
build_libm2k
build_griio
build_grm2k
build_grscopy
build_libsigrokdecode
#build_qwt
#build_qwtpolar

EOF
