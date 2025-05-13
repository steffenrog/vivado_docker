FROM ubuntu:20.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    git \
    nano \
    vim \
    locales \
    ca-certificates \
    libglib2.0-0 \
    libsm6 \
    libxi6 \
    libxrender1 \
    libxrandr2 \
    libfreetype6 \
    libfontconfig1 \
    libxcursor1 \
    libxinerama1 \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    dbus-x11 \
    libusb-1.0-0 \
    libusb-0.1-4 \
    usbutils \
    xterm \
    firefox \
    libtinfo5 \
    libncurses5 \
    libc6-dev \
    build-essential \
    xorg \
    openbox \
    iproute2 \
    gawk \
    python3 \
    python3-pip \
    python3-pexpect \
    xz-utils \
    zlib1g-dev \
    net-tools \
    libtool \
    flex \
    bison \
    libssl-dev \
    libncurses5-dev \
    libstdc++6 \
    texinfo \
    gcc-multilib \
    g++-multilib \
    expect \
    dosfstools \
    u-boot-tools \
    device-tree-compiler \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create a non-root user with sudo access
RUN useradd -m -s /bin/bash xilinx && \
    echo "xilinx ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/xilinx && \
    chmod 0440 /etc/sudoers.d/xilinx

# Create installation directory
RUN mkdir -p /opt/Xilinx && \
    chown -R xilinx:xilinx /opt/Xilinx

USER xilinx
WORKDIR /home/xilinx

# Add script to run Xilinx installer
RUN echo '#!/bin/bash\n\
echo "Please run the Xilinx installer with:"\n\
echo "sudo ./xsetup -a XilinxEULA,3rdPartyEULA,WebTalkTerms -b AuthTokenGen -e"\n\
echo "or follow the interactive installer"\n\
' > /home/xilinx/run_installer.sh && chmod +x /home/xilinx/run_installer.sh

# Default environment setup for Xilinx tools
RUN echo 'source /opt/Xilinx/Vitis/2023.2/settings64.sh 2>/dev/null || echo "Xilinx tools not yet installed"' >> /home/xilinx/.bashrc

ENTRYPOINT ["/bin/bash"]