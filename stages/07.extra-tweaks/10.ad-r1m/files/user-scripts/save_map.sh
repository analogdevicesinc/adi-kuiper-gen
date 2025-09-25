#!/bin/bash

MAP_NAME=map
I=working
docker run --network=host --pid=host --ipc=host -it $I \
	ros2 service call /slam_toolbox/save_map slam_toolbox/srv/SaveMap "{name:{ data: '/ros_data/maps/$MAP_NAME'}}"

