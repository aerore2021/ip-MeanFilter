#!/bin/bash

# MeanFilter Project Quick Start Script
# This script ensures clean project creation

echo "=========================================="
echo "   MeanFilter Project Quick Start"
echo "=========================================="

# Kill any existing Vivado processes
echo "Checking for existing Vivado processes..."
tasklist | grep vivado > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Found existing Vivado processes. Attempting to terminate..."
    taskkill /f /im vivado.exe > /dev/null 2>&1
    sleep 2
fi

# Clean up any existing project directory
if [ -d "MeanFilter" ]; then
    echo "Removing existing project directory..."
    rm -rf MeanFilter > /dev/null 2>&1
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

# Create fresh project
echo "Creating MeanFilter project..."
vivado -mode tcl -source create_meanfilter_auto.tcl

echo "=========================================="
echo "Script execution completed!"
echo "=========================================="
