#!/usr/bin/env bash

pushd $(dirname $0)

docker compose down

# CAN reset:
# Reset all CANopen devices
cansend can0 000#8100 # Reset all CANopen devices
systemctl stop slcan.service # Stop slcan client
gpioset 0 24=0 # Power cycle slcan MCU
sleep 0.1
gpioset 0 24=1
systemctl start slcan.service
 
# Set IMU frequency
iio_attr -u ip:localhost -d adis16470 sampling_frequency 100

# Power cycle CRSF transceiver
gpioset 0 21=0
sleep 0.5
gpioset 0 21=1

systemctl restart iiod.service

docker compose up

