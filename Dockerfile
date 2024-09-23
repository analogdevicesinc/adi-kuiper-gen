ARG BASE_IMAGE=debian:11.9
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
        git vim parted \
        quilt coreutils qemu-user-static debootstrap zerofree zip dosfstools \
        libarchive-tools libcap2-bin rsync grep udev xz-utils curl xxd file kmod bc\
	bison flex libssl-dev  build-essential libgtk-3-dev gcc-arm-linux-gnueabihf \
        u-boot-tools gcc-aarch64-linux-gnu \
        binfmt-support ca-certificates qemu-utils kpartx fdisk gpg pigz\
    && rm -rf /var/lib/apt/lists/*

COPY . /pi-gen/

VOLUME [ "/pi-gen/work", "/pi-gen/deploy"]
