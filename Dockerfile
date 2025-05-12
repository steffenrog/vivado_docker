# Base image: Ubuntu 20.04
FROM ubuntu:20.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /opt

# Install dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    tar \
    unzip \
    git \
    make \
    gcc \
    g++ \
    build-essential \
    libncurses5-dev \
    libtinfo-dev \
    zlib1g-dev \
    libssl-dev \
    flex \
    bison \
    libselinux1 \
    gnupg \
    cpio \
    rsync \
    bc \
    libtool \
    automake \
    autoconf \
    device-tree-compiler \
    u-boot-tools \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-dev \
    python3-numpy \
    libgtk-3-0 \
    xvfb \
    net-tools \
    iproute2 \
    libglib2.0-0 \
    libtool \
    libsdl1.2-dev \
    kpartx \
    libyaml-dev \
    default-jre \
    libtinfo5 \
    libncurses5 \
    libudev-dev \
    libftdi-dev \
    gawk \
    texinfo \
    vim \
    nano \
    usbutils \
    locales \
    ca-certificates \
    lsb-release \
    xterm \
    screen \
    patchelf \
    libxrender1 \
    libxtst6 \
    libxi6 \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create a non-root user for running Xilinx tools
RUN useradd -m -s /bin/bash xilinx && \
    echo "xilinx ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create installation directories
RUN mkdir -p /opt/Xilinx /home/xilinx/workspace
RUN chown -R xilinx:xilinx /opt/Xilinx /home/xilinx/workspace

# Switch to non-root user
USER xilinx
WORKDIR /home/xilinx

# Set environment variables for Xilinx tools
ENV XILINX_VIVADO="/opt/Xilinx/Vivado/2023.2"
ENV XILINX_VITIS="/opt/Xilinx/Vitis/2023.2"
ENV XILINX_HLS="/opt/Xilinx/Vitis_HLS/2023.2"
ENV PATH="$PATH:$XILINX_VIVADO/bin:$XILINX_VITIS/bin:$XILINX_HLS/bin"

# Add a setup script for installing Xilinx tools
# Note: You need to manually download the Xilinx installer and mount it to the container
COPY --chown=xilinx:xilinx scripts/setup_xilinx.sh /home/xilinx/setup_xilinx.sh
RUN chmod +x /home/xilinx/setup_xilinx.sh

# Setup script for container startup
COPY --chown=xilinx:xilinx scripts/entrypoint.sh /home/xilinx/entrypoint.sh
RUN chmod +x /home/xilinx/entrypoint.sh

# Install RISC-V GCC toolchain for MicroBlaze RISC-V development
RUN mkdir -p /home/xilinx/riscv-tools && \
    cd /home/xilinx/riscv-tools && \
    wget https://static.dev.sifive.com/dev-tools/freedom-tools/v2020.12/riscv-gnu-toolchain-2021.01.0-x86_64-linux-ubuntu14.tar.gz && \
    tar -xzf riscv-gnu-toolchain-2021.01.0-x86_64-linux-ubuntu14.tar.gz && \
    rm riscv-gnu-toolchain-2021.01.0-x86_64-linux-ubuntu14.tar.gz

# Add RISC-V toolchain to PATH
ENV PATH="$PATH:/home/xilinx/riscv-tools/riscv-gnu-toolchain-2021.01.0-x86_64-linux-ubuntu14/bin"

# Setup Petalinux prerequisites
USER root
RUN apt-get update && apt-get install -y \
    tofrodos \
    iproute2 \
    gawk \
    xvfb \
    gcc-multilib \
    libsdl2-dev \
    && rm -rf /var/lib/apt/lists/*
USER xilinx

# Create workspace directory
RUN mkdir -p /home/xilinx/workspace/projects

# Set the entrypoint
ENTRYPOINT ["/home/xilinx/entrypoint.sh"]
CMD ["/bin/bash"]