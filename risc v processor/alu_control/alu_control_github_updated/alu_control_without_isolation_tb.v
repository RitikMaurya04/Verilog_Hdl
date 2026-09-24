`timescale 1ns/1ps

// ============================================================
// ALU CONTROL - WITHOUT ISOLATION
// Same aluop/func workload and timing as the isolation TB.
// No ALUEnable signal exists in this version.
// ============================================================

module tb_alu_control_noiso;

    reg  [3:0] aluop;
    reg  [6:0] func_r;
    reg  [4:0] func_i;

    wire [1:0] mode;
    wire [4:0] control;
    wire       alu_enA, alu_enB, alu_enC;

    integer i;
    integer seed;
    reg [31:0] rnd;

    alu_control_noiso dut (
        .aluop      (aluop),
        .func_r     (func_r),
        .func_i     (func_i),
        .mode       (mode),
        .control    (control),
        .alu_enA    (alu_enA),
        .alu_enB    (alu_enB),
        .alu_enC    (alu_enC)
    );

    initial begin
        $dumpfile("alu_control_without_isolation.vcd");
        $dumpvars(0, tb_alu_control_noiso);
    end

    initial begin
        aluop = 4'b0000;
        func_r = 7'b0;
        func_i = 5'b0;
        #10;

        // Same deterministic functional workload
        aluop = 4'b0001; func_r = 7'd0;  func_i = 5'd0;  #10;
        aluop = 4'b0010; func_r = 7'd0;  func_i = 5'd0;  #10;
        aluop = 4'b0010; func_r = 7'd12; func_i = 5'd0;  #10;
        aluop = 4'b0010; func_r = 7'd21; func_i = 5'd0;  #10;
        aluop = 4'b0100; func_r = 7'd3;  func_i = 5'd0;  #10;
        aluop = 4'b0101; func_r = 7'd23; func_i = 5'd0;  #10;
        aluop = 4'b0101; func_r = 7'd24; func_i = 5'd0;  #10;
        aluop = 4'b0101; func_r = 7'd25; func_i = 5'd0;  #10;
        aluop = 4'b0101; func_r = 7'd26; func_i = 5'd0;  #10;
        aluop = 4'b0110; func_r = 7'd27; func_i = 5'd0;  #10;
        aluop = 4'b0110; func_r = 7'd30; func_i = 5'd0;  #10;
        aluop = 4'b1000; func_r = 7'd0;  func_i = 5'd6;  #10;

        // Same high-switching disabled-segment inputs, but here
        // there is no isolation, so these inputs directly enter
        // the decode logic.
        for (i = 0; i < 100; i = i + 1) begin
            aluop  = (i * 7 + 3) & 4'hF;
            func_r = (i * 13 + 5) & 7'h7F;
            func_i = (i * 3 + 1) & 5'h1F;
            #5;
        end

        // Same deterministic pseudo-random workload
        seed = 32'h13579BDF;

        for (i = 0; i < 1000; i = i + 1) begin
            seed = seed * 32'd1664525 + 32'd1013904223;
            rnd       = seed;
            aluop     = rnd[3:0];
            func_r    = rnd[10:4];
            func_i    = rnd[15:11];
            #5;
        end

        #5;
        $finish;
    end

endmodule
