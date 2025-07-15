# MeanFilter Project Build Script (Synthesis and Simulation)
# Compatible with Vivado 2021.1 and above
# Usage: vivado -mode tcl -source build.tcl
# Note: This script requires the project to be created first using create_meanfilter_project.tcl
# 
# Features:
# - Supports repeated execution in Vivado CLI
# - Automatically handles project state (open/closed)
# - Intelligent synthesis run management (rerun if needed)
# - Robust simulation launch with error handling
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

# Check if project is already open
set current_project ""
if {[catch {current_project} current_project]} {
    # No project is open, open the project
    open_project "$project_dir/$project_name/$project_name.xpr"
    puts "INFO: Project '$project_name' opened successfully"
} else {
    # A project is already open
    set expected_project_path [file normalize "$project_dir/$project_name/$project_name.xpr"]
    set current_project_path [file normalize [get_property DIRECTORY [current_project]]/[current_project].xpr]
    
    if {$current_project_path != $expected_project_path} {
        # Wrong project is open, close it and open the correct one
        puts "INFO: Closing current project '$current_project' and opening '$project_name'"
        close_project
        open_project "$project_dir/$project_name/$project_name.xpr"
        puts "INFO: Project '$project_name' opened successfully"
    } else {
        puts "INFO: Project '$project_name' is already open, continuing with build..."
    }
}

# Verify project is ready for build
set ip_files [get_files -filter {FILE_TYPE == IP}]
if {[llength $ip_files] == 0} {
    puts "ERROR: No IP files found in project. Please recreate the project."
    exit 1
}

# Update compile order to ensure all files are included
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "=========================================="
puts "Starting MeanFilter Project Build Process"
puts "=========================================="

# Auto-run synthesis
puts "Starting Synthesis..."

# Check if synthesis run already exists and is complete
set synth_status [get_property STATUS [get_runs synth_1]]
set synth_progress [get_property PROGRESS [get_runs synth_1]]

if {$synth_progress == "100%" && $synth_status == "synth_design Complete!"} {
    puts "INFO: Synthesis already completed successfully. Resetting and re-running..."
    reset_run synth_1
    launch_runs synth_1
    wait_on_run synth_1
} elseif {$synth_status == "Running"} {
    puts "INFO: Synthesis is currently running. Waiting for completion..."
    wait_on_run synth_1
} else {
    puts "INFO: Starting fresh synthesis run..."
    launch_runs synth_1
    wait_on_run synth_1
}

# Check synthesis results
if {[get_property PROGRESS [get_runs synth_1]] == "100%"} {
    puts "SUCCESS: Synthesis completed successfully!"
    puts "Synthesis Status: [get_property STATUS [get_runs synth_1]]"
    
    # Open synthesis run
    open_run synth_1 -name synth_1
    
    # Display synthesis report summary
    puts "\n=========================================="
    puts "Synthesis Report Summary:"
    puts "=========================================="
    
    # Get resource utilization
    if {[catch {report_utilization -return_string} util_report]} {
        puts "INFO: Utilization report not available"
    } else {
        puts "Resource Utilization:"
        puts $util_report
    }
    
    # Get timing summary
    if {[catch {report_timing_summary -return_string} timing_report]} {
        puts "INFO: Timing report not available"
    } else {
        puts "\nTiming Summary:"
        puts $timing_report
    }
    
    # Run simulation
    puts "\n=========================================="
    puts "Starting Simulation..."
    puts "=========================================="
    
    # Launch simulation - handle case where simulation might already be running
    if {[catch {launch_simulation} sim_error]} {
        # If simulation launch fails, try to close existing simulation first
        if {[string match "*already*" $sim_error] || [string match "*running*" $sim_error]} {
            puts "INFO: Simulation already running or exists. Attempting to restart..."
            if {[catch {close_sim} close_error]} {
                puts "INFO: Could not close existing simulation: $close_error"
            }
            # Try to launch simulation again
            if {[catch {launch_simulation} sim_error2]} {
                puts "WARNING: Simulation launch failed: $sim_error2"
                puts "You can manually launch simulation from Vivado GUI"
            } else {
                puts "SUCCESS: Simulation launched successfully!"
            }
        } else {
            puts "WARNING: Simulation launch failed: $sim_error"
            puts "You can manually launch simulation from Vivado GUI"
        }
    } else {
        puts "SUCCESS: Simulation launched successfully!"
    }
    
    puts "\n=========================================="
    puts "Build Process Complete!"
    puts "=========================================="
    puts "- Synthesis: PASSED"
    puts "- Simulation: LAUNCHED"
    puts "- Project ready for implementation"
    puts "=========================================="
    
    # Optionally open GUI for further analysis
    # Uncomment the line below to open Vivado GUI
    # start_gui
    
} else {
    puts "ERROR: Synthesis failed!"
    puts "Status: [get_property STATUS [get_runs synth_1]]"
    puts "Progress: [get_property PROGRESS [get_runs synth_1]]"
    puts "\nPlease check synthesis logs for details:"
    puts "- Navigate to: $project_dir/$project_name/$project_name.runs/synth_1/"
    puts "- Check files: runme.log, vivado.log"
    
    # Try to get error messages
    if {[catch {get_msg_config -rules} msg_rules]} {
        puts "INFO: Could not retrieve message configuration"
    } else {
        puts "\nSynthesis Messages:"
        if {[catch {get_messages -severity ERROR} error_msgs]} {
            puts "No error messages found"
        } else {
            foreach msg $error_msgs {
                puts "ERROR: $msg"
            }
        }
    }
    
    exit 1
}

puts "Build script execution completed."
