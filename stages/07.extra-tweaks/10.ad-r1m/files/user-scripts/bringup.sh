#!/usr/bin/env bash

pushd $(dirname $0)

docker compose down

# Morse code "B" for Bringup
flock /usr/local/bin/led-morse.sh /usr/local/bin/led-morse.sh "B" &

# Power on CRSF transceiver, if not already up
gpioset 0 24=1

# Reset all CANopen devices - sure way to halt drives and such
cansend can0 000#8100
sleep 0.1

# CAN reset
./recan.sh

# Set IMU frequency
iio_attr -u ip:localhost -d adis16470 sampling_frequency 200
systemctl restart iiod.service

docker compose up

