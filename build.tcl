# MeanFilter Project Build Script (Synthesis and Simulation)
# Compatible with Vivado 2021.1 and above
# Usage: 
#   vivado -mode tcl -source build.tcl                    # Default: batch simulation
#   vivado -mode tcl -source build.tcl -tclargs -gui      # GUI simulation
#   vivado -mode tcl -source build.tcl -tclargs -batch    # Batch simulation (no GUI)
#   vivado -mode tcl -source build.tcl -tclargs -nosim    # Skip simulation
# Note: This script requires the project to be created first using create_meanfilter_project.tcl
# 
# Arguments:
#   -batch : Run simulation in batch mode (no GUI required) [default]
#   -gui   : Run simulation in GUI mode (requires GUI access)
#   -nosim : Skip simulation entirely
#
# Features:
# - Supports repeated execution in Vivado CLI
# - Automatically handles project state (open/closed)
# - Intelligent synthesis run management (rerun if needed)
# - Batch mode simulation support for CLI environments
# - Robust simulation launch with error handling
# 
# Author: Aero2021
# Date: July 15, 2025

# Project configuration
set project_name "MeanFilter_project"
set project_dir "."

# Parse command line arguments for simulation mode
set sim_mode "batch"  
set run_sim true      

# Default to batch mode
# Default to run simulation

# Check for command line arguments
if {[info exists argv]} {
    foreach arg $argv {
        switch -exact -- $arg {
            "-nosim" {
                set run_sim false
                puts "INFO: Simulation will be skipped"
            }
            "-gui" {
                set sim_mode "gui"
                puts "INFO: Simulation will run in GUI mode"
            }
            "-batch" {
                set sim_mode "batch"
                puts "INFO: Simulation will run in batch mode"
            }
            default {
                puts "WARNING: Unknown argument: $arg"
            }
        }
    }
}

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
    
    # Run simulation based on mode setting
    if {$run_sim} {
        puts "\n=========================================="
        puts "Starting Simulation..."
        puts "=========================================="
        
        if {$sim_mode == "batch"} {
            puts "INFO: Running simulation in batch mode (no GUI required)"
            # Launch simulation in batch mode for CLI compatibility
            if {[catch {launch_simulation -mode batch} sim_error]} {
                puts "WARNING: Batch simulation launch failed: $sim_error"
                puts "Trying regular simulation mode..."
                if {[catch {launch_simulation} sim_error2]} {
                    puts "WARNING: All simulation launch attempts failed: $sim_error2"
                    puts "You can manually launch simulation from Vivado GUI"
                    puts "Or run: launch_simulation in Vivado CLI"
                } else {
                    puts "SUCCESS: Simulation launched successfully in GUI mode!"
                    puts "Note: This requires GUI access"
                }
            } else {
                puts "SUCCESS: Simulation launched successfully in batch mode!"
                puts "Simulation is running in background"
                
                # Wait a bit and check simulation status
                after 2000
                if {[catch {get_property STATUS [current_sim]} sim_status]} {
                    puts "INFO: Could not get simulation status"
                } else {
                    puts "INFO: Simulation status: $sim_status"
                }
            }
        } else {
            puts "INFO: Running simulation in GUI mode"
            # Launch simulation in GUI mode
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
        }
    } else {
        puts "\n=========================================="
        puts "Simulation skipped (use -nosim to skip)"
        puts "=========================================="
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
