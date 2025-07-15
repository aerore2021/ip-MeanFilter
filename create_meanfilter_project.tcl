# MeanFilter Project Creation Script
# Compatible with Vivado 2021.1 and above
# Usage: vivado -mode tcl -source create_meanfilter_project.tcl
# Author: GitHub Copilot
# Date: July 15, 2025

# Project configuration
set project_name "MeanFilter_project"
set project_dir "."
set fpga_part "xc7a100tcsg324-1"

# Delete existing project
if {[file exists "$project_dir/$project_name"]} {
    file delete -force "$project_dir/$project_name"
}

# Create new project
create_project $project_name $project_dir/$project_name -part $fpga_part
puts "INFO: Project '$project_name' created successfully"

# Add design files
add_files -norecurse {
    src/MeanFilter.sv
    src/LineBuf.sv
}

# Add simulation files
add_files -fileset sim_1 -norecurse {
    sim/tb_MF.sv
}

# Set file properties
set_property file_type SystemVerilog [get_files src/MeanFilter.sv]
set_property file_type SystemVerilog [get_files src/LineBuf.sv]
set_property file_type SystemVerilog [get_files sim/tb_MF.sv]

# Set top modules
set_property top MeanFilter [get_filesets sources_1]
set_property top tb_MF [get_filesets sim_1]
puts "INFO: Source files added successfully"

# Generate MeanFilter dedicated BRAM IP
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name BRAM_32x8192

# Configure BRAM parameters - Optimized for MeanFilter
set_property -dict [list \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.Write_Width_A {8} \
    CONFIG.Write_Depth_A {8192} \
    CONFIG.Read_Width_A {8} \
    CONFIG.Write_Width_B {8} \
    CONFIG.Read_Width_B {8} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Enable_B {Use_ENB_Pin} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
    CONFIG.Use_Byte_Write_Enable {false} \
    CONFIG.Byte_Size {9} \
    CONFIG.Assume_Synchronous_Clk {true} \
] [get_ips BRAM_32x8192]

puts "INFO: BRAM IP 'BRAM_32x8192' configured successfully"

# Generate IP - Wait for completion
puts "INFO: Generating BRAM IP files..."
generate_target all [get_ips BRAM_32x8192]
create_ip_run [get_ips BRAM_32x8192]
launch_runs BRAM_32x8192_synth_1
wait_on_run BRAM_32x8192_synth_1

# Check if IP generation was successful
if {[get_property PROGRESS [get_runs BRAM_32x8192_synth_1]] == "100%"} {
    puts "INFO: BRAM IP generation completed successfully"
} else {
    puts "ERROR: BRAM IP generation failed"
    puts "Status: [get_property STATUS [get_runs BRAM_32x8192_synth_1]]"
    exit 1
}

# Refresh the project to ensure IP files are recognized
update_compile_order -fileset sources_1
puts "INFO: IP generation and project refresh completed"

# Create constraints file
set constraints_content {# MeanFilter Project Clock Constraints
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

# Input/Output delay constraints
set_input_delay -clock clk -max 2.000 [get_ports {rst_n axis_in_*}]
set_output_delay -clock clk -max 2.000 [get_ports {axis_out_*}]

# Clock uncertainty
set_clock_uncertainty -setup 0.500 [get_clocks clk]
set_clock_uncertainty -hold 0.100 [get_clocks clk]
}

set constraints_file "$project_dir/$project_name.srcs/constrs_1/new/meanfilter_constraints.xdc"
set constraints_dir [file dirname $constraints_file]
file mkdir $constraints_dir

set fp [open $constraints_file w]
puts $fp $constraints_content
close $fp

add_files -fileset constrs_1 -norecurse $constraints_file
puts "INFO: Constraints file created successfully"

# Set synthesis strategy - Vivado 2021.1 compatible
set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]

# Update compile order - Ensure IP files are included
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Verify IP files are present
set ip_files [get_files -filter {FILE_TYPE == IP}]
if {[llength $ip_files] > 0} {
    puts "INFO: Found IP files: $ip_files"
} else {
    puts "WARNING: No IP files found in project"
}

puts "INFO: Project setup completed"

puts "=========================================="
puts "MeanFilter Project Created Successfully!"
puts "=========================================="
puts "Project is ready for synthesis and simulation."
puts "Run 'vivado -mode tcl -source run_meanfilter_build.tcl' to build the project."
puts "=========================================="

puts "Script execution completed."
