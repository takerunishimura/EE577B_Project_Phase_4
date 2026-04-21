// ============================================================
// cardinal_torus_cmp.v
// Top-level 16-core Cardinal Chip Multiprocessor
//
// Internal structure:
//   - One torus_mesh (16 routers in 4x4 torus topology)
//   - 16 nodes, each with: cardinal_cpu, cardinal_nic
//   - Memories are external (per Phase 4 spec Figure 1)
//
// Node naming: RC where R=row(0-3), C=col(0-3)
// ============================================================

module cardinal_torus_cmp (
    input clk,
    input reset,

    // NODE 00
    input  [0:31] node00_inst_in, input  [0:63] node00_d_in,
    output [0:31] node00_pc_out,  output [0:63] node00_d_out,
    output [0:31] node00_addr_out, output node00_memWrEn, output node00_memEn,

    // NODE 01
    input  [0:31] node01_inst_in, input  [0:63] node01_d_in,
    output [0:31] node01_pc_out,  output [0:63] node01_d_out,
    output [0:31] node01_addr_out, output node01_memWrEn, output node01_memEn,

    // NODE 02
    input  [0:31] node02_inst_in, input  [0:63] node02_d_in,
    output [0:31] node02_pc_out,  output [0:63] node02_d_out,
    output [0:31] node02_addr_out, output node02_memWrEn, output node02_memEn,

    // NODE 03
    input  [0:31] node03_inst_in, input  [0:63] node03_d_in,
    output [0:31] node03_pc_out,  output [0:63] node03_d_out,
    output [0:31] node03_addr_out, output node03_memWrEn, output node03_memEn,

    // NODE 10
    input  [0:31] node10_inst_in, input  [0:63] node10_d_in,
    output [0:31] node10_pc_out,  output [0:63] node10_d_out,
    output [0:31] node10_addr_out, output node10_memWrEn, output node10_memEn,

    // NODE 11
    input  [0:31] node11_inst_in, input  [0:63] node11_d_in,
    output [0:31] node11_pc_out,  output [0:63] node11_d_out,
    output [0:31] node11_addr_out, output node11_memWrEn, output node11_memEn,

    // NODE 12
    input  [0:31] node12_inst_in, input  [0:63] node12_d_in,
    output [0:31] node12_pc_out,  output [0:63] node12_d_out,
    output [0:31] node12_addr_out, output node12_memWrEn, output node12_memEn,

    // NODE 13
    input  [0:31] node13_inst_in, input  [0:63] node13_d_in,
    output [0:31] node13_pc_out,  output [0:63] node13_d_out,
    output [0:31] node13_addr_out, output node13_memWrEn, output node13_memEn,

    // NODE 20
    input  [0:31] node20_inst_in, input  [0:63] node20_d_in,
    output [0:31] node20_pc_out,  output [0:63] node20_d_out,
    output [0:31] node20_addr_out, output node20_memWrEn, output node20_memEn,

    // NODE 21
    input  [0:31] node21_inst_in, input  [0:63] node21_d_in,
    output [0:31] node21_pc_out,  output [0:63] node21_d_out,
    output [0:31] node21_addr_out, output node21_memWrEn, output node21_memEn,

    // NODE 22
    input  [0:31] node22_inst_in, input  [0:63] node22_d_in,
    output [0:31] node22_pc_out,  output [0:63] node22_d_out,
    output [0:31] node22_addr_out, output node22_memWrEn, output node22_memEn,

    // NODE 23
    input  [0:31] node23_inst_in, input  [0:63] node23_d_in,
    output [0:31] node23_pc_out,  output [0:63] node23_d_out,
    output [0:31] node23_addr_out, output node23_memWrEn, output node23_memEn,

    // NODE 30
    input  [0:31] node30_inst_in, input  [0:63] node30_d_in,
    output [0:31] node30_pc_out,  output [0:63] node30_d_out,
    output [0:31] node30_addr_out, output node30_memWrEn, output node30_memEn,

    // NODE 31
    input  [0:31] node31_inst_in, input  [0:63] node31_d_in,
    output [0:31] node31_pc_out,  output [0:63] node31_d_out,
    output [0:31] node31_addr_out, output node31_memWrEn, output node31_memEn,

    // NODE 32
    input  [0:31] node32_inst_in, input  [0:63] node32_d_in,
    output [0:31] node32_pc_out,  output [0:63] node32_d_out,
    output [0:31] node32_addr_out, output node32_memWrEn, output node32_memEn,

    // NODE 33
    input  [0:31] node33_inst_in, input  [0:63] node33_d_in,
    output [0:31] node33_pc_out,  output [0:63] node33_d_out,
    output [0:31] node33_addr_out, output node33_memWrEn, output node33_memEn
);

    // ============================================================
    // PE-side wires between torus_mesh and NICs (per node)
    // ============================================================
    wire n00_pesi, n00_peri; wire [63:0] n00_pedi;
    wire n00_peso, n00_pero; wire [63:0] n00_pedo; wire n00_polarity;
    wire n01_pesi, n01_peri; wire [63:0] n01_pedi;
    wire n01_peso, n01_pero; wire [63:0] n01_pedo; wire n01_polarity;
    wire n02_pesi, n02_peri; wire [63:0] n02_pedi;
    wire n02_peso, n02_pero; wire [63:0] n02_pedo; wire n02_polarity;
    wire n03_pesi, n03_peri; wire [63:0] n03_pedi;
    wire n03_peso, n03_pero; wire [63:0] n03_pedo; wire n03_polarity;
    wire n10_pesi, n10_peri; wire [63:0] n10_pedi;
    wire n10_peso, n10_pero; wire [63:0] n10_pedo; wire n10_polarity;
    wire n11_pesi, n11_peri; wire [63:0] n11_pedi;
    wire n11_peso, n11_pero; wire [63:0] n11_pedo; wire n11_polarity;
    wire n12_pesi, n12_peri; wire [63:0] n12_pedi;
    wire n12_peso, n12_pero; wire [63:0] n12_pedo; wire n12_polarity;
    wire n13_pesi, n13_peri; wire [63:0] n13_pedi;
    wire n13_peso, n13_pero; wire [63:0] n13_pedo; wire n13_polarity;
    wire n20_pesi, n20_peri; wire [63:0] n20_pedi;
    wire n20_peso, n20_pero; wire [63:0] n20_pedo; wire n20_polarity;
    wire n21_pesi, n21_peri; wire [63:0] n21_pedi;
    wire n21_peso, n21_pero; wire [63:0] n21_pedo; wire n21_polarity;
    wire n22_pesi, n22_peri; wire [63:0] n22_pedi;
    wire n22_peso, n22_pero; wire [63:0] n22_pedo; wire n22_polarity;
    wire n23_pesi, n23_peri; wire [63:0] n23_pedi;
    wire n23_peso, n23_pero; wire [63:0] n23_pedo; wire n23_polarity;
    wire n30_pesi, n30_peri; wire [63:0] n30_pedi;
    wire n30_peso, n30_pero; wire [63:0] n30_pedo; wire n30_polarity;
    wire n31_pesi, n31_peri; wire [63:0] n31_pedi;
    wire n31_peso, n31_pero; wire [63:0] n31_pedo; wire n31_polarity;
    wire n32_pesi, n32_peri; wire [63:0] n32_pedi;
    wire n32_peso, n32_pero; wire [63:0] n32_pedo; wire n32_polarity;
    wire n33_pesi, n33_peri; wire [63:0] n33_pedi;
    wire n33_peso, n33_pero; wire [63:0] n33_pedo; wire n33_polarity;

    // ============================================================
    // Torus Mesh instantiation
    // ============================================================
    torus_mesh MESH (
        .clk(clk), .reset(reset),
        .node00_pesi(n00_pesi), .node00_peri(n00_peri), .node00_pedi(n00_pedi),
        .node00_peso(n00_peso), .node00_pero(n00_pero), .node00_pedo(n00_pedo),
        .node00_polarity(n00_polarity),
        .node01_pesi(n01_pesi), .node01_peri(n01_peri), .node01_pedi(n01_pedi),
        .node01_peso(n01_peso), .node01_pero(n01_pero), .node01_pedo(n01_pedo),
        .node01_polarity(n01_polarity),
        .node02_pesi(n02_pesi), .node02_peri(n02_peri), .node02_pedi(n02_pedi),
        .node02_peso(n02_peso), .node02_pero(n02_pero), .node02_pedo(n02_pedo),
        .node02_polarity(n02_polarity),
        .node03_pesi(n03_pesi), .node03_peri(n03_peri), .node03_pedi(n03_pedi),
        .node03_peso(n03_peso), .node03_pero(n03_pero), .node03_pedo(n03_pedo),
        .node03_polarity(n03_polarity),
        .node10_pesi(n10_pesi), .node10_peri(n10_peri), .node10_pedi(n10_pedi),
        .node10_peso(n10_peso), .node10_pero(n10_pero), .node10_pedo(n10_pedo),
        .node10_polarity(n10_polarity),
        .node11_pesi(n11_pesi), .node11_peri(n11_peri), .node11_pedi(n11_pedi),
        .node11_peso(n11_peso), .node11_pero(n11_pero), .node11_pedo(n11_pedo),
        .node11_polarity(n11_polarity),
        .node12_pesi(n12_pesi), .node12_peri(n12_peri), .node12_pedi(n12_pedi),
        .node12_peso(n12_peso), .node12_pero(n12_pero), .node12_pedo(n12_pedo),
        .node12_polarity(n12_polarity),
        .node13_pesi(n13_pesi), .node13_peri(n13_peri), .node13_pedi(n13_pedi),
        .node13_peso(n13_peso), .node13_pero(n13_pero), .node13_pedo(n13_pedo),
        .node13_polarity(n13_polarity),
        .node20_pesi(n20_pesi), .node20_peri(n20_peri), .node20_pedi(n20_pedi),
        .node20_peso(n20_peso), .node20_pero(n20_pero), .node20_pedo(n20_pedo),
        .node20_polarity(n20_polarity),
        .node21_pesi(n21_pesi), .node21_peri(n21_peri), .node21_pedi(n21_pedi),
        .node21_peso(n21_peso), .node21_pero(n21_pero), .node21_pedo(n21_pedo),
        .node21_polarity(n21_polarity),
        .node22_pesi(n22_pesi), .node22_peri(n22_peri), .node22_pedi(n22_pedi),
        .node22_peso(n22_peso), .node22_pero(n22_pero), .node22_pedo(n22_pedo),
        .node22_polarity(n22_polarity),
        .node23_pesi(n23_pesi), .node23_peri(n23_peri), .node23_pedi(n23_pedi),
        .node23_peso(n23_peso), .node23_pero(n23_pero), .node23_pedo(n23_pedo),
        .node23_polarity(n23_polarity),
        .node30_pesi(n30_pesi), .node30_peri(n30_peri), .node30_pedi(n30_pedi),
        .node30_peso(n30_peso), .node30_pero(n30_pero), .node30_pedo(n30_pedo),
        .node30_polarity(n30_polarity),
        .node31_pesi(n31_pesi), .node31_peri(n31_peri), .node31_pedi(n31_pedi),
        .node31_peso(n31_peso), .node31_pero(n31_pero), .node31_pedo(n31_pedo),
        .node31_polarity(n31_polarity),
        .node32_pesi(n32_pesi), .node32_peri(n32_peri), .node32_pedi(n32_pedi),
        .node32_peso(n32_peso), .node32_pero(n32_pero), .node32_pedo(n32_pedo),
        .node32_polarity(n32_polarity),
        .node33_pesi(n33_pesi), .node33_peri(n33_peri), .node33_pedi(n33_pedi),
        .node33_peso(n33_peso), .node33_pero(n33_pero), .node33_pedo(n33_pedo),
        .node33_polarity(n33_polarity)
    );

    // ============================================================
    // NODE 00
    // ============================================================
    wire [0:63] nic00_dout;
    wire        cpu00_nicEn, cpu00_nicWrEn;
    wire [0:1]  cpu00_nic_addr;

    cardinal_cpu CPU_00 (.clk(clk), .reset(reset),
                         .inst_in(node00_inst_in), .d_in(node00_d_in),
                         .pc_out(node00_pc_out), .addr_out(node00_addr_out),
                         .memEn(node00_memEn), .memWrEn(node00_memWrEn), .d_out(node00_d_out),
                         .nicEn(cpu00_nicEn), .nicWrEn(cpu00_nicWrEn),
                         .nic_addr(cpu00_nic_addr), .nic_d_out(nic00_dout));
    cardinal_nic NIC_00 (.clk(clk), .reset(reset),
                         .addr(cpu00_nic_addr), .d_in(node00_d_out), .d_out(nic00_dout),
                         .nicEn(cpu00_nicEn), .nicWrEn(cpu00_nicWrEn),
                         .net_so(n00_pesi), .net_ro(n00_peri), .net_do(n00_pedi),
                         .net_si(n00_peso), .net_ri(n00_pero), .net_di(n00_pedo),
                         .net_polarity(n00_polarity));

    // ============================================================
    // NODE 01
    // ============================================================
    wire [0:63] nic01_dout;
    wire        cpu01_nicEn, cpu01_nicWrEn;
    wire [0:1]  cpu01_nic_addr;

    cardinal_cpu CPU_01 (.clk(clk), .reset(reset),
                         .inst_in(node01_inst_in), .d_in(node01_d_in),
                         .pc_out(node01_pc_out), .addr_out(node01_addr_out),
                         .memEn(node01_memEn), .memWrEn(node01_memWrEn), .d_out(node01_d_out),
                         .nicEn(cpu01_nicEn), .nicWrEn(cpu01_nicWrEn),
                         .nic_addr(cpu01_nic_addr), .nic_d_out(nic01_dout));
    cardinal_nic NIC_01 (.clk(clk), .reset(reset),
                         .addr(cpu01_nic_addr), .d_in(node01_d_out), .d_out(nic01_dout),
                         .nicEn(cpu01_nicEn), .nicWrEn(cpu01_nicWrEn),
                         .net_so(n01_pesi), .net_ro(n01_peri), .net_do(n01_pedi),
                         .net_si(n01_peso), .net_ri(n01_pero), .net_di(n01_pedo),
                         .net_polarity(n01_polarity));

    // ============================================================
    // NODE 02
    // ============================================================
    wire [0:63] nic02_dout;
    wire        cpu02_nicEn, cpu02_nicWrEn;
    wire [0:1]  cpu02_nic_addr;

    cardinal_cpu CPU_02 (.clk(clk), .reset(reset),
                         .inst_in(node02_inst_in), .d_in(node02_d_in),
                         .pc_out(node02_pc_out), .addr_out(node02_addr_out),
                         .memEn(node02_memEn), .memWrEn(node02_memWrEn), .d_out(node02_d_out),
                         .nicEn(cpu02_nicEn), .nicWrEn(cpu02_nicWrEn),
                         .nic_addr(cpu02_nic_addr), .nic_d_out(nic02_dout));
    cardinal_nic NIC_02 (.clk(clk), .reset(reset),
                         .addr(cpu02_nic_addr), .d_in(node02_d_out), .d_out(nic02_dout),
                         .nicEn(cpu02_nicEn), .nicWrEn(cpu02_nicWrEn),
                         .net_so(n02_pesi), .net_ro(n02_peri), .net_do(n02_pedi),
                         .net_si(n02_peso), .net_ri(n02_pero), .net_di(n02_pedo),
                         .net_polarity(n02_polarity));

    // ============================================================
    // NODE 03
    // ============================================================
    wire [0:63] nic03_dout;
    wire        cpu03_nicEn, cpu03_nicWrEn;
    wire [0:1]  cpu03_nic_addr;

    cardinal_cpu CPU_03 (.clk(clk), .reset(reset),
                         .inst_in(node03_inst_in), .d_in(node03_d_in),
                         .pc_out(node03_pc_out), .addr_out(node03_addr_out),
                         .memEn(node03_memEn), .memWrEn(node03_memWrEn), .d_out(node03_d_out),
                         .nicEn(cpu03_nicEn), .nicWrEn(cpu03_nicWrEn),
                         .nic_addr(cpu03_nic_addr), .nic_d_out(nic03_dout));
    cardinal_nic NIC_03 (.clk(clk), .reset(reset),
                         .addr(cpu03_nic_addr), .d_in(node03_d_out), .d_out(nic03_dout),
                         .nicEn(cpu03_nicEn), .nicWrEn(cpu03_nicWrEn),
                         .net_so(n03_pesi), .net_ro(n03_peri), .net_do(n03_pedi),
                         .net_si(n03_peso), .net_ri(n03_pero), .net_di(n03_pedo),
                         .net_polarity(n03_polarity));

    // ============================================================
    // NODE 10
    // ============================================================
    wire [0:63] nic10_dout;
    wire        cpu10_nicEn, cpu10_nicWrEn;
    wire [0:1]  cpu10_nic_addr;

    cardinal_cpu CPU_10 (.clk(clk), .reset(reset),
                         .inst_in(node10_inst_in), .d_in(node10_d_in),
                         .pc_out(node10_pc_out), .addr_out(node10_addr_out),
                         .memEn(node10_memEn), .memWrEn(node10_memWrEn), .d_out(node10_d_out),
                         .nicEn(cpu10_nicEn), .nicWrEn(cpu10_nicWrEn),
                         .nic_addr(cpu10_nic_addr), .nic_d_out(nic10_dout));
    cardinal_nic NIC_10 (.clk(clk), .reset(reset),
                         .addr(cpu10_nic_addr), .d_in(node10_d_out), .d_out(nic10_dout),
                         .nicEn(cpu10_nicEn), .nicWrEn(cpu10_nicWrEn),
                         .net_so(n10_pesi), .net_ro(n10_peri), .net_do(n10_pedi),
                         .net_si(n10_peso), .net_ri(n10_pero), .net_di(n10_pedo),
                         .net_polarity(n10_polarity));

    // ============================================================
    // NODE 11
    // ============================================================
    wire [0:63] nic11_dout;
    wire        cpu11_nicEn, cpu11_nicWrEn;
    wire [0:1]  cpu11_nic_addr;

    cardinal_cpu CPU_11 (.clk(clk), .reset(reset),
                         .inst_in(node11_inst_in), .d_in(node11_d_in),
                         .pc_out(node11_pc_out), .addr_out(node11_addr_out),
                         .memEn(node11_memEn), .memWrEn(node11_memWrEn), .d_out(node11_d_out),
                         .nicEn(cpu11_nicEn), .nicWrEn(cpu11_nicWrEn),
                         .nic_addr(cpu11_nic_addr), .nic_d_out(nic11_dout));
    cardinal_nic NIC_11 (.clk(clk), .reset(reset),
                         .addr(cpu11_nic_addr), .d_in(node11_d_out), .d_out(nic11_dout),
                         .nicEn(cpu11_nicEn), .nicWrEn(cpu11_nicWrEn),
                         .net_so(n11_pesi), .net_ro(n11_peri), .net_do(n11_pedi),
                         .net_si(n11_peso), .net_ri(n11_pero), .net_di(n11_pedo),
                         .net_polarity(n11_polarity));

    // ============================================================
    // NODE 12
    // ============================================================
    wire [0:63] nic12_dout;
    wire        cpu12_nicEn, cpu12_nicWrEn;
    wire [0:1]  cpu12_nic_addr;

    cardinal_cpu CPU_12 (.clk(clk), .reset(reset),
                         .inst_in(node12_inst_in), .d_in(node12_d_in),
                         .pc_out(node12_pc_out), .addr_out(node12_addr_out),
                         .memEn(node12_memEn), .memWrEn(node12_memWrEn), .d_out(node12_d_out),
                         .nicEn(cpu12_nicEn), .nicWrEn(cpu12_nicWrEn),
                         .nic_addr(cpu12_nic_addr), .nic_d_out(nic12_dout));
    cardinal_nic NIC_12 (.clk(clk), .reset(reset),
                         .addr(cpu12_nic_addr), .d_in(node12_d_out), .d_out(nic12_dout),
                         .nicEn(cpu12_nicEn), .nicWrEn(cpu12_nicWrEn),
                         .net_so(n12_pesi), .net_ro(n12_peri), .net_do(n12_pedi),
                         .net_si(n12_peso), .net_ri(n12_pero), .net_di(n12_pedo),
                         .net_polarity(n12_polarity));

    // ============================================================
    // NODE 13
    // ============================================================
    wire [0:63] nic13_dout;
    wire        cpu13_nicEn, cpu13_nicWrEn;
    wire [0:1]  cpu13_nic_addr;

    cardinal_cpu CPU_13 (.clk(clk), .reset(reset),
                         .inst_in(node13_inst_in), .d_in(node13_d_in),
                         .pc_out(node13_pc_out), .addr_out(node13_addr_out),
                         .memEn(node13_memEn), .memWrEn(node13_memWrEn), .d_out(node13_d_out),
                         .nicEn(cpu13_nicEn), .nicWrEn(cpu13_nicWrEn),
                         .nic_addr(cpu13_nic_addr), .nic_d_out(nic13_dout));
    cardinal_nic NIC_13 (.clk(clk), .reset(reset),
                         .addr(cpu13_nic_addr), .d_in(node13_d_out), .d_out(nic13_dout),
                         .nicEn(cpu13_nicEn), .nicWrEn(cpu13_nicWrEn),
                         .net_so(n13_pesi), .net_ro(n13_peri), .net_do(n13_pedi),
                         .net_si(n13_peso), .net_ri(n13_pero), .net_di(n13_pedo),
                         .net_polarity(n13_polarity));

    // ============================================================
    // NODE 20
    // ============================================================
    wire [0:63] nic20_dout;
    wire        cpu20_nicEn, cpu20_nicWrEn;
    wire [0:1]  cpu20_nic_addr;

    cardinal_cpu CPU_20 (.clk(clk), .reset(reset),
                         .inst_in(node20_inst_in), .d_in(node20_d_in),
                         .pc_out(node20_pc_out), .addr_out(node20_addr_out),
                         .memEn(node20_memEn), .memWrEn(node20_memWrEn), .d_out(node20_d_out),
                         .nicEn(cpu20_nicEn), .nicWrEn(cpu20_nicWrEn),
                         .nic_addr(cpu20_nic_addr), .nic_d_out(nic20_dout));
    cardinal_nic NIC_20 (.clk(clk), .reset(reset),
                         .addr(cpu20_nic_addr), .d_in(node20_d_out), .d_out(nic20_dout),
                         .nicEn(cpu20_nicEn), .nicWrEn(cpu20_nicWrEn),
                         .net_so(n20_pesi), .net_ro(n20_peri), .net_do(n20_pedi),
                         .net_si(n20_peso), .net_ri(n20_pero), .net_di(n20_pedo),
                         .net_polarity(n20_polarity));

    // ============================================================
    // NODE 21
    // ============================================================
    wire [0:63] nic21_dout;
    wire        cpu21_nicEn, cpu21_nicWrEn;
    wire [0:1]  cpu21_nic_addr;

    cardinal_cpu CPU_21 (.clk(clk), .reset(reset),
                         .inst_in(node21_inst_in), .d_in(node21_d_in),
                         .pc_out(node21_pc_out), .addr_out(node21_addr_out),
                         .memEn(node21_memEn), .memWrEn(node21_memWrEn), .d_out(node21_d_out),
                         .nicEn(cpu21_nicEn), .nicWrEn(cpu21_nicWrEn),
                         .nic_addr(cpu21_nic_addr), .nic_d_out(nic21_dout));
    cardinal_nic NIC_21 (.clk(clk), .reset(reset),
                         .addr(cpu21_nic_addr), .d_in(node21_d_out), .d_out(nic21_dout),
                         .nicEn(cpu21_nicEn), .nicWrEn(cpu21_nicWrEn),
                         .net_so(n21_pesi), .net_ro(n21_peri), .net_do(n21_pedi),
                         .net_si(n21_peso), .net_ri(n21_pero), .net_di(n21_pedo),
                         .net_polarity(n21_polarity));

    // ============================================================
    // NODE 22
    // ============================================================
    wire [0:63] nic22_dout;
    wire        cpu22_nicEn, cpu22_nicWrEn;
    wire [0:1]  cpu22_nic_addr;

    cardinal_cpu CPU_22 (.clk(clk), .reset(reset),
                         .inst_in(node22_inst_in), .d_in(node22_d_in),
                         .pc_out(node22_pc_out), .addr_out(node22_addr_out),
                         .memEn(node22_memEn), .memWrEn(node22_memWrEn), .d_out(node22_d_out),
                         .nicEn(cpu22_nicEn), .nicWrEn(cpu22_nicWrEn),
                         .nic_addr(cpu22_nic_addr), .nic_d_out(nic22_dout));
    cardinal_nic NIC_22 (.clk(clk), .reset(reset),
                         .addr(cpu22_nic_addr), .d_in(node22_d_out), .d_out(nic22_dout),
                         .nicEn(cpu22_nicEn), .nicWrEn(cpu22_nicWrEn),
                         .net_so(n22_pesi), .net_ro(n22_peri), .net_do(n22_pedi),
                         .net_si(n22_peso), .net_ri(n22_pero), .net_di(n22_pedo),
                         .net_polarity(n22_polarity));

    // ============================================================
    // NODE 23
    // ============================================================
    wire [0:63] nic23_dout;
    wire        cpu23_nicEn, cpu23_nicWrEn;
    wire [0:1]  cpu23_nic_addr;

    cardinal_cpu CPU_23 (.clk(clk), .reset(reset),
                         .inst_in(node23_inst_in), .d_in(node23_d_in),
                         .pc_out(node23_pc_out), .addr_out(node23_addr_out),
                         .memEn(node23_memEn), .memWrEn(node23_memWrEn), .d_out(node23_d_out),
                         .nicEn(cpu23_nicEn), .nicWrEn(cpu23_nicWrEn),
                         .nic_addr(cpu23_nic_addr), .nic_d_out(nic23_dout));
    cardinal_nic NIC_23 (.clk(clk), .reset(reset),
                         .addr(cpu23_nic_addr), .d_in(node23_d_out), .d_out(nic23_dout),
                         .nicEn(cpu23_nicEn), .nicWrEn(cpu23_nicWrEn),
                         .net_so(n23_pesi), .net_ro(n23_peri), .net_do(n23_pedi),
                         .net_si(n23_peso), .net_ri(n23_pero), .net_di(n23_pedo),
                         .net_polarity(n23_polarity));

    // ============================================================
    // NODE 30
    // ============================================================
    wire [0:63] nic30_dout;
    wire        cpu30_nicEn, cpu30_nicWrEn;
    wire [0:1]  cpu30_nic_addr;

    cardinal_cpu CPU_30 (.clk(clk), .reset(reset),
                         .inst_in(node30_inst_in), .d_in(node30_d_in),
                         .pc_out(node30_pc_out), .addr_out(node30_addr_out),
                         .memEn(node30_memEn), .memWrEn(node30_memWrEn), .d_out(node30_d_out),
                         .nicEn(cpu30_nicEn), .nicWrEn(cpu30_nicWrEn),
                         .nic_addr(cpu30_nic_addr), .nic_d_out(nic30_dout));
    cardinal_nic NIC_30 (.clk(clk), .reset(reset),
                         .addr(cpu30_nic_addr), .d_in(node30_d_out), .d_out(nic30_dout),
                         .nicEn(cpu30_nicEn), .nicWrEn(cpu30_nicWrEn),
                         .net_so(n30_pesi), .net_ro(n30_peri), .net_do(n30_pedi),
                         .net_si(n30_peso), .net_ri(n30_pero), .net_di(n30_pedo),
                         .net_polarity(n30_polarity));

    // ============================================================
    // NODE 31
    // ============================================================
    wire [0:63] nic31_dout;
    wire        cpu31_nicEn, cpu31_nicWrEn;
    wire [0:1]  cpu31_nic_addr;

    cardinal_cpu CPU_31 (.clk(clk), .reset(reset),
                         .inst_in(node31_inst_in), .d_in(node31_d_in),
                         .pc_out(node31_pc_out), .addr_out(node31_addr_out),
                         .memEn(node31_memEn), .memWrEn(node31_memWrEn), .d_out(node31_d_out),
                         .nicEn(cpu31_nicEn), .nicWrEn(cpu31_nicWrEn),
                         .nic_addr(cpu31_nic_addr), .nic_d_out(nic31_dout));
    cardinal_nic NIC_31 (.clk(clk), .reset(reset),
                         .addr(cpu31_nic_addr), .d_in(node31_d_out), .d_out(nic31_dout),
                         .nicEn(cpu31_nicEn), .nicWrEn(cpu31_nicWrEn),
                         .net_so(n31_pesi), .net_ro(n31_peri), .net_do(n31_pedi),
                         .net_si(n31_peso), .net_ri(n31_pero), .net_di(n31_pedo),
                         .net_polarity(n31_polarity));

    // ============================================================
    // NODE 32
    // ============================================================
    wire [0:63] nic32_dout;
    wire        cpu32_nicEn, cpu32_nicWrEn;
    wire [0:1]  cpu32_nic_addr;

    cardinal_cpu CPU_32 (.clk(clk), .reset(reset),
                         .inst_in(node32_inst_in), .d_in(node32_d_in),
                         .pc_out(node32_pc_out), .addr_out(node32_addr_out),
                         .memEn(node32_memEn), .memWrEn(node32_memWrEn), .d_out(node32_d_out),
                         .nicEn(cpu32_nicEn), .nicWrEn(cpu32_nicWrEn),
                         .nic_addr(cpu32_nic_addr), .nic_d_out(nic32_dout));
    cardinal_nic NIC_32 (.clk(clk), .reset(reset),
                         .addr(cpu32_nic_addr), .d_in(node32_d_out), .d_out(nic32_dout),
                         .nicEn(cpu32_nicEn), .nicWrEn(cpu32_nicWrEn),
                         .net_so(n32_pesi), .net_ro(n32_peri), .net_do(n32_pedi),
                         .net_si(n32_peso), .net_ri(n32_pero), .net_di(n32_pedo),
                         .net_polarity(n32_polarity));

    // ============================================================
    // NODE 33
    // ============================================================
    wire [0:63] nic33_dout;
    wire        cpu33_nicEn, cpu33_nicWrEn;
    wire [0:1]  cpu33_nic_addr;

    cardinal_cpu CPU_33 (.clk(clk), .reset(reset),
                         .inst_in(node33_inst_in), .d_in(node33_d_in),
                         .pc_out(node33_pc_out), .addr_out(node33_addr_out),
                         .memEn(node33_memEn), .memWrEn(node33_memWrEn), .d_out(node33_d_out),
                         .nicEn(cpu33_nicEn), .nicWrEn(cpu33_nicWrEn),
                         .nic_addr(cpu33_nic_addr), .nic_d_out(nic33_dout));
    cardinal_nic NIC_33 (.clk(clk), .reset(reset),
                         .addr(cpu33_nic_addr), .d_in(node33_d_out), .d_out(nic33_dout),
                         .nicEn(cpu33_nicEn), .nicWrEn(cpu33_nicWrEn),
                         .net_so(n33_pesi), .net_ro(n33_peri), .net_do(n33_pedi),
                         .net_si(n33_peso), .net_ri(n33_pero), .net_di(n33_pedo),
                         .net_polarity(n33_polarity));

endmodule