#!/bin/sh

modprobe slcan
killall slcand

# Reset MCU
gpioset 0 21=0
sleep 0.1
gpioset 0 21=1
sleep 0.1

# Start slcan daemon
slcand -F -o -c -f -s6 -S1000000 -t sw /dev/ttyAMA0 can0 &

sleep 1
ip link set can0 up

wait

