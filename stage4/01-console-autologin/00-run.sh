#!/bin/bash -e

install -m 644 files/serial-getty@.service "${ROOTFS_DIR}/lib/systemd/system/"

on_chroot << EOF
	SUDO_USER="${FIRST_USER_NAME}" raspi-config nonint do_boot_behaviour B4

	systemctl enable serial-getty@ttyPS0.service
	systemctl enable serial-getty@ttyS0.service
	sed -i '1s/^/auth sufficient pam_listfile.so item=tty sense=allow file=\/etc\/securetty onerr=fail apply=root\n/' "/etc/pam.d/login"

EOF
