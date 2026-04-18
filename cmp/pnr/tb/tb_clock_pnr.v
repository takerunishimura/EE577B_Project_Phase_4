`include "./include/gscl45nm.v"
module tb_clock_pnr;
reg clk;
reg rst;
wire out_clk;

frequency_divider_by3 freq1(clk,rst,out_clk);
initial
	clk = 1'b0;
always
	#2.5 clk = ~clk;
initial begin
	$dumpfile("test.vcd");
	$dumpvars(0, freq1);
	$monitor($time,"clk = %b,rst = %b,out_clk = %b",clk,rst,out_clk);
	rst =0;
	#5 rst =1;
	#50 $finish;
end
initial begin
	$sdf_annotate("./netlist/frequency_divider_by3_pnr.sdf", freq1,,"sdf.log","MAXIMUM","1.0:1.0:1.0", "FROM_MAXIMUM");
	$enable_warnings;
	$log("ncsim.log");
end
endmodule
