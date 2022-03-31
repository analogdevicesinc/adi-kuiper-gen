#!/bin/bash
set -e

SCRIPTS_DIR=wiki-scripts
LINUX="linux-adi"

declare -a klist=("zynq" "zynqmp" "socfpga")
declare -a rpi_configs=("rpi" "2709" "2711")
declare -a rpi_knames=("" "7" "7l")

build_rpi_linux() {

	git checkout $(git branch -a --sort=-committerdate | grep -E 'rpi\-[0-9]{1,2}\.[0-9]{1,2}\.y$' | head -1 | sed -e 's/^remotes\/origin\///' -e 's/* //')

	unset KCFLAGS ARCH CROSS_COMPILE
	DEFCONFIG=$1 source $WORK_DIR/$SCRIPTS_DIR/linux/build_rpi_kernel_image.sh . "" ""
	cp -f zImage $STAGE_WORK_DIR/rootfs/boot/$2

	make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE INSTALL_MOD_PATH=$STAGE_WORK_DIR/rootfs modules_install
	make dtbs

	cp -f arch/$ARCH/boot/dts/overlays/*.dtb* $STAGE_WORK_DIR/rootfs/boot/overlays
	cp -f arch/$ARCH/boot/dts/bcm27*.dtb $STAGE_WORK_DIR/rootfs/boot
}

build_linux() {

	[ -z $LINUX_BRANCH ] && {
		LINUX_BRANCH=master
	}

	git checkout $LINUX_BRANCH

	unset KCFLAGS ARCH CROSS_COMPILE DEFCONFIG
	make clean
	source $WORK_DIR/$SCRIPTS_DIR/linux/build_$1_kernel_image.sh "$WORK_DIR/$LINUX" "" ""
	mkdir -p $WORK_DIR/boot_partition/$1-common
	mv arch/$ARCH/boot/*Image $WORK_DIR/boot_partition/$1-common
}

pushd "$WORK_DIR"

[ -d "$SCRIPTS_DIR" ] || {
	git clone https://github.com/analogdevicesinc/wiki-scripts.git "$SCRIPTS_DIR"
	sed -i "s/make \$DEFCONFIG/make \$DEFCONFIG\necho \"\$(cat \$STAGE_DIR\/01-adi-kernel-dts\/files\/kuiper_defconfig)\" >> \.config\nyes \"\" \| make oldconfig/g" $SCRIPTS_DIR/linux/build_*
}

[ -d $LINUX ] || {
	git clone https://github.com/analogdevicesinc/linux $LINUX
}
pushd "$LINUX"

for i in ${!rpi_configs[@]}; do
	echo "building for adi_bcm${rpi_configs[$i]}_defconfig kernel${rpi_knames[$i]}.img"
	build_rpi_linux adi_bcm${rpi_configs[$i]}_defconfig kernel${rpi_knames[$i]}.img
done

for kernel in ${klist[@]}; do
	echo "building for $kernel"
	build_linux $kernel
done

popd 1> /dev/null
popd 1> /dev/null

echo "Kernel build finished."