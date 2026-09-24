`timescale 1ns/1ps

// ============================================================
// ALU CONTROL - WITH ISOLATION
// Same workload intended to be used for power comparison
// against the no-isolation testbench.
// ============================================================

module tb_alu_control_iso;

    reg  [3:0] aluop;
    reg  [6:0] func_r;
    reg  [4:0] func_i;
    reg        ALUEnable;

    wire [1:0] mode;
    wire [4:0] control;
    wire       alu_enA, alu_enB, alu_enC;

    integer i;
    integer seed;
    reg [31:0] rnd;

    alu_control dut (
        .aluop      (aluop),
        .func_r     (func_r),
        .func_i     (func_i),
        .ALUEnable  (ALUEnable),
        .mode       (mode),
        .control    (control),
        .alu_enA    (alu_enA),
        .alu_enB    (alu_enB),
        .alu_enC    (alu_enC)
    );

    initial begin
        $dumpfile("alu_control_with_isolation.vcd");
        $dumpvars(0, tb_alu_control_iso);
    end

    initial begin
        // Start disabled
        aluop = 4'b0000;
        func_r = 7'b0;
        func_i = 5'b0;
        ALUEnable = 1'b0;
        #10;

        // -----------------------------------------------------
        // Same deterministic functional workload
        // -----------------------------------------------------
        aluop = 4'b0001; func_r = 7'd0;  func_i = 5'd0;  ALUEnable = 1'b1; #10;
        aluop = 4'b0010; func_r = 7'd0;  func_i = 5'd0;  ALUEnable = 1'b1; #10;
        aluop = 4'b0010; func_r = 7'd12; func_i = 5'd0;  ALUEnable = 1'b1; #10;
        aluop = 4'b0010; func_r = 7'd21; func_i = 5'd0;  ALUEnable = 1'b1; #10;
        aluop = 4'b0100; func_r = 7'd3;  func_i = 5'd0;  ALUEnable = 1'b1; #10;
        aluop = 4'b0101; func_r = 7'd23; func_i = 5'd0;  ALUEnable = 1'b1; #10;
        aluop = 4'b0101; func_r = 7'd24; func_i = 5'd0;  ALUEnable = 1'b1; #10;
        aluop = 4'b0101; func_r = 7'd25; func_i = 5'd0;  ALUEnable = 1'b1; #10;
        aluop = 4'b0101; func_r = 7'd26; func_i = 5'd0;  ALUEnable = 1'b1; #10;
        aluop = 4'b0110; func_r = 7'd27; func_i = 5'd0;  ALUEnable = 1'b1; #10;
        aluop = 4'b0110; func_r = 7'd30; func_i = 5'd0;  ALUEnable = 1'b1; #10;
        aluop = 4'b1000; func_r = 7'd0;  func_i = 5'd6;  ALUEnable = 1'b1; #10;

        // -----------------------------------------------------
        // Same high-switching disabled segment in both TBs
        // -----------------------------------------------------
        for (i = 0; i < 100; i = i + 1) begin
            aluop  = (i * 7 + 3) & 4'hF;
            func_r = (i * 13 + 5) & 7'h7F;
            func_i = (i * 3 + 1) & 5'h1F;
            ALUEnable = 1'b0;
            #5;
        end

        // -----------------------------------------------------
        // Deterministic pseudo-random workload
        // -----------------------------------------------------
        seed = 32'h13579BDF;

        for (i = 0; i < 1000; i = i + 1) begin
            seed = seed * 32'd1664525 + 32'd1013904223;
            rnd       = seed;
            aluop     = rnd[3:0];
            func_r    = rnd[10:4];
            func_i    = rnd[15:11];
            ALUEnable = rnd[16];
            #5;
        end

        #5;
        $finish;
    end

endmodule
