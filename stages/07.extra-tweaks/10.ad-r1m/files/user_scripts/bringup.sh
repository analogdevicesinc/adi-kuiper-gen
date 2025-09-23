#!/usr/bin/env bash

pushd $(dirname $0)

docker compose down

# Power on CRSF transceiver
gpioset 0 21=1

# (Re)start slcan
./can_setup.sh
 
# Set IMU frequency
iio_attr -u ip:localhost -d adis16470 sampling_frequency 100

# Restart IIOD
systemctl restart iiod.service

docker compose up

