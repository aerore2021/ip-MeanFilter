#!/bin/bash

# MeanFilter Project Quick Start Script
# This script ensures clean project creation and build using separated TCL scripts
# Updated: 2025.7.15 - Using separated TCL scripts for better modularity

echo "=========================================="
echo "   MeanFilter Project Quick Start"
echo "=========================================="

# Parse command line arguments
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --help, -h         Show this help message"
    echo ""
    echo "This script uses separated TCL scripts for modular project creation and build."
    echo "Step 1: create_meanfilter_project.tcl - Creates the project"
    echo "Step 2: run_meanfilter_build.tcl - Builds the project (synthesis & simulation)"
    exit 0
fi

echo "Using separated TCL scripts for modular build process"

# Kill any existing Vivado processes
echo "Checking for existing Vivado processes..."
tasklist | grep vivado > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Found existing Vivado processes. Attempting to terminate..."
    taskkill /f /im vivado.exe > /dev/null 2>&1
    sleep 2
fi

# Clean up any existing project directory
if [ -d "MeanFilter_project" ]; then
    echo "Removing existing project directory..."
    rm -rf MeanFilter_project > /dev/null 2>&1
    sleep 1
fi

# Clean up log and journal files
echo "Cleaning up previous log and journal files..."
rm -f vivado*.log > /dev/null 2>&1
rm -f vivado*.jou > /dev/null 2>&1
rm -f *.log > /dev/null 2>&1
rm -f *.jou > /dev/null 2>&1
rm -f vivado_pid*.str > /dev/null 2>&1
rm -f vivado_pid*.debug > /dev/null 2>&1
rm -f .Xil > /dev/null 2>&1
rm -rf .Xil/ > /dev/null 2>&1
echo "Log and journal files cleaned."

# Create and build project using separated TCL scripts
echo "=========================================="
echo "Step 1: Creating MeanFilter project..."
echo "=========================================="
vivado -mode tcl -source create_meanfilter_project.tcl

if [ $? -eq 0 ]; then
    echo "=========================================="
    echo "Step 2: Building MeanFilter project..."
    echo "=========================================="
    vivado -mode tcl -source build.tcl
else
    echo "ERROR: Project creation failed!"
    exit 1
fi

echo "=========================================="
echo "Script execution completed!"
echo "=========================================="
