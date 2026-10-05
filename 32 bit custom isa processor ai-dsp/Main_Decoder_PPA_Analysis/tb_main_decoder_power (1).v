`timescale 1ns/1ps

// Gate-level power-analysis testbench for main_decoder
// Exercises every valid opcode and every branch function.
// Generates VCD activity for OpenSTA power analysis.

module tb_main_decoder_power;

    reg  [4:0] opcode;
    reg  [4:0] func;

    wire [3:0] aluop;
    wire       regwrite1, regwrite2;
    wire       regread1, regread2, regread3;
    wire       memwrite, memread;
    wire       Aluenable;
    wire       alumuxen1, alumuxsel1;
    wire       resulten;
    wire [1:0] resultsel;
    wire [2:0] ImmType;
    wire [1:0] ImmMode;
    wire       ImmEnable;
    wire       branch, branchrs1, branchrs2;
    wire [4:0] branchtype;
    wire       jump, jalr, link;

    main_decoder dut (
        .opcode(opcode),
        .func(func),
        .aluop(aluop),
        .regwrite1(regwrite1),
        .regwrite2(regwrite2),
        .regread1(regread1),
        .regread2(regread2),
        .regread3(regread3),
        .memwrite(memwrite),
        .memread(memread),
        .Aluenable(Aluenable),
        .alumuxen1(alumuxen1),
        .alumuxsel1(alumuxsel1),
        .resulten(resulten),
        .resultsel(resultsel),
        .ImmType(ImmType),
        .ImmMode(ImmMode),
        .ImmEnable(ImmEnable),
        .branch(branch),
        .branchrs1(branchrs1),
        .branchrs2(branchrs2),
        .branchtype(branchtype),
        .jump(jump),
        .jalr(jalr),
        .link(link)
    );

    // 100 MHz reference clock for the power-analysis workload.
    // The decoder itself is combinational; the clock sequences input
    // transitions so that a repeatable VCD workload is generated.
    reg clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Change decoder inputs on clock edges to create clean activity.

    task show_outputs;
        begin
            $display("---------------------------------------------------------------");
            $display("TIME=%0t ns | OPCODE=%05b | FUNC=%05b", $time, opcode, func);
            $display(" ALUOP=%04b | REGW1=%b | REGW2=%b | MEMR=%b | MEMW=%b",
                     aluop, regwrite1, regwrite2, memread, memwrite);
            $display(" ALUMUXSEL=%b | RESULTSEL=%02b | IMMTYPE=%03b | IMMMODE=%02b",
                     alumuxsel1, resultsel, ImmType, ImmMode);
            $display(" BRANCH=%b | BRANCHTYPE=%05b | JUMP=%b | JALR=%b | LINK=%b",
                     branch, branchtype, jump, jalr, link);
            $display("---------------------------------------------------------------");
        end
    endtask

    task apply_opcode;
        input [4:0] op;
        input [4:0] fn;
        begin
            @(negedge clk);
            opcode = op;
            func   = fn;
            #2;
            show_outputs;
        end
    endtask

    integer i;

    initial begin
        $dumpfile("main_decoder_workload.vcd");
        $dumpvars(0, tb_main_decoder_power);

        opcode = 5'b00000;
        func   = 5'b00000;

        // ---------------------------------------------------------
        // Initial settling
        // ---------------------------------------------------------
        repeat (2) @(posedge clk);

        // ---------------------------------------------------------
        // R4 TYPE
        // ---------------------------------------------------------
        apply_opcode(5'b00001, 5'b00000);
        apply_opcode(5'b00001, 5'b00101);
        apply_opcode(5'b00001, 5'b11111);

        // ---------------------------------------------------------
        // R3 TYPE
        // ---------------------------------------------------------
        apply_opcode(5'b00010, 5'b00000);
        apply_opcode(5'b00010, 5'b01010);
        apply_opcode(5'b00010, 5'b11111);

        // ---------------------------------------------------------
        // R3I TYPE
        // ---------------------------------------------------------
        apply_opcode(5'b00011, 5'b00000);
        apply_opcode(5'b00011, 5'b00111);
        apply_opcode(5'b00011, 5'b11111);

        // ---------------------------------------------------------
        // R4 MOVE TYPE
        // ---------------------------------------------------------
        apply_opcode(5'b01000, 5'b00000);
        apply_opcode(5'b01000, 5'b10101);

        // ---------------------------------------------------------
        // R2 TYPE
        // ---------------------------------------------------------
        apply_opcode(5'b01011, 5'b00000);
        apply_opcode(5'b01011, 5'b11010);

        // ---------------------------------------------------------
        // R2 MOV TYPE
        // ---------------------------------------------------------
        apply_opcode(5'b01010, 5'b00000);
        apply_opcode(5'b01010, 5'b10110);

        // ---------------------------------------------------------
        // I TYPE
        // ---------------------------------------------------------
        apply_opcode(5'b00100, 5'b00000);
        apply_opcode(5'b00100, 5'b01011);
        apply_opcode(5'b00100, 5'b11111);

        // ---------------------------------------------------------
        // LOAD WORD
        // ---------------------------------------------------------
        apply_opcode(5'b00111, 5'b00000);
        apply_opcode(5'b00111, 5'b10101);

        // ---------------------------------------------------------
        // STORE WORD
        // ---------------------------------------------------------
        apply_opcode(5'b00101, 5'b00000);
        apply_opcode(5'b00101, 5'b11001);

        // ---------------------------------------------------------
        // Branch: all 12 valid branch functions
        // ---------------------------------------------------------
        apply_opcode(5'b00110, 5'd1);   // BEQ
        apply_opcode(5'b00110, 5'd2);   // BNEQ
        apply_opcode(5'b00110, 5'd3);   // BGT
        apply_opcode(5'b00110, 5'd4);   // BLT
        apply_opcode(5'b00110, 5'd5);   // BGST
        apply_opcode(5'b00110, 5'd6);   // BLST
        apply_opcode(5'b00110, 5'd7);   // BLTZ
        apply_opcode(5'b00110, 5'd8);   // BGTZ
        apply_opcode(5'b00110, 5'd9);   // BGEZ
        apply_opcode(5'b00110, 5'd10);  // BLEZ
        apply_opcode(5'b00110, 5'd11);  // BEQZ
        apply_opcode(5'b00110, 5'd12);  // BNEZ

        // Invalid branch function
        apply_opcode(5'b00110, 5'd31);

        // ---------------------------------------------------------
        // JALR
        // ---------------------------------------------------------
        apply_opcode(5'b01111, 5'b00000);
        apply_opcode(5'b01111, 5'b10101);

        // ---------------------------------------------------------
        // JAL
        // ---------------------------------------------------------
        apply_opcode(5'b11110, 5'b00000);
        apply_opcode(5'b11110, 5'b11111);

        // ---------------------------------------------------------
        // Repeated mixed workload to increase switching activity.
        // ---------------------------------------------------------
        for (i = 0; i < 3; i = i + 1) begin
            apply_opcode(5'b00001, 5'b00101);
            apply_opcode(5'b00011, 5'b11010);
            apply_opcode(5'b00100, 5'b01010);
            apply_opcode(5'b00111, 5'b00011);
            apply_opcode(5'b00101, 5'b10110);
            apply_opcode(5'b00110, 5'd1);
            apply_opcode(5'b00110, 5'd7);
            apply_opcode(5'b01111, 5'b01001);
            apply_opcode(5'b11110, 5'b10101);
            apply_opcode(5'b01000, 5'b00010);
            apply_opcode(5'b01011, 5'b11100);
            apply_opcode(5'b01010, 5'b01111);
            apply_opcode(5'b00010, 5'b10001);
        end

        // ---------------------------------------------------------
        // Invalid opcodes to exercise default decode logic.
        // ---------------------------------------------------------
        apply_opcode(5'b00000, 5'b00000);
        apply_opcode(5'b01101, 5'b10101);
        apply_opcode(5'b10000, 5'b11111);
        apply_opcode(5'b11111, 5'b00001);

        repeat (3) @(posedge clk);

        $display("==============================================");
        $display(" Main Decoder Gate-Level Power Workload Done ");
        $display(" VCD: main_decoder_workload.vcd");
        $display("==============================================");

        $finish;
    end

endmodule
