#!/bin/bash -e

on_chroot << EOF
pip3 install sense-emu
EOF

icon="sense_emu_gui.svg"
desktop_path="/home/${FIRST_USER_NAME}/.local/share/applications"
icon_path="$desktop_path/$icon"
command_to_run="sense_emu_gui"

cp "files/"$icon ${ROOTFS_DIR}/$desktop_path/.

cat <<EOF >>  ${ROOTFS_DIR}/$desktop_path/sense_emu_gui.desktop
[Desktop Entry]
Name=Sense HAT Emulator
Comment=GUI for controlling the emulated Sense HAT
Exec=$command_to_run
Icon=$icon_path
Terminal=false
Type=Application
Categories=Development
StartupNotify=true
EOF

