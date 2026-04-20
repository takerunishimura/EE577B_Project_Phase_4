set design_name "cardinal_torus_cmp"

set search_path [ list . \
                  /tools/PDK/NCSU45PDK/FreePDK45/osu_soc/lib/files/ \
                  /tools/synopsys/syn/Y-2026.03/libraries/syn/ ]
set target_library { gscl45nm.db }
set synthetic_library [list /tools/synopsys/syn/Y-2026.03/libraries/syn/dw_foundation.sldb standard.sldb]
set link_library [list * gscl45nm.db /tools/synopsys/syn/Y-2026.03/libraries/syn/dw_foundation.sldb standard.sldb]

read_file -format verilog -netlist netlist/${design_name}_syn.v
current_design $design_name
link

create_clock -name clk -period 4 -waveform [list 0 2] [get_ports clk]

report_timing > report/$design_name.timing
report_area   > report/$design_name.area
report_power  > report/$design_name.power

exit