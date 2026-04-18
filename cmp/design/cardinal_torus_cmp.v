// ============================================================
// cardinal_torus_cmp.v
// Top-level 16-core Cardinal Chip Multiprocessor
//
// Internal structure:
//   - One cardinal_mesh (16 routers in 4x4 topology)
//   - 16 nodes, each with: imem, dmem, cardinal_cpu, cardinal_nic
//
// Node naming: RC where R=row(0-3), C=col(0-3)
// Testbench accesses memories via hierarchical references:
//   e.g. tb.CMP.IMEM_00.MEM, tb.CMP.DMEM_00.MEM
// ============================================================

module cardinal_torus_cmp (
    input clk,
    input reset
);

    // ============================================================
    // PE-side wires between cardinal_mesh and NICs (per node)
    // pesi = NIC->router send,  peri = router->NIC ready
    // pedi = NIC->router data
    // peso = router->NIC send,  pero = NIC->router ready
    // pedo = router->NIC data,  polarity = router polarity output
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
    // Cardinal Mesh instantiation
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
    wire [0:31] cpu00_pc, cpu00_addr;
    wire [0:63] cpu00_dout, dmem00_dout, nic00_dout;
    wire        cpu00_memEn, cpu00_memWrEn, cpu00_nicEn, cpu00_nicWrEn;
    wire [0:1]  cpu00_nic_addr;
    wire [0:31] imem00_inst;

    imem         IMEM_00 (.memAddr(cpu00_pc[22:29]),   .dataOut(imem00_inst));
    dmem         DMEM_00 (.clk(clk), .memEn(cpu00_memEn), .memWrEn(cpu00_memWrEn),
                          .memAddr(cpu00_addr[24:31]), .dataIn(cpu00_dout), .dataOut(dmem00_dout));
    cardinal_cpu CPU_00  (.clk(clk), .reset(reset),
                          .inst_in(imem00_inst), .d_in(dmem00_dout),
                          .pc_out(cpu00_pc), .addr_out(cpu00_addr),
                          .memEn(cpu00_memEn), .memWrEn(cpu00_memWrEn), .d_out(cpu00_dout),
                          .nicEn(cpu00_nicEn), .nicWrEn(cpu00_nicWrEn),
                          .nic_addr(cpu00_nic_addr), .nic_d_out(nic00_dout));
    cardinal_nic NIC_00  (.clk(clk), .reset(reset),
                          .addr(cpu00_nic_addr), .d_in(cpu00_dout), .d_out(nic00_dout),
                          .nicEn(cpu00_nicEn), .nicWrEn(cpu00_nicWrEn),
                          .net_so(n00_pesi), .net_ro(n00_peri), .net_do(n00_pedi),
                          .net_si(n00_peso), .net_ri(n00_pero), .net_di(n00_pedo),
                          .net_polarity(n00_polarity));

    // ============================================================
    // NODE 01
    // ============================================================
    wire [0:31] cpu01_pc, cpu01_addr;
    wire [0:63] cpu01_dout, dmem01_dout, nic01_dout;
    wire        cpu01_memEn, cpu01_memWrEn, cpu01_nicEn, cpu01_nicWrEn;
    wire [0:1]  cpu01_nic_addr;
    wire [0:31] imem01_inst;

    imem         IMEM_01 (.memAddr(cpu01_pc[22:29]),   .dataOut(imem01_inst));
    dmem         DMEM_01 (.clk(clk), .memEn(cpu01_memEn), .memWrEn(cpu01_memWrEn),
                          .memAddr(cpu01_addr[24:31]), .dataIn(cpu01_dout), .dataOut(dmem01_dout));
    cardinal_cpu CPU_01  (.clk(clk), .reset(reset),
                          .inst_in(imem01_inst), .d_in(dmem01_dout),
                          .pc_out(cpu01_pc), .addr_out(cpu01_addr),
                          .memEn(cpu01_memEn), .memWrEn(cpu01_memWrEn), .d_out(cpu01_dout),
                          .nicEn(cpu01_nicEn), .nicWrEn(cpu01_nicWrEn),
                          .nic_addr(cpu01_nic_addr), .nic_d_out(nic01_dout));
    cardinal_nic NIC_01  (.clk(clk), .reset(reset),
                          .addr(cpu01_nic_addr), .d_in(cpu01_dout), .d_out(nic01_dout),
                          .nicEn(cpu01_nicEn), .nicWrEn(cpu01_nicWrEn),
                          .net_so(n01_pesi), .net_ro(n01_peri), .net_do(n01_pedi),
                          .net_si(n01_peso), .net_ri(n01_pero), .net_di(n01_pedo),
                          .net_polarity(n01_polarity));

    // ============================================================
    // NODE 02
    // ============================================================
    wire [0:31] cpu02_pc, cpu02_addr;
    wire [0:63] cpu02_dout, dmem02_dout, nic02_dout;
    wire        cpu02_memEn, cpu02_memWrEn, cpu02_nicEn, cpu02_nicWrEn;
    wire [0:1]  cpu02_nic_addr;
    wire [0:31] imem02_inst;

    imem         IMEM_02 (.memAddr(cpu02_pc[22:29]),   .dataOut(imem02_inst));
    dmem         DMEM_02 (.clk(clk), .memEn(cpu02_memEn), .memWrEn(cpu02_memWrEn),
                          .memAddr(cpu02_addr[24:31]), .dataIn(cpu02_dout), .dataOut(dmem02_dout));
    cardinal_cpu CPU_02  (.clk(clk), .reset(reset),
                          .inst_in(imem02_inst), .d_in(dmem02_dout),
                          .pc_out(cpu02_pc), .addr_out(cpu02_addr),
                          .memEn(cpu02_memEn), .memWrEn(cpu02_memWrEn), .d_out(cpu02_dout),
                          .nicEn(cpu02_nicEn), .nicWrEn(cpu02_nicWrEn),
                          .nic_addr(cpu02_nic_addr), .nic_d_out(nic02_dout));
    cardinal_nic NIC_02  (.clk(clk), .reset(reset),
                          .addr(cpu02_nic_addr), .d_in(cpu02_dout), .d_out(nic02_dout),
                          .nicEn(cpu02_nicEn), .nicWrEn(cpu02_nicWrEn),
                          .net_so(n02_pesi), .net_ro(n02_peri), .net_do(n02_pedi),
                          .net_si(n02_peso), .net_ri(n02_pero), .net_di(n02_pedo),
                          .net_polarity(n02_polarity));

    // ============================================================
    // NODE 03
    // ============================================================
    wire [0:31] cpu03_pc, cpu03_addr;
    wire [0:63] cpu03_dout, dmem03_dout, nic03_dout;
    wire        cpu03_memEn, cpu03_memWrEn, cpu03_nicEn, cpu03_nicWrEn;
    wire [0:1]  cpu03_nic_addr;
    wire [0:31] imem03_inst;

    imem         IMEM_03 (.memAddr(cpu03_pc[22:29]),   .dataOut(imem03_inst));
    dmem         DMEM_03 (.clk(clk), .memEn(cpu03_memEn), .memWrEn(cpu03_memWrEn),
                          .memAddr(cpu03_addr[24:31]), .dataIn(cpu03_dout), .dataOut(dmem03_dout));
    cardinal_cpu CPU_03  (.clk(clk), .reset(reset),
                          .inst_in(imem03_inst), .d_in(dmem03_dout),
                          .pc_out(cpu03_pc), .addr_out(cpu03_addr),
                          .memEn(cpu03_memEn), .memWrEn(cpu03_memWrEn), .d_out(cpu03_dout),
                          .nicEn(cpu03_nicEn), .nicWrEn(cpu03_nicWrEn),
                          .nic_addr(cpu03_nic_addr), .nic_d_out(nic03_dout));
    cardinal_nic NIC_03  (.clk(clk), .reset(reset),
                          .addr(cpu03_nic_addr), .d_in(cpu03_dout), .d_out(nic03_dout),
                          .nicEn(cpu03_nicEn), .nicWrEn(cpu03_nicWrEn),
                          .net_so(n03_pesi), .net_ro(n03_peri), .net_do(n03_pedi),
                          .net_si(n03_peso), .net_ri(n03_pero), .net_di(n03_pedo),
                          .net_polarity(n03_polarity));

    // ============================================================
    // NODE 10
    // ============================================================
    wire [0:31] cpu10_pc, cpu10_addr;
    wire [0:63] cpu10_dout, dmem10_dout, nic10_dout;
    wire        cpu10_memEn, cpu10_memWrEn, cpu10_nicEn, cpu10_nicWrEn;
    wire [0:1]  cpu10_nic_addr;
    wire [0:31] imem10_inst;

    imem         IMEM_10 (.memAddr(cpu10_pc[22:29]),   .dataOut(imem10_inst));
    dmem         DMEM_10 (.clk(clk), .memEn(cpu10_memEn), .memWrEn(cpu10_memWrEn),
                          .memAddr(cpu10_addr[24:31]), .dataIn(cpu10_dout), .dataOut(dmem10_dout));
    cardinal_cpu CPU_10  (.clk(clk), .reset(reset),
                          .inst_in(imem10_inst), .d_in(dmem10_dout),
                          .pc_out(cpu10_pc), .addr_out(cpu10_addr),
                          .memEn(cpu10_memEn), .memWrEn(cpu10_memWrEn), .d_out(cpu10_dout),
                          .nicEn(cpu10_nicEn), .nicWrEn(cpu10_nicWrEn),
                          .nic_addr(cpu10_nic_addr), .nic_d_out(nic10_dout));
    cardinal_nic NIC_10  (.clk(clk), .reset(reset),
                          .addr(cpu10_nic_addr), .d_in(cpu10_dout), .d_out(nic10_dout),
                          .nicEn(cpu10_nicEn), .nicWrEn(cpu10_nicWrEn),
                          .net_so(n10_pesi), .net_ro(n10_peri), .net_do(n10_pedi),
                          .net_si(n10_peso), .net_ri(n10_pero), .net_di(n10_pedo),
                          .net_polarity(n10_polarity));

    // ============================================================
    // NODE 11
    // ============================================================
    wire [0:31] cpu11_pc, cpu11_addr;
    wire [0:63] cpu11_dout, dmem11_dout, nic11_dout;
    wire        cpu11_memEn, cpu11_memWrEn, cpu11_nicEn, cpu11_nicWrEn;
    wire [0:1]  cpu11_nic_addr;
    wire [0:31] imem11_inst;

    imem         IMEM_11 (.memAddr(cpu11_pc[22:29]),   .dataOut(imem11_inst));
    dmem         DMEM_11 (.clk(clk), .memEn(cpu11_memEn), .memWrEn(cpu11_memWrEn),
                          .memAddr(cpu11_addr[24:31]), .dataIn(cpu11_dout), .dataOut(dmem11_dout));
    cardinal_cpu CPU_11  (.clk(clk), .reset(reset),
                          .inst_in(imem11_inst), .d_in(dmem11_dout),
                          .pc_out(cpu11_pc), .addr_out(cpu11_addr),
                          .memEn(cpu11_memEn), .memWrEn(cpu11_memWrEn), .d_out(cpu11_dout),
                          .nicEn(cpu11_nicEn), .nicWrEn(cpu11_nicWrEn),
                          .nic_addr(cpu11_nic_addr), .nic_d_out(nic11_dout));
    cardinal_nic NIC_11  (.clk(clk), .reset(reset),
                          .addr(cpu11_nic_addr), .d_in(cpu11_dout), .d_out(nic11_dout),
                          .nicEn(cpu11_nicEn), .nicWrEn(cpu11_nicWrEn),
                          .net_so(n11_pesi), .net_ro(n11_peri), .net_do(n11_pedi),
                          .net_si(n11_peso), .net_ri(n11_pero), .net_di(n11_pedo),
                          .net_polarity(n11_polarity));

    // ============================================================
    // NODE 12
    // ============================================================
    wire [0:31] cpu12_pc, cpu12_addr;
    wire [0:63] cpu12_dout, dmem12_dout, nic12_dout;
    wire        cpu12_memEn, cpu12_memWrEn, cpu12_nicEn, cpu12_nicWrEn;
    wire [0:1]  cpu12_nic_addr;
    wire [0:31] imem12_inst;

    imem         IMEM_12 (.memAddr(cpu12_pc[22:29]),   .dataOut(imem12_inst));
    dmem         DMEM_12 (.clk(clk), .memEn(cpu12_memEn), .memWrEn(cpu12_memWrEn),
                          .memAddr(cpu12_addr[24:31]), .dataIn(cpu12_dout), .dataOut(dmem12_dout));
    cardinal_cpu CPU_12  (.clk(clk), .reset(reset),
                          .inst_in(imem12_inst), .d_in(dmem12_dout),
                          .pc_out(cpu12_pc), .addr_out(cpu12_addr),
                          .memEn(cpu12_memEn), .memWrEn(cpu12_memWrEn), .d_out(cpu12_dout),
                          .nicEn(cpu12_nicEn), .nicWrEn(cpu12_nicWrEn),
                          .nic_addr(cpu12_nic_addr), .nic_d_out(nic12_dout));
    cardinal_nic NIC_12  (.clk(clk), .reset(reset),
                          .addr(cpu12_nic_addr), .d_in(cpu12_dout), .d_out(nic12_dout),
                          .nicEn(cpu12_nicEn), .nicWrEn(cpu12_nicWrEn),
                          .net_so(n12_pesi), .net_ro(n12_peri), .net_do(n12_pedi),
                          .net_si(n12_peso), .net_ri(n12_pero), .net_di(n12_pedo),
                          .net_polarity(n12_polarity));

    // ============================================================
    // NODE 13
    // ============================================================
    wire [0:31] cpu13_pc, cpu13_addr;
    wire [0:63] cpu13_dout, dmem13_dout, nic13_dout;
    wire        cpu13_memEn, cpu13_memWrEn, cpu13_nicEn, cpu13_nicWrEn;
    wire [0:1]  cpu13_nic_addr;
    wire [0:31] imem13_inst;

    imem         IMEM_13 (.memAddr(cpu13_pc[22:29]),   .dataOut(imem13_inst));
    dmem         DMEM_13 (.clk(clk), .memEn(cpu13_memEn), .memWrEn(cpu13_memWrEn),
                          .memAddr(cpu13_addr[24:31]), .dataIn(cpu13_dout), .dataOut(dmem13_dout));
    cardinal_cpu CPU_13  (.clk(clk), .reset(reset),
                          .inst_in(imem13_inst), .d_in(dmem13_dout),
                          .pc_out(cpu13_pc), .addr_out(cpu13_addr),
                          .memEn(cpu13_memEn), .memWrEn(cpu13_memWrEn), .d_out(cpu13_dout),
                          .nicEn(cpu13_nicEn), .nicWrEn(cpu13_nicWrEn),
                          .nic_addr(cpu13_nic_addr), .nic_d_out(nic13_dout));
    cardinal_nic NIC_13  (.clk(clk), .reset(reset),
                          .addr(cpu13_nic_addr), .d_in(cpu13_dout), .d_out(nic13_dout),
                          .nicEn(cpu13_nicEn), .nicWrEn(cpu13_nicWrEn),
                          .net_so(n13_pesi), .net_ro(n13_peri), .net_do(n13_pedi),
                          .net_si(n13_peso), .net_ri(n13_pero), .net_di(n13_pedo),
                          .net_polarity(n13_polarity));

    // ============================================================
    // NODE 20
    // ============================================================
    wire [0:31] cpu20_pc, cpu20_addr;
    wire [0:63] cpu20_dout, dmem20_dout, nic20_dout;
    wire        cpu20_memEn, cpu20_memWrEn, cpu20_nicEn, cpu20_nicWrEn;
    wire [0:1]  cpu20_nic_addr;
    wire [0:31] imem20_inst;

    imem         IMEM_20 (.memAddr(cpu20_pc[22:29]),   .dataOut(imem20_inst));
    dmem         DMEM_20 (.clk(clk), .memEn(cpu20_memEn), .memWrEn(cpu20_memWrEn),
                          .memAddr(cpu20_addr[24:31]), .dataIn(cpu20_dout), .dataOut(dmem20_dout));
    cardinal_cpu CPU_20  (.clk(clk), .reset(reset),
                          .inst_in(imem20_inst), .d_in(dmem20_dout),
                          .pc_out(cpu20_pc), .addr_out(cpu20_addr),
                          .memEn(cpu20_memEn), .memWrEn(cpu20_memWrEn), .d_out(cpu20_dout),
                          .nicEn(cpu20_nicEn), .nicWrEn(cpu20_nicWrEn),
                          .nic_addr(cpu20_nic_addr), .nic_d_out(nic20_dout));
    cardinal_nic NIC_20  (.clk(clk), .reset(reset),
                          .addr(cpu20_nic_addr), .d_in(cpu20_dout), .d_out(nic20_dout),
                          .nicEn(cpu20_nicEn), .nicWrEn(cpu20_nicWrEn),
                          .net_so(n20_pesi), .net_ro(n20_peri), .net_do(n20_pedi),
                          .net_si(n20_peso), .net_ri(n20_pero), .net_di(n20_pedo),
                          .net_polarity(n20_polarity));

    // ============================================================
    // NODE 21
    // ============================================================
    wire [0:31] cpu21_pc, cpu21_addr;
    wire [0:63] cpu21_dout, dmem21_dout, nic21_dout;
    wire        cpu21_memEn, cpu21_memWrEn, cpu21_nicEn, cpu21_nicWrEn;
    wire [0:1]  cpu21_nic_addr;
    wire [0:31] imem21_inst;

    imem         IMEM_21 (.memAddr(cpu21_pc[22:29]),   .dataOut(imem21_inst));
    dmem         DMEM_21 (.clk(clk), .memEn(cpu21_memEn), .memWrEn(cpu21_memWrEn),
                          .memAddr(cpu21_addr[24:31]), .dataIn(cpu21_dout), .dataOut(dmem21_dout));
    cardinal_cpu CPU_21  (.clk(clk), .reset(reset),
                          .inst_in(imem21_inst), .d_in(dmem21_dout),
                          .pc_out(cpu21_pc), .addr_out(cpu21_addr),
                          .memEn(cpu21_memEn), .memWrEn(cpu21_memWrEn), .d_out(cpu21_dout),
                          .nicEn(cpu21_nicEn), .nicWrEn(cpu21_nicWrEn),
                          .nic_addr(cpu21_nic_addr), .nic_d_out(nic21_dout));
    cardinal_nic NIC_21  (.clk(clk), .reset(reset),
                          .addr(cpu21_nic_addr), .d_in(cpu21_dout), .d_out(nic21_dout),
                          .nicEn(cpu21_nicEn), .nicWrEn(cpu21_nicWrEn),
                          .net_so(n21_pesi), .net_ro(n21_peri), .net_do(n21_pedi),
                          .net_si(n21_peso), .net_ri(n21_pero), .net_di(n21_pedo),
                          .net_polarity(n21_polarity));

    // ============================================================
    // NODE 22
    // ============================================================
    wire [0:31] cpu22_pc, cpu22_addr;
    wire [0:63] cpu22_dout, dmem22_dout, nic22_dout;
    wire        cpu22_memEn, cpu22_memWrEn, cpu22_nicEn, cpu22_nicWrEn;
    wire [0:1]  cpu22_nic_addr;
    wire [0:31] imem22_inst;

    imem         IMEM_22 (.memAddr(cpu22_pc[22:29]),   .dataOut(imem22_inst));
    dmem         DMEM_22 (.clk(clk), .memEn(cpu22_memEn), .memWrEn(cpu22_memWrEn),
                          .memAddr(cpu22_addr[24:31]), .dataIn(cpu22_dout), .dataOut(dmem22_dout));
    cardinal_cpu CPU_22  (.clk(clk), .reset(reset),
                          .inst_in(imem22_inst), .d_in(dmem22_dout),
                          .pc_out(cpu22_pc), .addr_out(cpu22_addr),
                          .memEn(cpu22_memEn), .memWrEn(cpu22_memWrEn), .d_out(cpu22_dout),
                          .nicEn(cpu22_nicEn), .nicWrEn(cpu22_nicWrEn),
                          .nic_addr(cpu22_nic_addr), .nic_d_out(nic22_dout));
    cardinal_nic NIC_22  (.clk(clk), .reset(reset),
                          .addr(cpu22_nic_addr), .d_in(cpu22_dout), .d_out(nic22_dout),
                          .nicEn(cpu22_nicEn), .nicWrEn(cpu22_nicWrEn),
                          .net_so(n22_pesi), .net_ro(n22_peri), .net_do(n22_pedi),
                          .net_si(n22_peso), .net_ri(n22_pero), .net_di(n22_pedo),
                          .net_polarity(n22_polarity));

    // ============================================================
    // NODE 23
    // ============================================================
    wire [0:31] cpu23_pc, cpu23_addr;
    wire [0:63] cpu23_dout, dmem23_dout, nic23_dout;
    wire        cpu23_memEn, cpu23_memWrEn, cpu23_nicEn, cpu23_nicWrEn;
    wire [0:1]  cpu23_nic_addr;
    wire [0:31] imem23_inst;

    imem         IMEM_23 (.memAddr(cpu23_pc[22:29]),   .dataOut(imem23_inst));
    dmem         DMEM_23 (.clk(clk), .memEn(cpu23_memEn), .memWrEn(cpu23_memWrEn),
                          .memAddr(cpu23_addr[24:31]), .dataIn(cpu23_dout), .dataOut(dmem23_dout));
    cardinal_cpu CPU_23  (.clk(clk), .reset(reset),
                          .inst_in(imem23_inst), .d_in(dmem23_dout),
                          .pc_out(cpu23_pc), .addr_out(cpu23_addr),
                          .memEn(cpu23_memEn), .memWrEn(cpu23_memWrEn), .d_out(cpu23_dout),
                          .nicEn(cpu23_nicEn), .nicWrEn(cpu23_nicWrEn),
                          .nic_addr(cpu23_nic_addr), .nic_d_out(nic23_dout));
    cardinal_nic NIC_23  (.clk(clk), .reset(reset),
                          .addr(cpu23_nic_addr), .d_in(cpu23_dout), .d_out(nic23_dout),
                          .nicEn(cpu23_nicEn), .nicWrEn(cpu23_nicWrEn),
                          .net_so(n23_pesi), .net_ro(n23_peri), .net_do(n23_pedi),
                          .net_si(n23_peso), .net_ri(n23_pero), .net_di(n23_pedo),
                          .net_polarity(n23_polarity));

    // ============================================================
    // NODE 30
    // ============================================================
    wire [0:31] cpu30_pc, cpu30_addr;
    wire [0:63] cpu30_dout, dmem30_dout, nic30_dout;
    wire        cpu30_memEn, cpu30_memWrEn, cpu30_nicEn, cpu30_nicWrEn;
    wire [0:1]  cpu30_nic_addr;
    wire [0:31] imem30_inst;

    imem         IMEM_30 (.memAddr(cpu30_pc[22:29]),   .dataOut(imem30_inst));
    dmem         DMEM_30 (.clk(clk), .memEn(cpu30_memEn), .memWrEn(cpu30_memWrEn),
                          .memAddr(cpu30_addr[24:31]), .dataIn(cpu30_dout), .dataOut(dmem30_dout));
    cardinal_cpu CPU_30  (.clk(clk), .reset(reset),
                          .inst_in(imem30_inst), .d_in(dmem30_dout),
                          .pc_out(cpu30_pc), .addr_out(cpu30_addr),
                          .memEn(cpu30_memEn), .memWrEn(cpu30_memWrEn), .d_out(cpu30_dout),
                          .nicEn(cpu30_nicEn), .nicWrEn(cpu30_nicWrEn),
                          .nic_addr(cpu30_nic_addr), .nic_d_out(nic30_dout));
    cardinal_nic NIC_30  (.clk(clk), .reset(reset),
                          .addr(cpu30_nic_addr), .d_in(cpu30_dout), .d_out(nic30_dout),
                          .nicEn(cpu30_nicEn), .nicWrEn(cpu30_nicWrEn),
                          .net_so(n30_pesi), .net_ro(n30_peri), .net_do(n30_pedi),
                          .net_si(n30_peso), .net_ri(n30_pero), .net_di(n30_pedo),
                          .net_polarity(n30_polarity));

    // ============================================================
    // NODE 31
    // ============================================================
    wire [0:31] cpu31_pc, cpu31_addr;
    wire [0:63] cpu31_dout, dmem31_dout, nic31_dout;
    wire        cpu31_memEn, cpu31_memWrEn, cpu31_nicEn, cpu31_nicWrEn;
    wire [0:1]  cpu31_nic_addr;
    wire [0:31] imem31_inst;

    imem         IMEM_31 (.memAddr(cpu31_pc[22:29]),   .dataOut(imem31_inst));
    dmem         DMEM_31 (.clk(clk), .memEn(cpu31_memEn), .memWrEn(cpu31_memWrEn),
                          .memAddr(cpu31_addr[24:31]), .dataIn(cpu31_dout), .dataOut(dmem31_dout));
    cardinal_cpu CPU_31  (.clk(clk), .reset(reset),
                          .inst_in(imem31_inst), .d_in(dmem31_dout),
                          .pc_out(cpu31_pc), .addr_out(cpu31_addr),
                          .memEn(cpu31_memEn), .memWrEn(cpu31_memWrEn), .d_out(cpu31_dout),
                          .nicEn(cpu31_nicEn), .nicWrEn(cpu31_nicWrEn),
                          .nic_addr(cpu31_nic_addr), .nic_d_out(nic31_dout));
    cardinal_nic NIC_31  (.clk(clk), .reset(reset),
                          .addr(cpu31_nic_addr), .d_in(cpu31_dout), .d_out(nic31_dout),
                          .nicEn(cpu31_nicEn), .nicWrEn(cpu31_nicWrEn),
                          .net_so(n31_pesi), .net_ro(n31_peri), .net_do(n31_pedi),
                          .net_si(n31_peso), .net_ri(n31_pero), .net_di(n31_pedo),
                          .net_polarity(n31_polarity));

    // ============================================================
    // NODE 32
    // ============================================================
    wire [0:31] cpu32_pc, cpu32_addr;
    wire [0:63] cpu32_dout, dmem32_dout, nic32_dout;
    wire        cpu32_memEn, cpu32_memWrEn, cpu32_nicEn, cpu32_nicWrEn;
    wire [0:1]  cpu32_nic_addr;
    wire [0:31] imem32_inst;

    imem         IMEM_32 (.memAddr(cpu32_pc[22:29]),   .dataOut(imem32_inst));
    dmem         DMEM_32 (.clk(clk), .memEn(cpu32_memEn), .memWrEn(cpu32_memWrEn),
                          .memAddr(cpu32_addr[24:31]), .dataIn(cpu32_dout), .dataOut(dmem32_dout));
    cardinal_cpu CPU_32  (.clk(clk), .reset(reset),
                          .inst_in(imem32_inst), .d_in(dmem32_dout),
                          .pc_out(cpu32_pc), .addr_out(cpu32_addr),
                          .memEn(cpu32_memEn), .memWrEn(cpu32_memWrEn), .d_out(cpu32_dout),
                          .nicEn(cpu32_nicEn), .nicWrEn(cpu32_nicWrEn),
                          .nic_addr(cpu32_nic_addr), .nic_d_out(nic32_dout));
    cardinal_nic NIC_32  (.clk(clk), .reset(reset),
                          .addr(cpu32_nic_addr), .d_in(cpu32_dout), .d_out(nic32_dout),
                          .nicEn(cpu32_nicEn), .nicWrEn(cpu32_nicWrEn),
                          .net_so(n32_pesi), .net_ro(n32_peri), .net_do(n32_pedi),
                          .net_si(n32_peso), .net_ri(n32_pero), .net_di(n32_pedo),
                          .net_polarity(n32_polarity));

    // ============================================================
    // NODE 33
    // ============================================================
    wire [0:31] cpu33_pc, cpu33_addr;
    wire [0:63] cpu33_dout, dmem33_dout, nic33_dout;
    wire        cpu33_memEn, cpu33_memWrEn, cpu33_nicEn, cpu33_nicWrEn;
    wire [0:1]  cpu33_nic_addr;
    wire [0:31] imem33_inst;

    imem         IMEM_33 (.memAddr(cpu33_pc[22:29]),   .dataOut(imem33_inst));
    dmem         DMEM_33 (.clk(clk), .memEn(cpu33_memEn), .memWrEn(cpu33_memWrEn),
                          .memAddr(cpu33_addr[24:31]), .dataIn(cpu33_dout), .dataOut(dmem33_dout));
    cardinal_cpu CPU_33  (.clk(clk), .reset(reset),
                          .inst_in(imem33_inst), .d_in(dmem33_dout),
                          .pc_out(cpu33_pc), .addr_out(cpu33_addr),
                          .memEn(cpu33_memEn), .memWrEn(cpu33_memWrEn), .d_out(cpu33_dout),
                          .nicEn(cpu33_nicEn), .nicWrEn(cpu33_nicWrEn),
                          .nic_addr(cpu33_nic_addr), .nic_d_out(nic33_dout));
    cardinal_nic NIC_33  (.clk(clk), .reset(reset),
                          .addr(cpu33_nic_addr), .d_in(cpu33_dout), .d_out(nic33_dout),
                          .nicEn(cpu33_nicEn), .nicWrEn(cpu33_nicWrEn),
                          .net_so(n33_pesi), .net_ro(n33_peri), .net_do(n33_pedi),
                          .net_si(n33_peso), .net_ri(n33_pero), .net_di(n33_pedo),
                          .net_polarity(n33_polarity));

endmodule