#!/bin/bash
set -e

DEFCONFIG_PI0=adi_bcmrpi_defconfig
DEFCONFIG_PI3=adi_bcm2709_defconfig
DEFCONFIG_PI4=adi_bcm2711_defconfig
KERNEL_IMG_PI0=kernel.img
KERNEL_IMG_PI3=kernel7.img
KERNEL_IMG_PI4=kernel7l.img
SCRIPTS_DIR=wiki-scripts
LINUX_DIR="${1:-linux-adi}"

build_linux() {

	pushd "$WORK_DIR"

	[ -d "$SCRIPTS_DIR" ] || {
		git clone https://github.com/analogdevicesinc/wiki-scripts.git "$SCRIPTS_DIR"
	}
	export DEFCONFIG=$1
	source $SCRIPTS_DIR/linux/build_rpi_kernel_image.sh $LINUX_DIR "" "arm-linux-gnueabihf-"
	cp -f zImage $STAGE_WORK_DIR/rootfs/boot/$2

	pushd "$LINUX_DIR"
	make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE INSTALL_MOD_PATH=$STAGE_WORK_DIR/rootfs modules_install
	make dtbs

	popd 1> /dev/null
	popd 1> /dev/null
}

build_linux $DEFCONFIG_PI0 $KERNEL_IMG_PI0
build_linux $DEFCONFIG_PI3 $KERNEL_IMG_PI3
build_linux $DEFCONFIG_PI4 $KERNEL_IMG_PI4

cp -f $WORK_DIR/$LINUX_DIR/arch/$ARCH/boot/dts/overlays/*.dtb* $STAGE_WORK_DIR/rootfs/boot/overlays
cp -f $WORK_DIR/$LINUX_DIR/arch/$ARCH/boot/dts/bcm27*.dtb $STAGE_WORK_DIR/rootfs/boot

echo "Kernel build finished."

