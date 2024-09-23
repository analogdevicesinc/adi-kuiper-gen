#!/bin/bash

mkdir /lib/firmware
apt install -y dhcpcd5
echo -e "\ninterface usb0\nrequire dhcp" >> /etc/dhcpcd.conf
echo -e "\n[keyfile]\nunmanaged-devices=interface-name:usb0" >> /etc/NetworkManager/NetworkManager.conf
systemctl enable dhcpcd

# copy eval support files to embedded system and enable systemd-service (step 3)
# git setup
git clone --no-checkout --filter=blob:none https://bitbucket.analog.com/scm/pcts/misc_linux_tools.git
(
    cd misc_linux_tools
    git sparse-checkout init --cone
    git sparse-checkout set eval/lrc_carrier_scripts/
    git checkout master
)
mv ./misc_linux_tools/eval/lrc_carrier_scripts/root/eval /root/
install -m 644 ./misc_linux_tools/eval/lrc_carrier_scripts/etc/systemd/system/disable-ipv6-usb0.service /etc/systemd/system/
install -m 644 ./misc_linux_tools/eval/lrc_carrier_scripts/etc/systemd/system/evb_overlay.service /etc/systemd/system/
mv /root/eval/iio_rndis.scheme /usr/local/etc/gt/adi/
chmod +x /root/eval/bin/*

# enable RNDIS Gadget (step 2)
sed -i 's/GT_DEFAULT_SCHEME=.*/GT_DEFAULT_SCHEME=\/usr\/local\/etc\/gt\/adi\/iio_rndis.scheme/' /etc/default/usb_gadget
systemctl disable iiod_ffs.service
systemctl disable dev-iio_ffs.mount
sed -i 's/^Description=.*/Description=Start USB gadget scheme/; s/^After=.*/After=systemd-udev-settle.service/; /^Requires/d; s/^ExecStartPre=.*/ExecStartPre=\/bin\/sleep 5/' /etc/systemd/system/gt-start.service
sed -i 's/^Before=.*/Before=iiod.service/' /etc/systemd/system/iiod_context_attr.service

install -m 644 "${BASH_SOURCE%%/extra-ace-setup.sh}"/set-usb0-up.service /etc/systemd/system/
systemctl enable set-usb0-up
systemctl enable evb_overlay
systemctl enable disable-ipv6-usb0
rm -r ./misc_linux_tools

#step 6 create a service that needs to add a session-id
#example in 04 config-desk-env
#step 7 integrate in service
install -m 644 "${BASH_SOURCE%%/extra-ace-setup.sh}"/ace-config.service /etc/systemd/system/
install -m 755 "${BASH_SOURCE%%/extra-ace-setup.sh}"/adi-ace-config.sh /usr/bin/
systemctl enable ace-config

# fix IIOD script for sysid (step 8)
sed -i '/^SYSID=\$(sanitize_str/ s/head -1/tail -1/' /usr/local/bin/iiod_context.sh

# reduce stop-timeout fro iiod process (step 10)
sed -i "/^\[Service\]/a ExecStartPre=\/bin\/sh -c 'echo \"Timeout for IIOD changed to 5 seconds\" | logger -t IIOD'\nTimeoutStopSec=5" /lib/systemd/system/iiod.service

# reset hw_session_id in context
sed -i '/hw_session_id/d' $(which iiod_context.sh)
