######################################################################
# DesignCompiler synthesis script
#
# EE577B Phase 4 - Cardinal Torus CMP
######################################################################

# Hardcoded for Phase 4 torus CMP
set design_name "cardinal_torus_cmp"

## For NCSUFreePDK45nm library
set search_path [ list . \
                  /tools/PDK/NCSU45PDK/FreePDK45/osu_soc/lib/files/ \
                  /tools/synopsys/syn/Y-2026.03/libraries/syn/ ]
set target_library { gscl45nm.db }
set synthetic_library [list /tools/synopsys/syn/Y-2026.03/libraries/syn/dw_foundation.sldb standard.sldb ]
set link_library [list * gscl45nm.db /tools/synopsys/syn/Y-2026.03/libraries/syn/dw_foundation.sldb standard.sldb]


# Reading source verilog file.
# in this version, you don't need to copy the verilog file into ./src/ before synthesis.
set rtl_dir ./design
set rtl_files [glob -nocomplain $rtl_dir/*.v]
if {[llength $rtl_files] == 0} {
    puts "ERROR: No RTL files found in $rtl_dir"
    exit 1
}
puts "Info: Found [llength $rtl_files] RTL files"

analyze -format verilog $rtl_files
analyze -format verilog ./include/imem.v
analyze -format verilog ./include/dmem.v

elaborate $design_name
current_design $design_name
set_dont_touch [find design -hierarchy imem*]
set_dont_touch [find design -hierarchy dmem*]


# Setting $design_name as current working design.
# Use this command before setting any constraints.
#current_design $design_name ;

# Note: uniquify is omitted for CMP due to large hierarchical structure.

# Linking your design into the cells in standard cell libraries.
# This command checks whether your design can be compiled
link ;

# Create a clock with period of 5.
create_clock -name clk -period 4 -waveform [list 0 2] [get_ports clk]

# Setting timing constraints for combinational logic.
# Specifying maximum delay from inputs to outputs
#set_max_delay 5.0 -to [all_outputs];
#set_max_delay 5.0 -from [all_inputs];

# "check_design" checks the internal representation of the
# current design for consistency and issues error and
# warning messages as appropriate.
check_design > report/$design_name.check_design ;

# Perforing synthesis and optimization on the current_design.
compile ;
# compile_ultra

# For better synthesis result, use "" command.
# compile_ultra is doing automatic ungrouping during optimization,
# therefore sometimes it's hard to figure out the critical path 
# from the synthesized netlist.
# So, use "compile" command for now.

# Writing the synthesis result into Synopsys db format.
# You can read the saved db file into DesignCompiler later using
# "read_db" command for further analysis (timing, area...).
# write -xg_force_db -format db -hierarchy -out db/$design_name.db ;

# Generating timing,area and power report of the synthezied design.
report_timing > report/$design_name.timing ;
report_area > report/$design_name.area ;
report_power > report/$design_name.power ;

# Writing synthesized gate-level verilog netlist.
# This verilog netlist will be used for post-synthesis gate-level simulation.
change_names -rules verilog -hierarchy ;
write -format verilog -hierarchy -out netlist/${design_name}_syn.v ;

# Writing Standard Delay Format (SDF) back-annotation file.
# This delay information can be used for post-synthesis simulation.
write_sdf netlist/${design_name}_syn.sdf;
write_sdc netlist/${design_name}_syn.sdc

exit