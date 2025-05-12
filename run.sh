#!/bin/bash
# Script to help build and run the Xilinx Docker container

set -e

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function print_header() {
    echo -e "${GREEN}======================================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}======================================================${NC}"
}

function print_info() {
    echo -e "${YELLOW}INFO: $1${NC}"
}

function print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

function check_dependencies() {
    print_header "Checking dependencies"
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    print_info "Docker is installed. Good!"
    
    if ! command -v docker-compose &> /dev/null; then
        print_info "docker-compose not found. Using 'docker compose' instead."
        DOCKER_COMPOSE="docker compose"
    else
        DOCKER_COMPOSE="docker-compose"
        print_info "docker-compose is installed. Good!"
    fi
}

function create_directory_structure() {
    print_header "Creating directory structure"
    
    if [ ! -d "scripts" ]; then
        print_info "Creating scripts directory"
        mkdir -p scripts
    fi
    
    if [ ! -d "workspace" ]; then
        print_info "Creating workspace directory"
        mkdir -p workspace
    fi
    
    # Copy scripts to their correct locations
    if [ -f "setup_xilinx.sh" ]; then
        print_info "Moving setup_xilinx.sh to scripts directory"
        mv setup_xilinx.sh scripts/
        chmod +x scripts/setup_xilinx.sh
    fi
    
    if [ -f "entrypoint.sh" ]; then
        print_info "Moving entrypoint.sh to scripts directory"
        mv entrypoint.sh scripts/
        chmod +x scripts/entrypoint.sh
    fi
}

function build_container() {
    print_header "Building Docker container"
    print_info "This might take a while..."
    
    docker build -t xilinx-dev:2023.2 .
    
    if [ $? -eq 0 ]; then
        print_info "Container built successfully!"
    else
        print_error "Failed to build container"
        exit 1
    fi
}

function run_container() {
    print_header "Running Docker container"
    
    # Check if container already exists
    if docker ps -a | grep -q "xilinx-dev"; then
        print_info "Container already exists. Starting it..."
        docker start -i xilinx-dev
    else
        print_info "Starting new container..."
        $DOCKER_COMPOSE up -d
        docker attach xilinx-dev
    fi
}

function main() {
    print_header "Xilinx Vivado + Vitis Docker Setup"
    
    check_dependencies
    create_directory_structure
    
    # Check if the container image already exists
    if ! docker images | grep -q "xilinx-dev"; then
        build_container
    else
        print_info "Container image already exists. Skipping build."
    fi
    
    # Look for Xilinx installer
    if [ -z "$XILINX_INSTALLER" ]; then
        # Try to find installer in current directory
        INSTALLER=$(find . -maxdepth 1 -name "Xilinx_unified*.tar.gz" | head -1)
        if [ ! -z "$INSTALLER" ]; then
            print_info "Found Xilinx installer: $INSTALLER"
            # Update docker-compose.yml to use the found installer
            sed -i "s|# - /path/to/Xilinx_unified_2023.2.tar.gz:/tmp/Xilinx_unified_installer.tar.gz|- $(pwd)/$INSTALLER:/tmp/Xilinx_unified_installer.tar.gz|" docker-compose.yml
        else
            print_info "No Xilinx installer found. You'll need to install Xilinx tools manually."
        fi
    fi
    
    # Enable X11 forwarding
    if [ -n "$DISPLAY" ]; then
        print_info "Enabling X11 forwarding"
        xhost +local:docker || print_info "Could not set xhost permissions. GUI might not work."
    fi
    
    run_container
}

# Run main function
main "$@"