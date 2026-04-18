`timescale 1ns/10ps

// ============================================================
// tb_cardinal_torus_cmp.v
// Testbench for 16-core Cardinal Chip Multiprocessor
//
// Test pattern: All-to-all communication
//   Each of 16 nodes sends 1 packet to each of the other 15
//   nodes (240 packets total).
//
// Memory layout per node:
//   MEM[0..14]  = 15 outgoing packets (pre-loaded)
//   MEM[15]     = 0x0000000000000000 sentinel
//   MEM[16..30] = 15 incoming packets stored by recv loop
//   MEM[31]     = 0x0000000000000000
//
// Packet header (big-endian bit[0]=MSB):
//   bit[0]     = vc
//   bit[1]     = dirX
//   bit[2]     = dirY
//   bit[3:7]   = reserved
//   bit[8:11]  = hopX
//   bit[12:15] = hopY
//   bit[16:23] = sourceX (col of sender)
//   bit[24:31] = sourceY (row of sender)
//   bit[32:63] = payload
// ============================================================

`define CYCLE_TIME 4

module tb_cardinal_torus_cmp;

// ============================================================
// Clock and Reset
// ============================================================
reg clk, reset;

always #2 clk = ~clk;

// ============================================================
// DUT instantiation
// ============================================================
cardinal_torus_cmp CMP (
    .clk(clk),
    .reset(reset)
);

integer completion_time_ns;
integer all_done;

