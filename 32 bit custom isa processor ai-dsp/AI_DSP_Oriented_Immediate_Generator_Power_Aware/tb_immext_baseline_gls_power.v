`timescale 1ns/1ps

// ============================================================
// Gate-Level Self-Checking Testbench for BASELINE Immediate
// Generator
//
// DUT:
//   immext_baseline
//
// Baseline has NO ImmEnable input and NO input-isolation muxes.
//
// IMPORTANT POWER-COMPARISON RULE:
//   The instruction / ImmType / ImmMode workload and timing are
//   kept identical to the power-aware immext testbench.
//
//   During periods where the power-aware version has
//   ImmEnable=0, the baseline DUT still receives the same changing
//   inputs. No functional check is performed during those idle
//   periods because the baseline has no disabled state.
//
// The reference-only ImmEnable_ref signal is NOT connected to the
// DUT. It exists only to document/mirror the workload used by the
// power-aware testbench.
// ============================================================

module tb_immext_baseline_gls_power;

    reg  [31:0] instruction;
    reg  [2:0]  ImmType;
    reg  [1:0]  ImmMode;

    // Reference only: mirrors the optimized testbench's enable
    // state. It is not connected to the baseline DUT.
    reg         ImmEnable_ref;

    wire [31:0] Out;

    integer errors;
    integer tests;
    integer k;

    // ---------------------------------------------------------
    // DUT
    // ---------------------------------------------------------
    immext_baseline dut (
        .instruction (instruction),
        .ImmType     (ImmType),
        .ImmMode     (ImmMode),
        .Out         (Out)
    );

    // ---------------------------------------------------------
    // Generic result checker
    // ---------------------------------------------------------
    task check_output;
        input [159:0] name;
        input [31:0]  expected;

        begin
            #2;
            tests = tests + 1;

            if (Out !== expected) begin
                $display("[FAIL] %-28s | instruction=%b ImmType=%b ImmMode=%b | expected=%b actual=%b",
                         name,
                         instruction, ImmType, ImmMode,
                         expected, Out);
                errors = errors + 1;
            end
            else begin
                $display("[PASS] %-28s | Out=%b",
                         name, Out);
            end
        end
    endtask

    // ---------------------------------------------------------
    // I-type
    // IMM = instruction[26:15]
    // ---------------------------------------------------------
    task test_i;
        input [159:0] name;
        input [11:0]  imm;
        input [1:0]   mode_i;
        input [31:0]  expected;

        begin
            instruction = 32'b0;
            instruction[26:15] = imm;
            ImmType = 3'b001;
            ImmMode = mode_i;

            check_output(name, expected);
        end
    endtask

    // ---------------------------------------------------------
    // S-type
    // IMM = instruction[26:20], instruction[9:5]
    // ---------------------------------------------------------
    task test_s;
        input [159:0] name;
        input [11:0]  imm;
        input [1:0]   mode_i;
        input [31:0]  expected;

        begin
            instruction = 32'b0;
            instruction[26:20] = imm[11:5];
            instruction[9:5]   = imm[4:0];
            ImmType = 3'b010;
            ImmMode = mode_i;

            check_output(name, expected);
        end
    endtask

    // ---------------------------------------------------------
    // B-type
    // Same field split as S-type in this custom ISA.
    // ---------------------------------------------------------
    task test_b;
        input [159:0] name;
        input [11:0]  imm;
        input [1:0]   mode_i;
        input [31:0]  expected;

        begin
            instruction = 32'b0;
            instruction[26:20] = imm[11:5];
            instruction[9:5]   = imm[4:0];
            ImmType = 3'b011;
            ImmMode = mode_i;

            check_output(name, expected);
        end
    endtask

    // ---------------------------------------------------------
    // J-type
    // IMM = instruction[31:10]
    // ---------------------------------------------------------
    task test_j;
        input [159:0] name;
        input [21:0]  imm;
        input [1:0]   mode_i;
        input [31:0]  expected;

        begin
            instruction = 32'b0;
            instruction[31:10] = imm;
            ImmType = 3'b100;
            ImmMode = mode_i;

            check_output(name, expected);
        end
    endtask

    // ---------------------------------------------------------
    // R3I-type
    // IMM = instruction[24:20]
    // ---------------------------------------------------------
    task test_r3i;
        input [159:0] name;
        input [4:0]   imm;
        input [1:0]   mode_i;
        input [31:0]  expected;

        begin
            instruction = 32'b0;
            instruction[24:20] = imm;
            ImmType = 3'b101;
            ImmMode = mode_i;

            check_output(name, expected);
        end
    endtask

    // ---------------------------------------------------------
    // JALR-type
    // IMM = instruction[31:15]
    // ---------------------------------------------------------
    task test_jalr;
        input [159:0] name;
        input [16:0]  imm;
        input [1:0]   mode_i;
        input [31:0]  expected;

        begin
            instruction = 32'b0;
            instruction[31:15] = imm;
            ImmType = 3'b110;
            ImmMode = mode_i;

            check_output(name, expected);
        end
    endtask

    initial begin
        errors = 0;
        tests  = 0;

        instruction   = 32'b0;
        ImmType       = 3'b000;
        ImmMode       = 2'b00;
        ImmEnable_ref = 1'b0;

        $dumpfile("immext_baseline_gls_power.vcd");
        $dumpvars(0, tb_immext_baseline_gls_power);

        // =====================================================
        // 1. SAME DISABLED / IDLE WORKLOAD AS ENABLE VERSION
        //
        // No functional check here. The baseline has no
        // ImmEnable state; these vectors are applied solely to
        // reproduce the same external switching workload.
        // =====================================================

        ImmEnable_ref = 1'b0;
        ImmType       = 3'b001;
        ImmMode       = 2'b00;
        instruction   = 32'b10101010101010101010101010101010;
        #2;

        ImmEnable_ref = 1'b0;
        ImmType       = 3'b010;
        ImmMode       = 2'b11;
        instruction   = 32'b01010101010101010101010101010101;
        #2;

        ImmEnable_ref = 1'b0;
        ImmType       = 3'b100;
        ImmMode       = 2'b10;
        instruction   = 32'b11110000111100001111000011110000;
        #2;

        // =====================================================
        // 2. I-TYPE
        // =====================================================

        ImmEnable_ref = 1'b1;

        test_i("I SIGN EXTEND +13",
                12'b000000001101,
                2'b00,
                32'b00000000000000000000000000001101);

        test_i("I ZERO EXTEND +13",
                12'b000000001101,
                2'b01,
                32'b00000000000000000000000000001101);

        test_i("I SHIFT LEFT 2 +13",
                12'b000000001101,
                2'b10,
                32'b00000000000000000000000000110100);

        test_i("I CUSTOM +13",
                12'b000000001101,
                2'b11,
                32'b10101011110011011111000000001101);

        test_i("I SIGN EXTEND -5",
                12'b111111111011,
                2'b00,
                32'b11111111111111111111111111111011);

        test_i("I ZERO EXTEND -5",
                12'b111111111011,
                2'b01,
                32'b00000000000000000000111111111011);

        test_i("I SHIFT LEFT 2 -5",
                12'b111111111011,
                2'b10,
                32'b11111111111111111111111111101100);

        // =====================================================
        // 3. S-TYPE
        // =====================================================

        test_s("S SIGN EXTEND +11",
                12'b000000001011,
                2'b00,
                32'b00000000000000000000000000001011);

        test_s("S ZERO EXTEND +11",
                12'b000000001011,
                2'b01,
                32'b00000000000000000000000000001011);

        test_s("S SHIFT LEFT 2 +11",
                12'b000000001011,
                2'b10,
                32'b00000000000000000000000000101100);

        test_s("S CUSTOM +11",
                12'b000000001011,
                2'b11,
                32'b10101011110011011111000000001011);

        test_s("S SIGN EXTEND -5",
                12'b111111111011,
                2'b00,
                32'b11111111111111111111111111111011);

        // =====================================================
        // 4. B-TYPE
        // =====================================================

        test_b("B SIGN EXTEND +9",
                12'b000000001001,
                2'b00,
                32'b00000000000000000000000000001001);

        test_b("B ZERO EXTEND +9",
                12'b000000001001,
                2'b01,
                32'b00000000000000000000000000001001);

        test_b("B SHIFT LEFT 1 +9",
                12'b000000001001,
                2'b10,
                32'b00000000000000000000000000010010);

        test_b("B CUSTOM +9",
                12'b000000001001,
                2'b11,
                32'b10101011110011011111000000001001);

        test_b("B SIGN EXTEND -5",
                12'b111111111011,
                2'b00,
                32'b11111111111111111111111111111011);

        // =====================================================
        // 5. J-TYPE
        // =====================================================

        test_j("J SIGN EXTEND +21",
                22'b0000000000000000010101,
                2'b00,
                32'b00000000000000000000000000010101);

        test_j("J ZERO EXTEND +21",
                22'b0000000000000000010101,
                2'b01,
                32'b00000000000000000000000000010101);

        test_j("J SHIFT LEFT 1 +21",
                22'b0000000000000000010101,
                2'b10,
                32'b00000000000000000000000000101010);

        test_j("J CUSTOM +21",
                22'b0000000000000000010101,
                2'b11,
                32'b10101010100000000000000000010101);

        test_j("J SIGN EXTEND -17",
                22'b1111111111111111101111,
                2'b00,
                32'b11111111111111111111111111101111);

        // =====================================================
        // 6. R3I-TYPE
        // =====================================================

        test_r3i("R3I SIGN EXTEND +5",
                  5'b00101,
                  2'b00,
                  32'b00000000000000000000000000000101);

        test_r3i("R3I ZERO EXTEND +5",
                  5'b00101,
                  2'b01,
                  32'b00000000000000000000000000000101);

        test_r3i("R3I SHIFT LEFT 1 +5",
                  5'b00101,
                  2'b10,
                  32'b00000000000000000000000000001010);

        test_r3i("R3I CUSTOM +5",
                  5'b00101,
                  2'b11,
                  32'b01010101010111110111100000100101);

        test_r3i("R3I SIGN EXTEND -3",
                  5'b11101,
                  2'b00,
                  32'b11111111111111111111111111111101);

        test_r3i("R3I SHIFT LEFT 1 -3",
                  5'b11101,
                  2'b10,
                  32'b11111111111111111111111111111010);

        // =====================================================
        // 7. JALR-TYPE
        // =====================================================

        test_jalr("JALR SIGN EXTEND +13",
                   17'b00000000000001101,
                   2'b00,
                   32'b00000000000000000000000000001101);

        test_jalr("JALR ZERO EXTEND +13",
                   17'b00000000000001101,
                   2'b01,
                   32'b00000000000000000000000000001101);

        test_jalr("JALR SHIFT LEFT 1 +13",
                   17'b00000000000001101,
                   2'b10,
                   32'b00000000000000000000000000011010);

        test_jalr("JALR CUSTOM +13",
                   17'b00000000000001101,
                   2'b11,
                   32'b01111001101111100000000000001101);

        test_jalr("JALR SIGN EXTEND -5",
                   17'b11111111111111011,
                   2'b00,
                   32'b11111111111111111111111111111011);

        // =====================================================
        // 8. NONE / INVALID IMM TYPE
        // =====================================================

        ImmEnable_ref = 1'b1;
        ImmType       = 3'b000;
        ImmMode       = 2'b00;
        instruction   = 32'b11111111111111111111111111111111;

        check_output("NONE TYPE",
                     32'b00000000000000000000000000000000);

        ImmEnable_ref = 1'b1;
        ImmType       = 3'b111;
        ImmMode       = 2'b11;
        instruction   = 32'b01010101010101010101010101010101;

        check_output("INVALID TYPE",
                     32'b00000000000000000000000000000000);

        // =====================================================
        // 9. SAME ACTIVITY WORKLOAD AS ENABLE VERSION
        // =====================================================

        // Same inactive / isolation window
        ImmEnable_ref = 1'b0;

        for (k = 0; k < 40; k = k + 1) begin
            instruction = 32'b00010011010101100111100010010101
                          ^ (k * 32'b00000000000000010001000100010001);
            ImmType = k[2:0];
            ImmMode = k[1:0];
            #1;
        end

        // Same active deterministic workload
        ImmEnable_ref = 1'b1;

        instruction = 32'b00000000000000000000000000001101;
        ImmType = 3'b001;
        ImmMode = 2'b00;
        #1;

        instruction = 32'b00000000000000000000000000001011;
        ImmType = 3'b010;
        ImmMode = 2'b10;
        #1;

        instruction = 32'b00000000000000000000000000001001;
        ImmType = 3'b011;
        ImmMode = 2'b11;
        #1;

        instruction = 32'b00000000000000000000000000010101;
        ImmType = 3'b100;
        ImmMode = 2'b10;
        #1;

        instruction = 32'b00000000000000000000000000000101;
        ImmType = 3'b101;
        ImmMode = 2'b11;
        #1;

        instruction = 32'b00000000000000000000000000001101;
        ImmType = 3'b110;
        ImmMode = 2'b00;
        #1;

        // Same final inactive window with changing inputs
        ImmEnable_ref = 1'b0;
        ImmType       = 3'b110;
        ImmMode       = 2'b11;
        instruction   = 32'b10110101101011010011101001100110;
        #1;

        ImmType       = 3'b001;
        ImmMode       = 2'b01;
        instruction   = 32'b01001001111100011101010110101100;
        #1;

        ImmType       = 3'b100;
        ImmMode       = 2'b10;
        instruction   = 32'b11110000111100001111000011110000;
        #5;

        // =====================================================
        // Final summary
        // =====================================================

        $display("==============================================");
        $display("IMMEXT BASELINE GATE-LEVEL TEST SUMMARY");
        $display("TOTAL TESTS  = %0d", tests);
        $display("TOTAL ERRORS = %0d", errors);

        if (errors == 0)
            $display("GATE-LEVEL BASELINE IMMEXT SELF-TEST PASSED");
        else
            $display("GATE-LEVEL BASELINE IMMEXT SELF-TEST FAILED");

        $display("==============================================");

        $finish;
    end

endmodule
