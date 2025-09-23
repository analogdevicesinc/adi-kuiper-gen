#!/usr/bin/env bash

pushd $(dirname $0)

docker compose down

# (Re)start slcan
./can_setup.sh
 
# Set IMU frequency
iio_attr -u ip:localhost -d adis16470 sampling_frequency 100

# Power cycle CRSF transceiver
gpioset 0 21=0
sleep 0.5
gpioset 0 21=1

systemctl restart iiod.service

docker compose up

