`timescale 1ns/1ps

// ============================================================
// Gate-Level Self-Checking Testbench for ALU CONTROL
//
// DUT:
//   alu_control
//
// Purpose:
//   - Verify the synthesized ALU-control netlist.
//   - Check all supported ALU operation classes.
//   - Verify mode/control/operand-enable outputs.
//   - Verify the global AluEnable isolation behavior.
//   - Generate a VCD suitable for OpenSTA power analysis.
//
// Function encodings are written in BINARY to match the ISA/control
// documentation.
// ============================================================

module tb_alu_control_gls;

    reg  [3:0] aluop;
    reg  [6:0] func_r;
    reg  [4:0] func_i;
    reg        AluEnable;

    wire [1:0] mode;
    wire [4:0] control;
    wire       alu_enA;
    wire       alu_enB;
    wire       alu_enC;

    integer errors;
    integer tests;

    // ---------------------------------------------------------
    // DUT
    // ---------------------------------------------------------
    alu_control dut (
        .aluop      (aluop),
        .func_r     (func_r),
        .func_i     (func_i),
        .AluEnable  (AluEnable),
        .mode       (mode),
        .control    (control),
        .alu_enA    (alu_enA),
        .alu_enB    (alu_enB),
        .alu_enC    (alu_enC)
    );

    // ---------------------------------------------------------
    // Generic checker
    // ---------------------------------------------------------
    task check_outputs;
        input [127:0] name;
        input [1:0]   exp_mode;
        input [4:0]   exp_control;
        input         exp_enA;
        input         exp_enB;
        input         exp_enC;

        begin
            #2;
            tests = tests + 1;

            if ((mode    !== exp_mode)    ||
                (control !== exp_control) ||
                (alu_enA !== exp_enA)     ||
                (alu_enB !== exp_enB)     ||
                (alu_enC !== exp_enC)) begin

                $display("[FAIL] %-24s | aluop=%b func_r=%b func_i=%b AluEnable=%b | mode=%b/%b control=%b/%b enA=%b/%b enB=%b/%b enC=%b/%b",
                         name,
                         aluop, func_r, func_i, AluEnable,
                         mode, exp_mode,
                         control, exp_control,
                         alu_enA, exp_enA,
                         alu_enB, exp_enB,
                         alu_enC, exp_enC);

                errors = errors + 1;
            end
            else begin
                $display("[PASS] %-24s | mode=%b control=%b enA=%b enB=%b enC=%b",
                         name, mode, control, alu_enA, alu_enB, alu_enC);
            end
        end
    endtask

    // ---------------------------------------------------------
    // R4 / R3I common function test
    // ---------------------------------------------------------
    task test_r4;
        input [127:0] name;
        input [6:0]   f;
        input [4:0]   c;

        begin
            aluop     = 4'b0010;
            func_r    = f;
            func_i    = 5'b00000;
            AluEnable = 1'b1;

            check_outputs(name,
                          2'b00, c,
                          1'b1, 1'b1, 1'b1);
        end
    endtask

    task test_r3i;
        input [127:0] name;
        input [6:0]   f;
        input [4:0]   c;

        begin
            aluop     = 4'b0100;
            func_r    = f;
            func_i    = 5'b00000;
            AluEnable = 1'b1;

            check_outputs(name,
                          2'b00, c,
                          1'b1, 1'b1, 1'b1);
        end
    endtask

    // ---------------------------------------------------------
    // R3 tests
    // ---------------------------------------------------------
    task test_r3;
        input [127:0] name;
        input [6:0]   f;
        input [4:0]   c;
        input         enC;

        begin
            aluop     = 4'b0101;
            func_r    = f;
            func_i    = 5'b00000;
            AluEnable = 1'b1;

            check_outputs(name,
                          2'b01, c,
                          1'b1, 1'b1, enC);
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
            aluop     = 4'b0110;
            func_r    = f;
            func_i    = 5'b00000;
            AluEnable = 1'b1;

            check_outputs(name,
                          2'b10, c,
                          1'b1, 1'b0, 1'b0);
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
            aluop     = 4'b1000;
            func_r    = 7'b0000000;
            func_i    = f;
            AluEnable = 1'b1;

            check_outputs(name,
                          2'b11, c,
                          1'b1, 1'b0, 1'b1);
        end
    endtask

    initial begin
        errors = 0;
        tests  = 0;

        // Initial conditions
        aluop     = 4'b0000;
        func_r    = 7'b0000000;
        func_i    = 5'b00000;
        AluEnable = 1'b0;

        $dumpfile("alu_control_gls.vcd");
        $dumpvars(0, tb_alu_control_gls);

        // =====================================================
        // 1. ALU DISABLED / ISOLATION TESTS
        // =====================================================
        //
        // Regardless of incoming function/opcode values, the
        // outputs must remain at the safe defaults when AluEnable=0.
        //
        aluop     = 4'b0010;
        func_r    = 7'b1111111;
        func_i    = 5'b11111;
        AluEnable = 1'b0;

        check_outputs("ALU DISABLED R4",
                      2'b00, 5'b11110,
                      1'b0, 1'b0, 1'b0);

        aluop     = 4'b0101;
        func_r    = 7'b1011010;
        func_i    = 5'b10110;
        AluEnable = 1'b0;

        check_outputs("ALU DISABLED R3",
                      2'b00, 5'b11110,
                      1'b0, 1'b0, 1'b0);

        aluop     = 4'b1000;
        func_r    = 7'b0101010;
        func_i    = 5'b10011;
        AluEnable = 1'b0;

        check_outputs("ALU DISABLED I",
                      2'b00, 5'b11110,
                      1'b0, 1'b0, 1'b0);

        // =====================================================
        // 2. LOAD / STORE
        // Address = A + C
        // =====================================================
        aluop     = 4'b0001;
        func_r    = 7'b1111111;
        func_i    = 5'b11111;
        AluEnable = 1'b1;

        check_outputs("LOAD / STORE",
                      2'b11, 5'b00000,
                      1'b1, 1'b0, 1'b1);

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
        aluop     = 4'b0011;
        func_r    = 7'b1111111;
        AluEnable = 1'b1;

        check_outputs("R4 MOV",
                      2'b11, 5'b11110,
                      1'b0, 1'b0, 1'b0);

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
        // 5. R3
        // =====================================================
        test_r3("R3 ADD",           7'b0000000, 5'b00000, 1'b0);
        test_r3("R3 SUB",           7'b0000001, 5'b00001, 1'b0);
        test_r3("R3 OR",            7'b0000010, 5'b00010, 1'b0);
        test_r3("R3 AND",           7'b0000011, 5'b00011, 1'b0);
        test_r3("R3 NAND",          7'b0000100, 5'b00100, 1'b0);
        test_r3("R3 NOR",           7'b0000101, 5'b00101, 1'b0);
        test_r3("R3 XOR",           7'b0000110, 5'b00110, 1'b0);
        test_r3("R3 XNOR",          7'b0000111, 5'b00111, 1'b0);
        test_r3("R3 AND_NOT",       7'b0011111, 5'b11100, 1'b0);
        test_r3("R3 OR_NOT",        7'b0100000, 5'b11011, 1'b0);
        test_r3("R3 INC",           7'b0001100, 5'b01001, 1'b0);
        test_r3("R3 DEC",           7'b0001101, 5'b01010, 1'b0);
        test_r3("R3 SLL",           7'b0001110, 5'b10000, 1'b0);
        test_r3("R3 SLT",           7'b0001111, 5'b10001, 1'b0);
        test_r3("R3 SRL",           7'b0010000, 5'b10010, 1'b0);
        test_r3("R3 SRA",           7'b0010001, 5'b10011, 1'b0);
        test_r3("R3 SGT",           7'b0010010, 5'b10100, 1'b0);
        test_r3("R3 MAX",           7'b0010011, 5'b01100, 1'b0);
        test_r3("R3 MIN",           7'b0010100, 5'b01101, 1'b0);
        test_r3("R3 MUL",           7'b0010111, 5'b11111, 1'b0);
        test_r3("R3 VADD8",         7'b0011000, 5'b10111, 1'b0);
        test_r3("R3 VMAX8",         7'b0011001, 5'b11000, 1'b0);
        test_r3("R3 SDOTP4",        7'b0011010, 5'b11101, 1'b0);

        // =====================================================
        // 6. R2
        // =====================================================
        test_r2("R2 NEG",           7'b0011011, 5'b00000);
        test_r2("R2 ABS",           7'b0011100, 5'b00001);
        test_r2("R2 NOT",           7'b0011101, 5'b01000);
        test_r2("R2 VRELU8",        7'b0011110, 5'b10110);
        test_r2("R2 INC",           7'b0001100, 5'b01001);
        test_r2("R2 DEC",           7'b0001101, 5'b01010);

        // R2 MOV
        aluop     = 4'b0111;
        func_r    = 7'b1111111;
        AluEnable = 1'b1;

        check_outputs("R2 MOV",
                      2'b11, 5'b11110,
                      1'b0, 1'b0, 1'b0);

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

        // Invalid R4 FUNC
        aluop     = 4'b0010;
        func_r    = 7'b0011100;
        AluEnable = 1'b1;

        check_outputs("R4 INVALID FUNC",
                      2'b00, 5'b11110,
                      1'b1, 1'b1, 1'b1);

        // Invalid R3I FUNC
        aluop     = 4'b0100;
        func_r    = 7'b0011111;
        AluEnable = 1'b1;

        check_outputs("R3I INVALID FUNC",
                      2'b00, 5'b11110,
                      1'b1, 1'b1, 1'b1);

        // Invalid R3 FUNC
        aluop     = 4'b0101;
        func_r    = 7'b1111111;
        AluEnable = 1'b1;

        check_outputs("R3 INVALID FUNC",
                      2'b01, 5'b11110,
                      1'b1, 1'b1, 1'b0);

        // Invalid R2 FUNC
        aluop     = 4'b0110;
        func_r    = 7'b0000101;
        AluEnable = 1'b1;

        check_outputs("R2 INVALID FUNC",
                      2'b10, 5'b11110,
                      1'b1, 1'b0, 1'b0);

        // Invalid I FUNC
        aluop     = 4'b1000;
        func_i    = 5'b00100;
        AluEnable = 1'b1;

        check_outputs("I INVALID FUNC",
                      2'b11, 5'b11110,
                      1'b1, 1'b0, 1'b1);

        // =====================================================
        // 9. Unknown / unsupported ALUOP -> safe default
        // =====================================================
        aluop     = 4'b1111;
        func_r    = 7'b0010111;
        func_i    = 5'b10011;
        AluEnable = 1'b1;

        check_outputs("INVALID ALUOP",
                      2'b00, 5'b11110,
                      1'b0, 1'b0, 1'b0);

        // =====================================================
        // 10. Activity window for power analysis
        // =====================================================
        //
        // Keep AluEnable active and cycle through representative
        // instruction classes and function fields.
        //
        repeat (50) begin

            aluop     = $random;
            func_r    = $random;
            func_i    = $random;
            AluEnable = $random;
            #1;

        end

        // Deterministic activity sequence
        aluop     = 4'b0010;
        func_r    = 7'b0000000;
        func_i    = 5'b00000;
        AluEnable = 1'b1;
        #1;

        aluop     = 4'b0101;
        func_r    = 7'b0011000;
        AluEnable = 1'b1;
        #1;

        aluop     = 4'b0110;
        func_r    = 7'b0011110;
        AluEnable = 1'b1;
        #1;

        aluop     = 4'b1000;
        func_i    = 5'b10011;
        AluEnable = 1'b1;
        #1;

        aluop     = 4'b0001;
        AluEnable = 1'b1;
        #1;

        aluop     = 4'b0011;
        AluEnable = 1'b1;
        #1;

        aluop     = 4'b0111;
        AluEnable = 1'b1;
        #1;

        // Return to disabled state with changing inputs.
        AluEnable = 1'b0;
        aluop     = 4'b1111;
        func_r    = 7'b1111111;
        func_i    = 5'b11111;
        #5;

        // Final report
        $display("==============================================");
        $display("ALU CONTROL GLS TEST SUMMARY");
        $display("TOTAL TESTS = %0d", tests);
        $display("TOTAL ERRORS = %0d", errors);

        if (errors == 0)
            $display("GATE-LEVEL ALU CONTROL SELF-TEST PASSED");
        else
            $display("GATE-LEVEL ALU CONTROL SELF-TEST FAILED");

        $display("==============================================");

        $finish;
    end

endmodule
