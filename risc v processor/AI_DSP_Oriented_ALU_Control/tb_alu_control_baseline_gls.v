`timescale 1ns/1ps

// ============================================================
// Gate-Level Self-Checking Testbench for BASELINE ALU CONTROL
//
// DUT:
//   alu_control_baseline
//
// Baseline version:
//   - No AluEnable input
//   - No operand-enable outputs
//   - Direct decoding of aluop / func_r / func_i
//
// The functional stimulus is kept equivalent to the enable-version
// ALU-control testbench so the resulting VCD can be used for a
// fair power comparison.
// ============================================================

module tb_alu_control_baseline_gls;

    reg  [3:0] aluop;
    reg  [6:0] func_r;
    reg  [4:0] func_i;

    // Reference-only enable signal used only to mirror the
    // optimized testbench workload. It is not connected to the
    // baseline DUT.
    reg        AluEnable_ref;

    wire [1:0] mode;
    wire [4:0] control;

    integer errors;
    integer tests;
    integer k;

    // ---------------------------------------------------------
    // DUT
    // ---------------------------------------------------------
    alu_control_baseline dut (
        .aluop   (aluop),
        .func_r  (func_r),
        .func_i  (func_i),
        .mode    (mode),
        .control (control)
    );

    // ---------------------------------------------------------
    // Generic checker
    // ---------------------------------------------------------
    task check_outputs;
        input [127:0] name;
        input [1:0]   exp_mode;
        input [4:0]   exp_control;

        begin
            #2;
            tests = tests + 1;

            if ((mode !== exp_mode) || (control !== exp_control)) begin
                $display("[FAIL] %-24s | aluop=%b func_r=%b func_i=%b | mode=%b/%b control=%b/%b",
                         name,
                         aluop, func_r, func_i,
                         mode, exp_mode,
                         control, exp_control);
                errors = errors + 1;
            end
            else begin
                $display("[PASS] %-24s | mode=%b control=%b",
                         name, mode, control);
            end
        end
    endtask

    // ---------------------------------------------------------
    // R4 tests
    // ---------------------------------------------------------
    task test_r4;
        input [127:0] name;
        input [6:0]   f;
        input [4:0]   c;

        begin
            aluop  = 4'b0010;
            func_r = f;
            func_i = 5'b00000;

            check_outputs(name, 2'b00, c);
        end
    endtask

    // ---------------------------------------------------------
    // R3I tests
    // ---------------------------------------------------------
    task test_r3i;
        input [127:0] name;
        input [6:0]   f;
        input [4:0]   c;

        begin
            aluop  = 4'b0100;
            func_r = f;
            func_i = 5'b00000;

            check_outputs(name, 2'b00, c);
        end
    endtask

    // ---------------------------------------------------------
    // R3 / AI tests
    // ---------------------------------------------------------
    task test_r3;
        input [127:0] name;
        input [6:0]   f;
        input [4:0]   c;

        begin
            aluop  = 4'b0101;
            func_r = f;
            func_i = 5'b00000;

            check_outputs(name, 2'b01, c);
        end
    endtask

    // ---------------------------------------------------------
    // R2 tests
    // ---------------------------------------------------------
    task test_r2;
        input [127:0] name;
        input [6:0]   f;
        input [4:0]   c;

        begin
            aluop  = 4'b0110;
            func_r = f;
            func_i = 5'b00000;

            check_outputs(name, 2'b10, c);
        end
    endtask

    // ---------------------------------------------------------
    // I-type tests
    // ---------------------------------------------------------
    task test_i;
        input [127:0] name;
        input [4:0]   f;
        input [4:0]   c;

        begin
            aluop  = 4'b1000;
            func_r = 7'b0000000;
            func_i = f;

            check_outputs(name, 2'b11, c);
        end
    endtask

    initial begin
        errors = 0;
        tests  = 0;

        // Initial values
        aluop          = 4'b0000;
        func_r         = 7'b0000000;
        func_i         = 5'b00000;
        AluEnable_ref  = 1'b0;

        // VCD for OpenSTA power analysis
        $dumpfile("alu_control_baseline_gls.vcd");
        $dumpvars(0, tb_alu_control_baseline_gls);

        // =====================================================
        // 1. SAME IDLE / DISABLED WORKLOAD AS ENABLE VERSION
        //
        // The baseline DUT has no AluEnable input, so these vectors
        // are NOT functionally checked as "disabled" states.
        // They are included only to reproduce the same input/control
        // activity seen by the optimized design when AluEnable=0.
        // =====================================================

        // Optimized version: AluEnable=0
        AluEnable_ref = 1'b0;
        aluop         = 4'b0010;
        func_r        = 7'b1111111;
        func_i        = 5'b11111;
        #2;

        // Optimized version: AluEnable=0
        AluEnable_ref = 1'b0;
        aluop         = 4'b0101;
        func_r        = 7'b1011010;
        func_i        = 5'b10110;
        #2;

        // Optimized version: AluEnable=0
        AluEnable_ref = 1'b0;
        aluop         = 4'b1000;
        func_r        = 7'b0101010;
        func_i        = 5'b10011;
        #2;

        // =====================================================
        // 2. LOAD / STORE
        // =====================================================
        aluop  = 4'b0001;
        func_r = 7'b1111111;
        func_i = 5'b11111;

        check_outputs("LOAD / STORE",
                      2'b11, 5'b00000);

        // =====================================================
        // 3. R4
        // =====================================================
        test_r4("R4 ADD",          7'b0000000, 5'b00000);
        test_r4("R4 SUB",          7'b0000001, 5'b00001);
        test_r4("R4 OR",           7'b0000010, 5'b00010);
        test_r4("R4 AND",          7'b0000011, 5'b00011);
        test_r4("R4 NAND",         7'b0000100, 5'b00100);
        test_r4("R4 NOR",          7'b0000101, 5'b00101);
        test_r4("R4 XOR",          7'b0000110, 5'b00110);
        test_r4("R4 XNOR",         7'b0000111, 5'b00111);
        test_r4("R4 XOR_AND",      7'b0001000, 5'b10110);
        test_r4("R4 NOT_AND_XOR",  7'b0001001, 5'b10101);
        test_r4("R4 NOT_OR_AND",   7'b0001010, 5'b11001);
        test_r4("R4 AND_NOT2",     7'b0001011, 5'b11010);
        test_r4("R4 INC",          7'b0001100, 5'b01001);
        test_r4("R4 DEC",          7'b0001101, 5'b01010);
        test_r4("R4 MAX",          7'b0010011, 5'b01100);
        test_r4("R4 MIN",          7'b0010100, 5'b01101);
        test_r4("R4 MAC",          7'b0010101, 5'b01110);
        test_r4("R4 MSC",          7'b0010110, 5'b01111);

        // R4 MOV
        aluop  = 4'b0011;
        func_r = 7'b1111111;
        func_i = 5'b11111;

        check_outputs("R4 MOV",
                      2'b11, 5'b11110);

        // =====================================================
        // 4. R3I
        // =====================================================
        test_r3i("R3I ADD",         7'b0000000, 5'b00000);
        test_r3i("R3I SUB",         7'b0000001, 5'b00001);
        test_r3i("R3I OR",          7'b0000010, 5'b00010);
        test_r3i("R3I AND",         7'b0000011, 5'b00011);
        test_r3i("R3I NAND",        7'b0000100, 5'b00100);
        test_r3i("R3I NOR",         7'b0000101, 5'b00101);
        test_r3i("R3I XOR",         7'b0000110, 5'b00110);
        test_r3i("R3I XNOR",        7'b0000111, 5'b00111);
        test_r3i("R3I INC",         7'b0001100, 5'b01001);
        test_r3i("R3I DEC",         7'b0001101, 5'b01010);
        test_r3i("R3I MAX",         7'b0010011, 5'b01100);
        test_r3i("R3I MIN",         7'b0010100, 5'b01101);
        test_r3i("R3I MAC",         7'b0010101, 5'b01110);
        test_r3i("R3I MSC",         7'b0010110, 5'b01111);

        // =====================================================
        // 5. R3 / AI
        // =====================================================
        test_r3("R3 ADD",           7'b0000000, 5'b00000);
        test_r3("R3 SUB",           7'b0000001, 5'b00001);
        test_r3("R3 OR",            7'b0000010, 5'b00010);
        test_r3("R3 AND",           7'b0000011, 5'b00011);
        test_r3("R3 NAND",          7'b0000100, 5'b00100);
        test_r3("R3 NOR",           7'b0000101, 5'b00101);
        test_r3("R3 XOR",           7'b0000110, 5'b00110);
        test_r3("R3 XNOR",          7'b0000111, 5'b00111);
        test_r3("R3 AND_NOT",       7'b0011111, 5'b11100);
        test_r3("R3 OR_NOT",        7'b0100000, 5'b11011);
        test_r3("R3 INC",           7'b0001100, 5'b01001);
        test_r3("R3 DEC",           7'b0001101, 5'b01010);
        test_r3("R3 SLL",           7'b0001110, 5'b10000);
        test_r3("R3 SLT",           7'b0001111, 5'b10001);
        test_r3("R3 SRL",           7'b0010000, 5'b10010);
        test_r3("R3 SRA",           7'b0010001, 5'b10011);
        test_r3("R3 SGT",           7'b0010010, 5'b10100);
        test_r3("R3 MAX",           7'b0010011, 5'b01100);
        test_r3("R3 MIN",           7'b0010100, 5'b01101);
        test_r3("R3 MUL",           7'b0010111, 5'b11111);
        test_r3("R3 VADD8",         7'b0011000, 5'b10111);
        test_r3("R3 VMAX8",         7'b0011001, 5'b11000);
        test_r3("R3 SDOTP4",        7'b0011010, 5'b11101);

        // =====================================================
        // 6. R2
        // =====================================================
        test_r2("R2 NEG",           7'b0011011, 5'b00000);
        test_r2("R2 ABS",           7'b0011100, 5'b00001);
        test_r2("R2 NOT",           7'b0011101, 5'b01000);
        test_r2("R2 INC",           7'b0001100, 5'b01001);
        test_r2("R2 DEC",           7'b0001101, 5'b01010);
        test_r2("R2 VRELU8",        7'b0011110, 5'b10110);

        // R2 MOV
        aluop  = 4'b0111;
        func_r = 7'b1111111;
        func_i = 5'b11111;

        check_outputs("R2 MOV",
                      2'b11, 5'b11110);

        // =====================================================
        // 7. I-TYPE
        // =====================================================
        test_i("I ADD",             5'b00000, 5'b00000);
        test_i("I SUB",             5'b00001, 5'b00001);
        test_i("I OR",              5'b00010, 5'b00010);
        test_i("I AND",             5'b00011, 5'b00011);
        test_i("I XOR",             5'b00110, 5'b00110);
        test_i("I SLL",             5'b01110, 5'b10000);
        test_i("I SRL",             5'b10000, 5'b10010);
        test_i("I SRA",             5'b10001, 5'b10011);

        // =====================================================
        // 8. Invalid function codes -> safe default
        // =====================================================
        aluop  = 4'b0010;
        func_r = 7'b0011100;
        func_i = 5'b00000;

        check_outputs("R4 INVALID FUNC",
                      2'b00, 5'b11110);

        aluop  = 4'b0100;
        func_r = 7'b0011111;

        check_outputs("R3I INVALID FUNC",
                      2'b00, 5'b11110);

        aluop  = 4'b0101;
        func_r = 7'b1111111;

        check_outputs("R3 INVALID FUNC",
                      2'b01, 5'b11110);

        aluop  = 4'b0110;
        func_r = 7'b0000101;

        check_outputs("R2 INVALID FUNC",
                      2'b10, 5'b11110);

        aluop  = 4'b1000;
        func_i = 5'b00100;

        check_outputs("I INVALID FUNC",
                      2'b11, 5'b11110);

        // =====================================================
        // 9. Invalid ALUOP -> safe default
        // =====================================================
        aluop  = 4'b1111;
        func_r = 7'b0010111;
        func_i = 5'b10011;

        check_outputs("INVALID ALUOP",
                      2'b00, 5'b11110);

        // =====================================================
        // 10. Deterministic activity workload
        //
        // Same sequence of aluop/func fields used to exercise
        // the control decoder for power analysis.
        // =====================================================

        // Functional activity is active in this deterministic section.
        AluEnable_ref = 1'b1;

        for (k = 0; k < 40; k = k + 1) begin
            case (k % 8)
                0: begin
                    aluop  = 4'b0010;
                    func_r = 7'b0000000;
                    func_i = 5'b00000;
                end
                1: begin
                    aluop  = 4'b0101;
                    func_r = 7'b0011000;
                    func_i = 5'b00000;
                end
                2: begin
                    aluop  = 4'b0110;
                    func_r = 7'b0011110;
                    func_i = 5'b00000;
                end
                3: begin
                    aluop  = 4'b1000;
                    func_r = 7'b0000000;
                    func_i = 5'b10001;
                end
                4: begin
                    aluop  = 4'b0100;
                    func_r = 7'b0010101;
                    func_i = 5'b00000;
                end
                5: begin
                    aluop  = 4'b0011;
                    func_r = 7'b1111111;
                    func_i = 5'b00000;
                end
                6: begin
                    aluop  = 4'b0111;
                    func_r = 7'b1111111;
                    func_i = 5'b00000;
                end
                7: begin
                    aluop  = 4'b0001;
                    func_r = 7'b1111111;
                    func_i = 5'b11111;
                end
            endcase
            #1;
        end

        // =====================================================
        // Same mixed activity window as optimized version.
        //
        // The reference AluEnable follows the exact same random
        // sequence. The baseline DUT ignores it because this
        // signal does not exist in the baseline implementation.
        // =====================================================
        for (k = 0; k < 50; k = k + 1) begin
            aluop          = $random;
            func_r         = $random;
            func_i         = $random;
            AluEnable_ref  = $random;
            #1;
        end

        // Same deterministic final activity sequence as optimized version.
        AluEnable_ref = 1'b1;
        aluop         = 4'b0010;
        func_r        = 7'b0000000;
        func_i        = 5'b00000;
        #1;

        AluEnable_ref = 1'b1;
        aluop         = 4'b0101;
        func_r        = 7'b0011000;
        #1;

        AluEnable_ref = 1'b1;
        aluop         = 4'b0110;
        func_r        = 7'b0011110;
        #1;

        AluEnable_ref = 1'b1;
        aluop         = 4'b1000;
        func_i        = 5'b10011;
        #1;

        AluEnable_ref = 1'b1;
        aluop         = 4'b0001;
        #1;

        AluEnable_ref = 1'b1;
        aluop         = 4'b0011;
        #1;

        AluEnable_ref = 1'b1;
        aluop         = 4'b0111;
        #1;

        // Final idle window: exact same input/control values
        // as the optimized AluEnable=0 state. No functional
        // comparison is performed because baseline has no enable.
        AluEnable_ref = 1'b0;
        aluop         = 4'b1111;
        func_r        = 7'b1111111;
        func_i        = 5'b11111;
        #5;

        $display("==============================================");
        $display("BASELINE ALU CONTROL GLS TEST SUMMARY");
        $display("TOTAL TESTS  = %0d", tests);
        $display("TOTAL ERRORS = %0d", errors);

        if (errors == 0)
            $display("GATE-LEVEL BASELINE ALU CONTROL SELF-TEST PASSED");
        else
            $display("GATE-LEVEL BASELINE ALU CONTROL SELF-TEST FAILED");

        $display("==============================================");

        $finish;
    end

endmodule
