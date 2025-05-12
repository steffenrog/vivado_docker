# Xilinx Vivado + Vitis Docker Container

This Docker container provides a complete development environment for Xilinx FPGA designs, specifically targeted for MPSoC and MicroBlaze RISC-V development. It includes all necessary tools and dependencies for hardware design, Linux development, and application building.

## Features

- Ubuntu 20.04 base system
- Support for Xilinx Vivado and Vitis 2023.2
- RISC-V GCC toolchain for MicroBlaze RISC-V development
- All dependencies for PetaLinux and embedded Linux development
- Prepared environment for MPSoC development
- Non-root user setup for better security

## Prerequisites

1. Install Docker on your host system
2. Download the Xilinx Unified Installer (2023.2 or your preferred version) from the [Xilinx website](https://www.xilinx.com/support/download.html) (requires login)
3. At least 100GB of free disk space (Xilinx tools require significant space)
4. At least 16GB of RAM recommended

## Directory Structure

```
xilinx-docker/
├── Dockerfile
├── scripts/
│   ├── setup_xilinx.sh
│   └── entrypoint.sh
└── README.md
```

## Building the Docker Image

1. Create the directory structure as shown above and copy the files from this repository.

2. Build the Docker image:
```bash
cd xilinx-docker
mkdir -p scripts
# Copy setup_xilinx.sh and entrypoint.sh to scripts/ directory
docker build -t xilinx-dev:2023.2 .
```

## Running the Container

### First Run (Without Xilinx Tools)

```bash
docker run -it --name xilinx-dev \
  -v /path/to/your/workspace:/home/xilinx/workspace \
  xilinx-dev:2023.2
```

### Running with Xilinx Installer

```bash
docker run -it --name xilinx-dev \
  -v /path/to/your/workspace:/home/xilinx/workspace \
  -v /path/to/Xilinx_unified_2023.2.tar.gz:/tmp/Xilinx_unified_installer.tar.gz \
  xilinx-dev:2023.2
```

Once inside the container, install Xilinx tools:
```bash
./setup_xilinx.sh /tmp/Xilinx_unified_installer.tar.gz
```

### Resuming an Existing Container

```bash
docker start -i xilinx-dev
```

### Running with USB Device Support (for JTAG)

To use hardware JTAG devices, you need to run the container with USB device access:

```bash
docker run -it --name xilinx-dev \
  --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -v /path/to/your/workspace:/home/xilinx/workspace \
  xilinx-dev:2023.2
```

### Running with X11 Support (for GUI)

To run Vivado/Vitis GUI applications:

```bash
docker run -it --name xilinx-dev \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $HOME/.Xauthority:/home/xilinx/.Xauthority \
  -v /path/to/your/workspace:/home/xilinx/workspace \
  xilinx-dev:2023.2
```

On the host, you need to allow X11 connections:
```bash
xhost +local:docker
```

## Working with MPSoC and MicroBlaze RISC-V

### MPSoC Development

1. Create a new Vivado project for your Zynq UltraScale+ MPSoC board
2. Design your hardware and export it to Vitis
3. Create a Vitis platform project and application
4. Build PetaLinux for your design

Example workflow:
```bash
cd workspace
vivado &  # Launch Vivado GUI to create MPSoC design
# After exporting hardware:
vitis &   # Launch Vitis to create software projects
```

### MicroBlaze RISC-V Development

1. Create a Vivado design with MicroBlaze RISC-V processor
2. Export the hardware to Vitis
3. Use the included RISC-V toolchain for compilation:
```bash
riscv64-unknown-elf-gcc -o my_program my_program.c
```

## Building Linux for MPSoC

For PetaLinux development, you'll need to install PetaLinux separately within the container. The Dockerfile includes all the required dependencies.

## License

This Docker setup is provided under the MIT License. Note that you'll need to comply with Xilinx's licensing terms when using their tools.

## Notes

- The Xilinx tools require a significant amount of disk space (80GB+)
- Building the container and installing tools may take a considerable amount of time
- You'll need a valid Xilinx account and license to download and use the tools
