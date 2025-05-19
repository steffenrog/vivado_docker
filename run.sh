#!/bin/bash

# Build the Docker image
sudo docker build -t xilinx-tools:2023.2 .

# Create directories for the Xilinx installation and your projects
mkdir -p xilinx_data
mkdir -p xilinx_projects

# Ensure host directories have proper permissions
sudo chown -R $(id -u):$(id -g) xilinx_data
sudo chown -R $(id -u):$(id -g) xilinx_projects

# Run the Docker container with additional capabilities and settings for PetaLinux
sudo docker run -it --rm \
  --privileged \
  --security-opt seccomp=unconfined \
  --cap-add=SYS_ADMIN \
  --cap-add=NET_ADMIN \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $PWD/FPGAs_AdaptiveSoCs_Unified_2023.2_1013_2256.tar.gz:/home/xilinx/FPGAs_AdaptiveSoCs_Unified_2023.2_1013_2256.tar.gz \
  -v $PWD/xilinx_data:/opt/Xilinx \
  -v $PWD/xilinx_projects:/home/xilinx/projects \
  --device-cgroup-rule='c 189:* rmw' \
  -v /dev/bus/usb:/dev/bus/usb \
  --net=host \
  --name xilinx-docker \
  xilinx-tools:2023.2 \
  -c "sudo chown -R xilinx:xilinx /opt/Xilinx && sudo chown -R xilinx:xilinx /home/xilinx/projects && exec /bin/bash"