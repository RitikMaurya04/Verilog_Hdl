`timescale 1ns/1ps

// ============================================================
// Gate-Level Self-Checking Testbench for BASELINE Branch Unit
//
// DUT:
//   branch_unit_baseline
//
// Baseline has NO branchrs1 / branchrs2 operand-isolation inputs.
//
// The branch/rdata1/rdata2/branchtype workload is intentionally
// matched to the power-aware branch-unit testbench so the two
// post-synthesis VCDs can be compared under the same stimulus.
//
// During workload portions corresponding to operand-isolation or
// branch-inactive operation in the power-aware version, the same
// data/type inputs are still applied here. No artificial disabled
// state is checked because the baseline has no such controls.
// ============================================================

module tb_branch_unit_baseline_gls_power;

    reg        branch;
    reg [31:0] rdata1;
    reg [31:0] rdata2;
    reg [4:0]  branchtype;

    // Reference-only signals. They mirror the optimized workload
    // but are not connected to the baseline DUT.
    reg        branchrs1_ref;
    reg        branchrs2_ref;

    wire       branch_taken;

    integer tests;
    integer errors;
    integer k;

    // ---------------------------------------------------------
    // Exact DUT interface from branch_unit_baseline.v
    // ---------------------------------------------------------
    branch_unit_baseline dut (
        .branch       (branch),
        .rdata1       (rdata1),
        .rdata2       (rdata2),
        .branchtype   (branchtype),
        .branch_taken (branch_taken)
    );

    // ---------------------------------------------------------
    // Checker
    // ---------------------------------------------------------
    task check_output;
        input [127:0] name;
        input          expected;
        begin
            #2;
            tests = tests + 1;

            if (branch_taken !== expected) begin
                $display("[FAIL] %-24s | branch=%b type=%b r1=%b r2=%b | expected=%b actual=%b",
                         name, branch, branchtype,
                         rdata1, rdata2,
                         expected, branch_taken);
                errors = errors + 1;
            end
            else begin
                $display("[PASS] %-24s | type=%b branch_taken=%b",
                         name, branchtype, branch_taken);
            end
        end
    endtask

    task test_two_reg;
        input [127:0] name;
        input [4:0]   type;
        input [31:0]  a;
        input [31:0]  b;
        input          expected;
        begin
            branch     = 1'b1;
            rdata1     = a;
            rdata2     = b;
            branchtype = type;
            check_output(name, expected);
        end
    endtask

    task test_one_reg;
        input [127:0] name;
        input [4:0]   type;
        input [31:0]  a;
        input [31:0]  noisy_b;
        input          expected;
        begin
            branch     = 1'b1;
            rdata1     = a;
            rdata2     = noisy_b;
            branchtype = type;
            check_output(name, expected);
        end
    endtask

    initial begin
        tests  = 0;
        errors = 0;

        branch         = 1'b0;
        rdata1         = 32'b0;
        rdata2         = 32'b0;
        branchtype     = 5'b00000;
        branchrs1_ref  = 1'b0;
        branchrs2_ref  = 1'b0;

        $dumpfile("branch_unit_baseline_gls_power.vcd");
        $dumpvars(0, tb_branch_unit_baseline_gls_power);

        // =====================================================
        // 1. SAME IDLE / INACTIVE WORKLOAD AS ENABLE VERSION
        //
        // The baseline has no branchrs1/branchrs2 isolation, so
        // these vectors are NOT treated as disabled-state checks.
        // They are applied only to reproduce the same workload.
        // =====================================================

        branch         = 1'b0;
        branchrs1_ref  = 1'b0;
        branchrs2_ref  = 1'b0;
        branchtype     = 5'b00001;
        rdata1         = 32'b11111111111111111111111111111111;
        rdata2         = 32'b00000000000000000000000000000000;
        #2;

        branch         = 1'b0;
        branchrs1_ref  = 1'b1;
        branchrs2_ref  = 1'b1;
        branchtype     = 5'b00101;
        rdata1         = 32'b10000000000000000000000000000000;
        rdata2         = 32'b01111111111111111111111111111111;
        #2;

        branch         = 1'b0;
        branchrs1_ref  = 1'b1;
        branchrs2_ref  = 1'b0;
        branchtype     = 5'b01100;
        rdata1         = 32'b00000000000000000000000000000101;
        rdata2         = 32'b10101010101010101010101010101010;
        #2;

        // =====================================================
        // 2. TWO-REGISTER BRANCH CONDITIONS
        // =====================================================

        test_two_reg("BEQ TRUE",
                     5'b00001,
                     32'b00000000000000000000000000001010,
                     32'b00000000000000000000000000001010,
                     1'b1);

        test_two_reg("BEQ FALSE",
                     5'b00001,
                     32'b00000000000000000000000000001010,
                     32'b00000000000000000000000000010100,
                     1'b0);

        test_two_reg("BNEQ TRUE",
                     5'b00010,
                     32'b00000000000000000000000000001010,
                     32'b00000000000000000000000000010100,
                     1'b1);

        test_two_reg("BNEQ FALSE",
                     5'b00010,
                     32'b00000000000000000000000000001010,
                     32'b00000000000000000000000000001010,
                     1'b0);

        test_two_reg("BGT UNSIGNED TRUE",
                     5'b00011,
                     32'b00000000000000000000000000101000,
                     32'b00000000000000000000000000010100,
                     1'b1);

        test_two_reg("BGT UNSIGNED FALSE",
                     5'b00011,
                     32'b00000000000000000000000000010100,
                     32'b00000000000000000000000000101000,
                     1'b0);

        test_two_reg("BLT UNSIGNED TRUE",
                     5'b00100,
                     32'b00000000000000000000000000010100,
                     32'b00000000000000000000000000101000,
                     1'b1);

        test_two_reg("BLT UNSIGNED FALSE",
                     5'b00100,
                     32'b00000000000000000000000000101000,
                     32'b00000000000000000000000000010100,
                     1'b0);

        test_two_reg("BGST SIGNED TRUE",
                     5'b00101,
                     32'b00000000000000000000000000000010,
                     32'b11111111111111111111111111111101,
                     1'b1);

        test_two_reg("BGST SIGNED FALSE",
                     5'b00101,
                     32'b11111111111111111111111111111101,
                     32'b00000000000000000000000000000010,
                     1'b0);

        test_two_reg("BLST SIGNED TRUE",
                     5'b00110,
                     32'b11111111111111111111111111111101,
                     32'b00000000000000000000000000000010,
                     1'b1);

        test_two_reg("BLST SIGNED FALSE",
                     5'b00110,
                     32'b00000000000000000000000000000010,
                     32'b11111111111111111111111111111101,
                     1'b0);

        // =====================================================
        // 3. SINGLE-REGISTER SIGNED BRANCHES
        // =====================================================

        test_one_reg("BLTZ TRUE",
                     5'b00111,
                     32'b11111111111111111111111111111111,
                     32'b01010101010101010101010101010101,
                     1'b1);

        test_one_reg("BLTZ FALSE",
                     5'b00111,
                     32'b00000000000000000000000000000001,
                     32'b11111111111111111111111111111111,
                     1'b0);

        test_one_reg("BGTZ TRUE",
                     5'b01000,
                     32'b00000000000000000000000000000001,
                     32'b11111111111111111111111111111111,
                     1'b1);

        test_one_reg("BGTZ FALSE",
                     5'b01000,
                     32'b11111111111111111111111111111111,
                     32'b00000000000000000000000000000001,
                     1'b0);

        test_one_reg("BGEZ TRUE",
                     5'b01001,
                     32'b00000000000000000000000000000000,
                     32'b11111111111111111111111111111111,
                     1'b1);

        test_one_reg("BGEZ POSITIVE",
                     5'b01001,
                     32'b00000000000000000000000000000010,
                     32'b11111111111111111111111111111111,
                     1'b1);

        test_one_reg("BGEZ FALSE",
                     5'b01001,
                     32'b11111111111111111111111111111110,
                     32'b00000000000000000000000000000000,
                     1'b0);

        test_one_reg("BLEZ TRUE",
                     5'b01010,
                     32'b00000000000000000000000000000000,
                     32'b01010101010101010101010101010101,
                     1'b1);

        test_one_reg("BLEZ NEGATIVE",
                     5'b01010,
                     32'b11111111111111111111111111111110,
                     32'b01010101010101010101010101010101,
                     1'b1);

        test_one_reg("BLEZ FALSE",
                     5'b01010,
                     32'b00000000000000000000000000000010,
                     32'b01010101010101010101010101010101,
                     1'b0);

        // =====================================================
        // 4. ZERO COMPARISONS
        // =====================================================

        test_one_reg("BEQZ TRUE",
                     5'b01011,
                     32'b00000000000000000000000000000000,
                     32'b10101010101010101010101010101010,
                     1'b1);

        test_one_reg("BEQZ FALSE",
                     5'b01011,
                     32'b00000000000000000000000000000101,
                     32'b00000000000000000000000000000000,
                     1'b0);

        test_one_reg("BNEZ TRUE",
                     5'b01100,
                     32'b00000000000000000000000000000101,
                     32'b00000000000000000000000000000000,
                     1'b1);

        test_one_reg("BNEZ FALSE",
                     5'b01100,
                     32'b00000000000000000000000000000000,
                     32'b11111111111111111111111111111111,
                     1'b0);

        // =====================================================
        // 5. NONE / INVALID
        // =====================================================

        branch     = 1'b1;
        branchtype = 5'b00000;
        rdata1     = 32'b00000000000000000000000000001010;
        rdata2     = 32'b00000000000000000000000000001010;
        check_output("NONE TYPE", 1'b0);

        branchtype = 5'b01101;
        check_output("INVALID TYPE", 1'b0);

        // =====================================================
        // 6. SAME POWER-ACTIVITY WORKLOAD
        // =====================================================

        branch = 1'b0;

        for (k = 0; k < 40; k = k + 1) begin
            branchtype = k[4:0];

            rdata1 = 32'b00010011010101100111100010010101
                   ^ (k * 32'b00000000000000010001000100010001);

            rdata2 = 32'b10101010110011001100110010101010
                   ^ (k * 32'b00000000000100110011001101010101);

            branchrs1_ref = k[0];
            branchrs2_ref = k[1];

            #1;
        end

        // Active two-register branch sequence.
        branch = 1'b1;

        branchtype = 5'b00001;
        rdata1 = 32'd10;
        rdata2 = 32'd10;
        #1;

        branchtype = 5'b00010;
        rdata1 = 32'd10;
        rdata2 = 32'd20;
        #1;

        branchtype = 5'b00011;
        rdata1 = 32'd30;
        rdata2 = 32'd20;
        #1;

        branchtype = 5'b00100;
        rdata1 = 32'd20;
        rdata2 = 32'd30;
        #1;

        branchtype = 5'b00101;
        rdata1 = 32'b00000000000000000000000000000010;
        rdata2 = 32'b11111111111111111111111111111101;
        #1;

        branchtype = 5'b00110;
        rdata1 = 32'b11111111111111111111111111111101;
        rdata2 = 32'b00000000000000000000000000000010;
        #1;

        // Single-register branch sequence.
        // rdata2 continues toggling even though the optimized
        // version would isolate it.
        branchrs1_ref = 1'b1;
        branchrs2_ref = 1'b0;

        branchtype = 5'b00111;
        rdata1 = 32'b11111111111111111111111111111111;
        rdata2 = 32'b01010101010101010101010101010101;
        #1;

        branchtype = 5'b01000;
        rdata1 = 32'b00000000000000000000000000000001;
        rdata2 = 32'b11111111111111111111111111111111;
        #1;

        branchtype = 5'b01001;
        rdata1 = 32'b00000000000000000000000000000000;
        rdata2 = 32'b10101010101010101010101010101010;
        #1;

        branchtype = 5'b01010;
        rdata1 = 32'b11111111111111111111111111111110;
        rdata2 = 32'b01010101010101010101010101010101;
        #1;

        branchtype = 5'b01011;
        rdata1 = 32'b00000000000000000000000000000000;
        rdata2 = 32'b11111111111111111111111111111111;
        #1;

        branchtype = 5'b01100;
        rdata1 = 32'b00000000000000000000000000000101;
        rdata2 = 32'b10101010101010101010101010101010;
        #1;

        // Final inactive window with noisy operands.
        branch         = 1'b0;
        branchrs1_ref  = 1'b1;
        branchrs2_ref  = 1'b1;
        branchtype     = 5'b01100;
        rdata1         = 32'b11001100110011001100110011001100;
        rdata2         = 32'b00110011001100110011001100110011;
        #5;

        $display("==============================================");
        $display("BASELINE BRANCH UNIT GLS TEST SUMMARY");
        $display("TOTAL TESTS  = %0d", tests);
        $display("TOTAL ERRORS = %0d", errors);

        if (errors == 0)
            $display("GATE-LEVEL BASELINE BRANCH UNIT SELF-TEST PASSED");
        else
            $display("GATE-LEVEL BASELINE BRANCH UNIT SELF-TEST FAILED");

        $display("==============================================");

        $finish;
    end

endmodule
