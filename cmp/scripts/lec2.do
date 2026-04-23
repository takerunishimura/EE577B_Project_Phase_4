reset
read library -verilog ./include/gscl45nm.v /tools/synopsys/syn/Y-2026.03/packages/gtech/src_ver/gtech_lib.v
set undefined cell black_box
read design -golden -verilog ./design/alu.v ./design/instr_decode.v ./design/reg_file.v ./design/sfu.v ./design/cardinal_cpu.v ./design/cardinal_nic.v ./design/input_ctrl.v ./design/output_ctrl.v ./design/gold_router.v ./design/torus_mesh.v ./design/cardinal_torus_cmp.v
read design -revised -verilog ./netlist/cardinal_torus_cmp_syn_modified.v
set system mode lec
add compared points -all
compare
report verification