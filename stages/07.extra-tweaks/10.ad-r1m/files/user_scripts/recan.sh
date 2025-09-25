#!/bin/bash
#
# recan: (Re)initialize CAN bus adapters
# 
# Copyright (c) 2025 Analog Devices, Inc.

killall slcand

# Power cycle SLCAN MCU. With the latest firmware, this shouldn't be necessary,
# but while developing the SLCAN FW this was useful for when it hung.
gpioset 0 21=0
sleep 0.1
gpioset 0 21=1
sleep 0.5

# Start slcan daemon and activate interface
slcand -o -c -f -t hw -s 6 -S 2000000 /dev/ttyCAN slcan0
ip link set slcan0 up

# If an external CAN adapter is present, uncomment the following to start it up as well
#ip link set can0 down
#ip link set can0 type can bitrate 500000
#ip link set can0 up

