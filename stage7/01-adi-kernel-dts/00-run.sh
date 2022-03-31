#!/bin/bash
set -e
SCRIPTS_DIR=wiki-scripts
LINUX="linux-adi"

declare -a rpi_configs=("rpi" "2709" "2711")
declare -a rpi_knames=("" "7" "7l")

build_rpi_linux() {

	# this will checkout the branch that has newest commit - should use a parameter/variable to be able to switch between branches
	git checkout $(git branch -a --sort=-committerdate | grep -E 'rpi\-[0-9]{1,2}\.[0-9]{1,2}\.y$' | head -1 | sed -e 's/^remotes\/origin\///' -e 's/* //')

	unset KCFLAGS ARCH CROSS_COMPILE
	DEFCONFIG=$1 source $WORK_DIR/$SCRIPTS_DIR/linux/build_rpi_kernel_image.sh . "" ""
	cp -f zImage $STAGE_WORK_DIR/rootfs/boot/$2

	make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE INSTALL_MOD_PATH=$STAGE_WORK_DIR/rootfs modules_install
	make dtbs

	cp -f arch/$ARCH/boot/dts/overlays/*.dtb* $STAGE_WORK_DIR/rootfs/boot/overlays
	cp -f arch/$ARCH/boot/dts/bcm27*.dtb $STAGE_WORK_DIR/rootfs/boot

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

popd 1> /dev/null # push ${LINUX}
popd 1> /dev/null # push ${WORK_DIR}

echo "RPI Kernel build finished."
