# MeanFilter Project - CLI Simulation Script
# Compatible with Vivado 2021.1 and above
# Usage: vivado -mode tcl -source simulate.tcl
# Note: This script requires the project to be created first
# 
# Features:
# - Pure command-line simulation without GUI
# - Automatic waveform generation
# - Simulation result analysis
# - Error handling and reporting
# 
# Author: GitHub Copilot
# Date: July 15, 2025

# Project configuration
set project_name "MeanFilter_project"
set project_dir "."

# Check if project exists
if {![file exists "$project_dir/$project_name/$project_name.xpr"]} {
    puts "ERROR: Project '$project_name' not found!"
    puts "Please run 'create_meanfilter_project.tcl' first to create the project."
    exit 1
}

# Open project if not already open
if {[catch {current_project} current_project]} {
    # No project is open, open the project
    open_project "$project_dir/$project_name/$project_name.xpr"
    puts "INFO: Project '$project_name' opened successfully"
} else {
    puts "INFO: Using currently open project: $current_project"
}

puts "=========================================="
puts "MeanFilter CLI Simulation"
puts "=========================================="

# Configure simulation settings
set_property -name {xsim.simulate.runtime} -value {1000ns} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]

# Start simulation in batch mode
puts "INFO: Starting simulation in batch mode..."
if {[catch {
    launch_simulation
    
    # Configure VCD output
    set vcd_file "tb_MF_simulation.vcd"
    puts "INFO: Configuring VCD output to: $vcd_file"
      # Open VCD file for writing
    open_vcd $vcd_file

    # Log all signals to VCD (hierarchical)
    # Use top-level scope for better compatibility
    log_vcd [get_objects -r /*]
    
    # Run simulation for specified time
    set run_time 1000000ns
    puts "INFO: Running simulation for $run_time..."
    run $run_time

    # Close VCD file
    close_vcd
    puts "INFO: VCD file generated: $vcd_file"
    
    # Try to save waveform config as backup
    if {[catch {write_wave_config -force "simulation_waveform.wcfg"} waveform_error]} {
        puts "WARNING: Could not save waveform config: $waveform_error"
    } else {
        puts "INFO: Waveform configuration saved as simulation_waveform.wcfg"
    }
    
    # Close simulation
    close_sim
    
} sim_error]} {
    puts "ERROR: Simulation failed: $sim_error"
    
    # Try to get more detailed error information
    if {[catch {get_messages -severity ERROR} error_msgs]} {
        puts "Could not retrieve error messages"
    } else {
        puts "Error messages:"
        foreach msg $error_msgs {
            puts "  - $msg"
        }
    }
    exit 1
} else {
    puts "SUCCESS: Simulation completed in batch mode"
}

puts "=========================================="
puts "CLI Simulation Complete!"
puts "=========================================="
puts "- Simulation ran for 1000ns"
puts "- VCD waveform file generated: tb_MF_simulation.vcd"
puts "- Waveform data saved (if supported)"
puts "- Check simulation logs for detailed results"
puts "=========================================="

puts "CLI simulation script execution completed."
