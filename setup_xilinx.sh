#!/bin/bash
# This script helps with installing Xilinx tools inside the Docker container
# You need to download the installer manually and mount it to the container
# Usage: ./setup_xilinx.sh /path/to/Xilinx_unified_2023.2_*.tar.gz

set -e

INSTALLER_PATH=$1

if [ -z "$INSTALLER_PATH" ]; then
    echo "Error: Please provide the path to the Xilinx installer tar.gz file"
    echo "Usage: ./setup_xilinx.sh /path/to/Xilinx_unified_2023.2_*.tar.gz"
    exit 1
fi

if [ ! -f "$INSTALLER_PATH" ]; then
    echo "Error: Installer file not found at $INSTALLER_PATH"
    exit 1
fi

# Extract the installer
echo "Extracting Xilinx installer..."
mkdir -p /tmp/xilinx_installer
tar -xzf "$INSTALLER_PATH" -C /tmp/xilinx_installer
cd /tmp/xilinx_installer

# Create installation config file for unattended installation
cat > /tmp/xilinx_installer/install_config.txt << EOL
#### Vivado ML Standard Edition Install Configuration ####
Edition=Vitis Unified Software Platform
Product=Vitis
Version=2023.2
Destination=/opt/Xilinx
Modules=Zynq UltraScale+ MPSoC:1,DocNav:1,Vitis Model Composer:1,Install devices for Alveo and Xilinx edge acceleration platforms:1,Vitis Networking P4:1,Versal AI Core Series ES1:1,Zynq-7000:1,Engineering Sample:1,Versal Prime Series ES1:1,System Generator for DSP:1,Kria KV260 Vision AI Starter Kit:1,Virtex UltraScale+ HBM ES:1
InstallOptions=Acquire or Manage a License Key:0
EOL

# Run the installer silently
echo "Running Xilinx installer (this might take a while)..."
cd /tmp/xilinx_installer
./xsetup --batch Install --config /tmp/xilinx_installer/install_config.txt --agree XilinxEULA,3rdPartyEULA

# Clean up
echo "Cleaning up installation files..."
rm -rf /tmp/xilinx_installer

# Setup cable drivers
echo "Setting up cable drivers..."
cd /opt/Xilinx/Vivado/2023.2/data/xicom/cable_drivers/lin64/install_script/install_drivers
sudo ./install_drivers

# Create a settings script for easy sourcing in future sessions
cat > /home/xilinx/.xilinx_env.sh << EOL
#!/bin/bash
export XILINX_VIVADO="/opt/Xilinx/Vivado/2023.2"
export XILINX_VITIS="/opt/Xilinx/Vitis/2023.2"
export XILINX_HLS="/opt/Xilinx/Vitis_HLS/2023.2"
export PATH="\$PATH:\$XILINX_VIVADO/bin:\$XILINX_VITIS/bin:\$XILINX_HLS/bin"
export LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:\$XILINX_VIVADO/lib/lnx64.o:\$XILINX_HLS/lib/lnx64.o"
EOL

chmod +x /home/xilinx/.xilinx_env.sh

# Add source command to .bashrc
echo "source /home/xilinx/.xilinx_env.sh" >> /home/xilinx/.bashrc

echo "Installation complete. Xilinx tools are installed in /opt/Xilinx"
echo "Please restart the container or run 'source /home/xilinx/.xilinx_env.sh' to set up the environment"