#!/bin/bash

I=working
docker run --rm -v ./ros_data:/ros_data --network=host --ipc=host --pid=host $I \
	ros2 launch adrd_demo_ros2 online_async_launch.py params_file:=/ros_data/mapping_params.yaml

