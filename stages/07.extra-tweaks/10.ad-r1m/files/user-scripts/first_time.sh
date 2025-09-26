#!/usr/bin/env bash

echo "=== AD-R1M first-time setup ==="

sudo systemctl stop ros_app.service

echo
read -e -p "  * Connect to wifi? [yn] " choice
[[ "x$choice" == x[Yy]* ]] && sudo nmtui

echo
read -e -p "  * Docker login and pull latest container? [yn] " choice
[[ "x$choice" == x[Yy]* ]] && {
	echo "  ! If you don't know what credentials to enter here, contact us !"
	docker login docker.cloudsmith.io
	~/recreate_container.sh
}

echo
read -e -p "  * Bind CRSF transceiver and handset? [yn] " choice
[[ "x$choice" == x[Yy]* ]] && {
	gpioset 0 24=0; sleep 1
	gpioset 0 24=1; sleep 2; gpioset 0 24=0; sleep 0.5
	gpioset 0 24=1; sleep 2; gpioset 0 24=0; sleep 0.5
	gpioset 0 24=1; sleep 2; gpioset 0 24=0; sleep 0.5
	gpioset 0 24=1 

	echo "  Transceiver should be in bind mode and double-blinking"
	echo "  On your RC handset:"
	echo "    1. Go to the main screen (press RET a few times)"
	echo "    2. Navigate to SYS > ExpressLRS"
	echo "    3. Press the [Bind] menu button"
	echo
	echo "  After that, the transceiver should stop double-blinking and show a solid color."
}

echo
read -e -p "  * Flash ADRD4161 SLCAN firmware? [yn] " choice
[[ "x$choice" == x[Yy]* ]] && {
	/opt/adrd4161-fw/upload.sh /opt/adrd4161-fw/adrd4161_slcan.elf
}

echo
read -e -p "  * Set default motor control parameters? [yn] " choice
[[ "x$choice" == x[Yy]* ]] && {
	sudo ~/recan.sh
	cansend slcan0 000#8114
	cansend slcan0 000#8116
	/opt/adrd3161/param_tool.sh -i slcan0 -e /opt/adrd3161/adrd3161.eds 0x14 write /opt/adrd3161/qsh5718_basic.ini
	/opt/adrd3161/param_tool.sh -i slcan0 -e /opt/adrd3161/adrd3161.eds 0x16 write /opt/adrd3161/qsh5718_basic.ini
}

echo
echo "ALL DONE!"

