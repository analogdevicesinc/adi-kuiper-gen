#!/bin/bash -e

cp -f files/wallpaper.png "${ROOTFS_DIR}/usr/share/rpd-wallpaper"
cp -f files/launch.png "${ROOTFS_DIR}/usr/share/raspberrypi-artwork"

on_chroot << EOF
sed -i 's+^wallpaper=.*$+wallpaper=/usr/share/rpd-wallpaper/wallpaper.png+g' /etc/xdg/pcmanfm/LXDE-pi/desktop-items-0.conf
sed -i 's+start-here+/usr/share/raspberrypi-artwork/launch.png+g' /etc/xdg/lxpanel/LXDE-pi/panels/panel

#disable screensaver
sed -i 's+@xscreensaver -no-splash+#@xscreensaver -no-splash+g' /etc/xdg/lxsession/LXDE-pi/autostart
echo "@xset s off" >> /etc/xdg/lxsession/LXDE-pi/autostart
echo "@xset -dpms" >> /etc/xdg/lxsession/LXDE-pi/autostart
EOF
