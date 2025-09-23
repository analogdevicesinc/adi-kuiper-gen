#!/bin/bash

MAP_NAME=map
I=working

(
# Make Ctrl-C work
trap 'kill 0' SIGINT

# Run AMCL localization
docker run --rm -v ./ros_data:/ros_data --network=host --ipc=host --pid=host $I \
        ros2 launch adrd_demo_ros2 localization_launch.py map:=/ros_data/maps/$MAP_NAME.yaml &

# Run nav2 stack
docker run --rm -v ./ros_data:/ros_data --network=host --ipc=host --pid=host $I \
	ros2 launch adrd_demo_ros2 navigation_launch.py params_file:=/ros_data/navigation_params.yaml &
)


