#!/usr/bin/env bash

pushd $(dirname $0)

docker compose down

# Power on CRSF transceiver, if not already up
gpioset 0 24=1

# Reset all CANopen devices - sure way to halt drives and such
cansend can0 000#8100 # Reset all CANopen devices
sleep 0.1

# CAN reset
./recan.sh

# Set IMU frequency
iio_attr -u ip:localhost -d adis16470 sampling_frequency 100
systemctl restart iiod.service

docker compose up

