#!/usr/bin/env bash

SCRIPT_DIR=$(readlink -f $(dirname $0))

if [ $# != 1 ]; then
	echo "Usage: $0 path/to/firmware.hex/elf"
	exit 1
fi

FWHEX=$(readlink -f $1)

openocd -s $SCRIPT_DIR -f raspberrypi5-gpiod.cfg -f max32662.cfg \
	-c "init" \
	-c "targets" \
	-c "reset init" \
	-c "flash write_image erase $FWHEX" \
	-c "reset run" \
	-c "shutdown"

