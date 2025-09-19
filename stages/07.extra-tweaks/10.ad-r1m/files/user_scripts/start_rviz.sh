#!/usr/bin/env bash

I=docker.cloudsmith.io/adi/adrd-common/ad-r1m:backpack_rpi5-4380b77
docker pull $I
export DISPLAY=:0
xhost +
docker run --rm -it --network host --ipc host --pid host -e DISPLAY --privileged --name rviz -v /home/analog/ros_data:/ros_data $I bash -c 'source install/setup.sh; rviz2 -d /ros_data/main.rviz'

