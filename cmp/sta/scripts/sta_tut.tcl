#############################################################################
#
# EE577b Phase 4
#
# PrimeTime Static Timing Analysis script for Cardinal Torus CMP
# Adapted from sample script by Ehsan Pakbaznia
#
#############################################################################

remove_design -all
set_app_var search_path ". ./designs"
set_app_var link_path "* /tools/PDK/NCSU45PDK/FreePDK45/osu_soc/lib/files/gscl45nm.db"
set link_create_black_boxes true

# Reading the design
# synthesized verilog netlist output from Design Compiler
read_verilog designs/cardinal_torus_cmp_syn.v ;

# Link the design with the library
link_design cardinal_torus_cmp;

# Create clock for your design
# 4ns period (250 MHz) matching synthesis constraint
create_clock -period 4.0 -name CLK [get_ports clk];

# Set the clock latency
# per Phase 4 spec: clock_latency = 0.5ns
set_clock_latency 0.5 CLK;

# Set input/output delays per Phase 4 spec: input/output delays = 1ns
set_input_delay 1.0 -clock CLK [all_inputs];
set_output_delay 1.0 -clock CLK [all_outputs];

# Standard timing report
report_timing;

# Generate timing histogram report as required by spec
report_timing -max_paths 1000 -histogram -nosplit > timing_histogram.rpt