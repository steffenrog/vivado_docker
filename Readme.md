./run.sh
tar -xf FPGAs_AdaptiveSoCs_Unified_2023.2_1013_2256.tar.gz -C installer
cd installer
./xsetup

source /opt/Xilinx/Vitis/2023.2/settings64.sh

source /opt/Xilinx/Vivado/2023.2/settings64.sh

cd /opt/Xilinx/Vivado/2023.2/data/xicom/cable_drivers/lin64/install_script/install_drivers/
sudo ./install_drivers