// ============================================================
// Completion detector - latches time when all 240 slots filled
// ============================================================
always @(posedge clk) begin
    if (!reset && !all_done) begin : check_done
        integer cnt;
        integer m;
        cnt = 0;
        for (m = 16; m <= 30; m = m + 1) begin
            if (tb_cardinal_torus_cmp.CMP.DMEM_00.MEM[m] !== 64'd0) cnt = cnt + 1;
            if (tb_cardinal_torus_cmp.CMP.DMEM_01.MEM[m] !== 64'd0) cnt = cnt + 1;
            if (tb_cardinal_torus_cmp.CMP.DMEM_02.MEM[m] !== 64'd0) cnt = cnt + 1;
            if (tb_cardinal_torus_cmp.CMP.DMEM_03.MEM[m] !== 64'd0) cnt = cnt + 1;
            if (tb_cardinal_torus_cmp.CMP.DMEM_10.MEM[m] !== 64'd0) cnt = cnt + 1;
            if (tb_cardinal_torus_cmp.CMP.DMEM_11.MEM[m] !== 64'd0) cnt = cnt + 1;
            if (tb_cardinal_torus_cmp.CMP.DMEM_12.MEM[m] !== 64'd0) cnt = cnt + 1;
            if (tb_cardinal_torus_cmp.CMP.DMEM_13.MEM[m] !== 64'd0) cnt = cnt + 1;
            if (tb_cardinal_torus_cmp.CMP.DMEM_20.MEM[m] !== 64'd0) cnt = cnt + 1;
            if (tb_cardinal_torus_cmp.CMP.DMEM_21.MEM[m] !== 64'd0) cnt = cnt + 1;
            if (tb_cardinal_torus_cmp.CMP.DMEM_22.MEM[m] !== 64'd0) cnt = cnt + 1;
            if (tb_cardinal_torus_cmp.CMP.DMEM_23.MEM[m] !== 64'd0) cnt = cnt + 1;
            if (tb_cardinal_torus_cmp.CMP.DMEM_30.MEM[m] !== 64'd0) cnt = cnt + 1;
            if (tb_cardinal_torus_cmp.CMP.DMEM_31.MEM[m] !== 64'd0) cnt = cnt + 1;
            if (tb_cardinal_torus_cmp.CMP.DMEM_32.MEM[m] !== 64'd0) cnt = cnt + 1;
            if (tb_cardinal_torus_cmp.CMP.DMEM_33.MEM[m] !== 64'd0) cnt = cnt + 1;
        end
        if (cnt == 240) begin
            completion_time_ns = $time;
            all_done = 1;
            $display("COMPLETION DETECTED: all 240 slots filled at time %0t (cycle %0d)",
                     $time, ($time / `CYCLE_TIME) - 4);
        end
    end
end

// ============================================================
// File handles
// ============================================================
integer dump_file [0:15];
integer cov_file;
integer i, j;

// ============================================================
// Coverage matrix: cov[src][dst] = 1 if packet delivered
// ============================================================
integer cov_matrix [0:15][0:15];
integer total_delivered;
integer total_expected;

integer start_cycle;
integer completion_cycle;



// ============================================================
// Node ID helpers
// Row-major: node(r,c) = r*4 + c
// ============================================================
// Node names for file naming (row*10 + col for file suffix)
// 00,01,02,03,10,11,12,13,20,21,22,23,30,31,32,33

// ============================================================
// Packet decode helper tasks
// ============================================================
// Extract sourceX (col) and sourceY (row) from received packet
// Packet is 64-bit big-endian:
//   bits[16:23] = sourceX → in 64-bit word: bits 40:47 from MSB
//   bits[24:31] = sourceY → in 64-bit word: bits 32:39 from MSB
// In Verilog [0:63]: sourceX = pkt[16:23], sourceY = pkt[24:31]
task decode_source;
    input  [0:63] pkt;
    output [7:0]  src_col;
    output [7:0]  src_row;
    begin
        src_col = pkt[16:23];
        src_row = pkt[24:31];
    end
endtask

// ============================================================
// Main test
// ============================================================
initial begin
    // Initialize
    clk   = 0;
    reset = 1;
    total_delivered = 0;
    total_expected  = 240;
    all_done = 0;

    // Initialize coverage matrix
    for (i = 0; i < 16; i = i + 1)
        for (j = 0; j < 16; j = j + 1)
            cov_matrix[i][j] = 0;

    // Load instruction memories (identical program for all nodes)
    $readmemh("./testcase_torus/cmp_test.imem.00.fill", tb_cardinal_torus_cmp.CMP.IMEM_00.MEM);
    $readmemh("./testcase_torus/cmp_test.imem.01.fill", tb_cardinal_torus_cmp.CMP.IMEM_01.MEM);
    $readmemh("./testcase_torus/cmp_test.imem.02.fill", tb_cardinal_torus_cmp.CMP.IMEM_02.MEM);
    $readmemh("./testcase_torus/cmp_test.imem.03.fill", tb_cardinal_torus_cmp.CMP.IMEM_03.MEM);
    $readmemh("./testcase_torus/cmp_test.imem.10.fill", tb_cardinal_torus_cmp.CMP.IMEM_10.MEM);
    $readmemh("./testcase_torus/cmp_test.imem.11.fill", tb_cardinal_torus_cmp.CMP.IMEM_11.MEM);
    $readmemh("./testcase_torus/cmp_test.imem.12.fill", tb_cardinal_torus_cmp.CMP.IMEM_12.MEM);
    $readmemh("./testcase_torus/cmp_test.imem.13.fill", tb_cardinal_torus_cmp.CMP.IMEM_13.MEM);
    $readmemh("./testcase_torus/cmp_test.imem.20.fill", tb_cardinal_torus_cmp.CMP.IMEM_20.MEM);
    $readmemh("./testcase_torus/cmp_test.imem.21.fill", tb_cardinal_torus_cmp.CMP.IMEM_21.MEM);
    $readmemh("./testcase_torus/cmp_test.imem.22.fill", tb_cardinal_torus_cmp.CMP.IMEM_22.MEM);
    $readmemh("./testcase_torus/cmp_test.imem.23.fill", tb_cardinal_torus_cmp.CMP.IMEM_23.MEM);
    $readmemh("./testcase_torus/cmp_test.imem.30.fill", tb_cardinal_torus_cmp.CMP.IMEM_30.MEM);
    $readmemh("./testcase_torus/cmp_test.imem.31.fill", tb_cardinal_torus_cmp.CMP.IMEM_31.MEM);
    $readmemh("./testcase_torus/cmp_test.imem.32.fill", tb_cardinal_torus_cmp.CMP.IMEM_32.MEM);
    $readmemh("./testcase_torus/cmp_test.imem.33.fill", tb_cardinal_torus_cmp.CMP.IMEM_33.MEM);

    // Load data memories (unique per node - contains outgoing packets)
    $readmemh("./testcase_torus/cmp_test.dmem.00.fill", tb_cardinal_torus_cmp.CMP.DMEM_00.MEM);
    $readmemh("./testcase_torus/cmp_test.dmem.01.fill", tb_cardinal_torus_cmp.CMP.DMEM_01.MEM);
    $readmemh("./testcase_torus/cmp_test.dmem.02.fill", tb_cardinal_torus_cmp.CMP.DMEM_02.MEM);
    $readmemh("./testcase_torus/cmp_test.dmem.03.fill", tb_cardinal_torus_cmp.CMP.DMEM_03.MEM);
    $readmemh("./testcase_torus/cmp_test.dmem.10.fill", tb_cardinal_torus_cmp.CMP.DMEM_10.MEM);
    $readmemh("./testcase_torus/cmp_test.dmem.11.fill", tb_cardinal_torus_cmp.CMP.DMEM_11.MEM);
    $readmemh("./testcase_torus/cmp_test.dmem.12.fill", tb_cardinal_torus_cmp.CMP.DMEM_12.MEM);
    $readmemh("./testcase_torus/cmp_test.dmem.13.fill", tb_cardinal_torus_cmp.CMP.DMEM_13.MEM);
    $readmemh("./testcase_torus/cmp_test.dmem.20.fill", tb_cardinal_torus_cmp.CMP.DMEM_20.MEM);
    $readmemh("./testcase_torus/cmp_test.dmem.21.fill", tb_cardinal_torus_cmp.CMP.DMEM_21.MEM);
    $readmemh("./testcase_torus/cmp_test.dmem.22.fill", tb_cardinal_torus_cmp.CMP.DMEM_22.MEM);
    $readmemh("./testcase_torus/cmp_test.dmem.23.fill", tb_cardinal_torus_cmp.CMP.DMEM_23.MEM);
    $readmemh("./testcase_torus/cmp_test.dmem.30.fill", tb_cardinal_torus_cmp.CMP.DMEM_30.MEM);
    $readmemh("./testcase_torus/cmp_test.dmem.31.fill", tb_cardinal_torus_cmp.CMP.DMEM_31.MEM);
    $readmemh("./testcase_torus/cmp_test.dmem.32.fill", tb_cardinal_torus_cmp.CMP.DMEM_32.MEM);
    $readmemh("./testcase_torus/cmp_test.dmem.33.fill", tb_cardinal_torus_cmp.CMP.DMEM_33.MEM);

    // Assert reset for 4 cycles
    #(4 * `CYCLE_TIME);
    reset = 0;
    start_cycle = $time / `CYCLE_TIME;

    $display("Simulation started at time %0t", $time);
    $display("Running all-to-all communication test (240 packets)...");

    #(50000 * `CYCLE_TIME);
    completion_cycle = ($time / `CYCLE_TIME) - start_cycle;
    $display("Stopped at cycle %0d from reset. Flushing pipeline...", completion_cycle);

    repeat(10) @(negedge clk);

    // ============================================================
    // Dump dmem contents for all 16 nodes
    // ============================================================
    $display("\n--- Dumping data memories ---");

    dump_file[0]  = $fopen("./report_torus/cmp_test.dmem.00.dump");
    dump_file[1]  = $fopen("./report_torus/cmp_test.dmem.01.dump");
    dump_file[2]  = $fopen("./report_torus/cmp_test.dmem.02.dump");
    dump_file[3]  = $fopen("./report_torus/cmp_test.dmem.03.dump");
    dump_file[4]  = $fopen("./report_torus/cmp_test.dmem.10.dump");
    dump_file[5]  = $fopen("./report_torus/cmp_test.dmem.11.dump");
    dump_file[6]  = $fopen("./report_torus/cmp_test.dmem.12.dump");
    dump_file[7]  = $fopen("./report_torus/cmp_test.dmem.13.dump");
    dump_file[8]  = $fopen("./report_torus/cmp_test.dmem.20.dump");
    dump_file[9]  = $fopen("./report_torus/cmp_test.dmem.21.dump");
    dump_file[10] = $fopen("./report_torus/cmp_test.dmem.22.dump");
    dump_file[11] = $fopen("./report_torus/cmp_test.dmem.23.dump");
    dump_file[12] = $fopen("./report_torus/cmp_test.dmem.30.dump");
    dump_file[13] = $fopen("./report_torus/cmp_test.dmem.31.dump");
    dump_file[14] = $fopen("./report_torus/cmp_test.dmem.32.dump");
    dump_file[15] = $fopen("./report_torus/cmp_test.dmem.33.dump");

    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[0],  "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_00.MEM[i]);
    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[1],  "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_01.MEM[i]);
    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[2],  "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_02.MEM[i]);
    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[3],  "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_03.MEM[i]);
    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[4],  "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_10.MEM[i]);
    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[5],  "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_11.MEM[i]);
    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[6],  "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_12.MEM[i]);
    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[7],  "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_13.MEM[i]);
    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[8],  "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_20.MEM[i]);
    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[9],  "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_21.MEM[i]);
    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[10], "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_22.MEM[i]);
    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[11], "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_23.MEM[i]);
    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[12], "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_30.MEM[i]);
    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[13], "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_31.MEM[i]);
    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[14], "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_32.MEM[i]);
    for (i = 0; i < 32; i = i + 1)
        $fdisplay(dump_file[15], "Memory location # %3d : %016h", i, tb_cardinal_torus_cmp.CMP.DMEM_33.MEM[i]);

    for (i = 0; i < 16; i = i + 1)
        $fclose(dump_file[i]);

    $display("Dmem dumps written to ./report_torus/");

    // ============================================================
    // Coverage checking
    // Decode sourceX/sourceY from each received packet (MEM[16..30])
    // and mark coverage matrix
    // ============================================================
    $display("\n--- Checking packet delivery coverage ---");

    // Node 00 (id=0, row=0, col=0)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_00.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_00.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_00.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_00.MEM[i][16:23];
            if (cov_matrix[j][0] == 0) begin
                cov_matrix[j][0] = 1; total_delivered = total_delivered + 1;
            end
        end
    end
    // Node 01 (id=1)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_01.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_01.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_01.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_01.MEM[i][16:23];
            if (cov_matrix[j][1] == 0) begin
                cov_matrix[j][1] = 1; total_delivered = total_delivered + 1;
            end
        end
    end
    // Node 02 (id=2)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_02.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_02.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_02.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_02.MEM[i][16:23];
            if (cov_matrix[j][2] == 0) begin
                cov_matrix[j][2] = 1; total_delivered = total_delivered + 1;
            end
        end
    end
    // Node 03 (id=3)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_03.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_03.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_03.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_03.MEM[i][16:23];
            if (cov_matrix[j][3] == 0) begin
                cov_matrix[j][3] = 1; total_delivered = total_delivered + 1;
            end
        end
    end
    // Node 10 (id=4)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_10.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_10.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_10.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_10.MEM[i][16:23];
            if (cov_matrix[j][4] == 0) begin
                cov_matrix[j][4] = 1; total_delivered = total_delivered + 1;
            end
        end
    end
    // Node 11 (id=5)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_11.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_11.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_11.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_11.MEM[i][16:23];
            if (cov_matrix[j][5] == 0) begin
                cov_matrix[j][5] = 1; total_delivered = total_delivered + 1;
            end
        end
    end
    // Node 12 (id=6)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_12.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_12.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_12.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_12.MEM[i][16:23];
            if (cov_matrix[j][6] == 0) begin
                cov_matrix[j][6] = 1; total_delivered = total_delivered + 1;
            end
        end
    end
    // Node 13 (id=7)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_13.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_13.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_13.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_13.MEM[i][16:23];
            if (cov_matrix[j][7] == 0) begin
                cov_matrix[j][7] = 1; total_delivered = total_delivered + 1;
            end
        end
    end
    // Node 20 (id=8)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_20.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_20.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_20.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_20.MEM[i][16:23];
            if (cov_matrix[j][8] == 0) begin
                cov_matrix[j][8] = 1; total_delivered = total_delivered + 1;
            end
        end
    end
    // Node 21 (id=9)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_21.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_21.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_21.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_21.MEM[i][16:23];
            if (cov_matrix[j][9] == 0) begin
                cov_matrix[j][9] = 1; total_delivered = total_delivered + 1;
            end
        end
    end
    // Node 22 (id=10)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_22.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_22.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_22.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_22.MEM[i][16:23];
            if (cov_matrix[j][10] == 0) begin
                cov_matrix[j][10] = 1; total_delivered = total_delivered + 1;
            end
        end
    end
    // Node 23 (id=11)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_23.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_23.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_23.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_23.MEM[i][16:23];
            if (cov_matrix[j][11] == 0) begin
                cov_matrix[j][11] = 1; total_delivered = total_delivered + 1;
            end
        end
    end
    // Node 30 (id=12)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_30.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_30.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_30.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_30.MEM[i][16:23];
            if (cov_matrix[j][12] == 0) begin
                cov_matrix[j][12] = 1; total_delivered = total_delivered + 1;
            end
        end
    end
    // Node 31 (id=13)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_31.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_31.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_31.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_31.MEM[i][16:23];
            if (cov_matrix[j][13] == 0) begin
                cov_matrix[j][13] = 1; total_delivered = total_delivered + 1;
            end
        end
    end
    // Node 32 (id=14)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_32.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_32.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_32.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_32.MEM[i][16:23];
            if (cov_matrix[j][14] == 0) begin
                cov_matrix[j][14] = 1; total_delivered = total_delivered + 1;
            end
        end
    end
    // Node 33 (id=15)
    for (i = 16; i <= 30; i = i + 1) begin
        if (tb_cardinal_torus_cmp.CMP.DMEM_33.MEM[i] !== 64'bx &&
            tb_cardinal_torus_cmp.CMP.DMEM_33.MEM[i] !== 64'd0) begin
            j = tb_cardinal_torus_cmp.CMP.DMEM_33.MEM[i][24:31] * 4 +
                tb_cardinal_torus_cmp.CMP.DMEM_33.MEM[i][16:23];
            if (cov_matrix[j][15] == 0) begin
                cov_matrix[j][15] = 1; total_delivered = total_delivered + 1;
            end
        end
    end

    // ============================================================
    // Print coverage report_torus
    // ============================================================
    $display("\n============================================================");
    $display("COVERAGE REPORT_torus");
    $display("============================================================");
    $display("Packets delivered: %0d / %0d", total_delivered, total_expected);
    $display("Coverage: %0d%%", (total_delivered * 100) / total_expected);
    $display("");
    $display("Coverage matrix (src=row, dst=col, 1=delivered, -=self):");
    $display("     00 01 02 03 10 11 12 13 20 21 22 23 30 31 32 33");

    begin : print_matrix
        integer r, c;
        
        for (r = 0; r < 16; r = r + 1) begin
            $write("n%02d: ", r);
            for (c = 0; c < 16; c = c + 1) begin
                if (r == c)
                    $write(" - ");
                else if (cov_matrix[r][c] == 1)
                    $write(" 1 ");
                else
                    $write(" 0 ");
            end
            $write("\n");
        end
    end

    // Print missing packets
    $display("\nMissing packets:");
    begin : print_missing
        integer r, c;
        integer missing_count;
        missing_count = 0;
        for (r = 0; r < 16; r = r + 1) begin
            for (c = 0; c < 16; c = c + 1) begin
                if (r != c && cov_matrix[r][c] == 0) begin
                    $display("  node%0d -> node%0d: NOT DELIVERED", r, c);
                    missing_count = missing_count + 1;
                end
            end
        end
        if (missing_count == 0)
            $display("  None! All 240 packets delivered successfully.");
    end

    // Write coverage report_torus to file
    cov_file = $fopen("./report_torus/coverage_report_torus.txt");
    $fdisplay(cov_file, "Completion detected at cycle: %0d", 
          (completion_time_ns / `CYCLE_TIME) - 4);
    $fdisplay(cov_file, "CARDINAL CMP ALL-TO-ALL COVERAGE REPORT_torus");
    $fdisplay(cov_file, "Packets delivered: %0d / %0d", total_delivered, total_expected);
    $fdisplay(cov_file, "Coverage: %0d%%", (total_delivered * 100) / total_expected);
    $fdisplay(cov_file, "");
    $fdisplay(cov_file, "Coverage matrix (src=row, dst=col):");
    $fdisplay(cov_file, "     00 01 02 03 10 11 12 13 20 21 22 23 30 31 32 33");
    begin : write_matrix
        integer r, c;
        for (r = 0; r < 16; r = r + 1) begin
            $fwrite(cov_file, "n%02d: ", r);
            for (c = 0; c < 16; c = c + 1) begin
                if (r == c)
                    $fwrite(cov_file, " - ");
                else if (cov_matrix[r][c] == 1)
                    $fwrite(cov_file, " 1 ");
                else
                    $fwrite(cov_file, " 0 ");
            end
            $fwrite(cov_file, "\n");
        end
    end
    $fclose(cov_file);

    $display("\nCoverage report_torus written to ./report_torus/coverage_report_torus.txt");
    $display("============================================================");

    if (total_delivered == total_expected) begin
        $display("RESULT: PASS - All 240 packets delivered correctly!");
        $display("Completion: %0d cycles from reset", completion_cycle);
    end else
        $display("RESULT: FAIL - %0d packets missing.",
                 total_expected - total_delivered);

    $display("============================================================\n");

    $stop;
end

// ============================================================
// Global timeout watchdog
// ============================================================
initial begin
    #(3100000 * `CYCLE_TIME);
    $display("WATCHDOG TIMEOUT - simulation forcibly terminated");
    $finish;
end

endmodule