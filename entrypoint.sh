#!/bin/bash
# Container entrypoint script

# Source Xilinx environment if available
if [ -f "/home/xilinx/.xilinx_env.sh" ]; then
    source /home/xilinx/.xilinx_env.sh
fi

# Display welcome message
cat << EOL
=======================================================================
Xilinx Vivado + Vitis Development Environment
=======================================================================
This container includes:
* Xilinx Vivado and Vitis (requires installation using setup_xilinx.sh)
* RISC-V GCC Toolchain for MicroBlaze RISC-V development
* All dependencies for building Linux and applications for MPSoC
* Development tools and utilities

To install Xilinx tools:
1. Mount your Xilinx installer to the container
2. Run: ./setup_xilinx.sh /path/to/mounted/Xilinx_unified_installer.tar.gz

Your workspace is available at: /home/xilinx/workspace
=======================================================================
EOL

# Execute the command passed to docker run
exec "$@"