#!/bin/bash

# Build the Docker image
sudo docker build -t xilinx-tools:2023.2 .

# Create a directory for the Xilinx installation files
mkdir -p xilinx_data

# Get current user and group IDs
USER_ID=$(id -u)
GROUP_ID=$(id -g)

# Run the Docker container
sudo docker run -it --rm \
  --privileged \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $PWD/FPGAs_AdaptiveSoCs_Unified_2023.2_1013_2256.tar.gz:/home/xilinx/FPGAs_AdaptiveSoCs_Unified_2023.2_1013_2256.tar.gz \
  -v $PWD/xilinx_data:/opt/Xilinx \
  --device-cgroup-rule='c 189:* rmw' \
  -v /dev/bus/usb:/dev/bus/usb \
  --net=host \
  --name xilinx-docker \
  xilinx-tools:2023.2