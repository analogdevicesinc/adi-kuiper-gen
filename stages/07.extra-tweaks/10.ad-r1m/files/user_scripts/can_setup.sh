#!/bin/bash

# Reset all CANopen devices
cansend slcan0 000#8100

# Stop slcan daemon
sleep 0.1
killall slcand

# Power cycle MCU
gpioset 0 21=0
sleep 0.1
gpioset 0 21=1

# Start slcan daemon
sleep 0.1
slcand -o -c -f -t hw -s 6 -S 2000000 /dev/ttyCAN slcan0
ip link set slcan0 up

# Initialize gs_can device
# ip l set can0 type can bitrate 500000
# ip l set can0 up

