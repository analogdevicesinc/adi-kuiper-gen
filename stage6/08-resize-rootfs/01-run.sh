#!/bin/bash -e

install -m 755 files/extend-rootfs-once 	"${ROOTFS_DIR}/etc/init.d/"

on_chroot << EOF
systemctl enable extend-rootfs-once
EOF

