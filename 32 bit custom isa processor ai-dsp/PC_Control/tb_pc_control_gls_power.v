`timescale 1ns/1ps

// ============================================================
// Gate-Level Self-Checking Testbench for POWER-AWARE PC CONTROL
//
// DUT:
//   pc_control
//
// Power-aware inputs/behavior:
//   branch_imm_iso = (branch && branch_taken) ? imm : 0
//   jump_imm_iso   = jump ? imm : 0
//   jalr_imm_iso   = jalr ? imm : 0
//   rdata1_iso     = jalr ? rdata1 : 0
//
// The workload exercises:
//   - default PC + 4
//   - branch taken / not taken
//   - jump
//   - JALR
//   - link output
//   - combinations of control signals to verify priority
//   - inactive windows with noisy operands/immediates for VCD power
//
// Use the same stimulus values/control sequence for the baseline
// version later so the two VCD power results are comparable.
// ============================================================

module tb_pc_control_gls_power;

    reg [31:0] pc;
    reg [31:0] imm;
    reg [31:0] rdata1;

    reg        branch;
    reg        branch_taken;
    reg        jump;
    reg        jalr;
    reg        link;

    wire [31:0] next_pc;
    wire [31:0] pc_plus4_out;

    integer tests;
    integer errors;
    integer k;

    pc_control dut (
        .pc            (pc),
        .imm           (imm),
        .rdata1        (rdata1),
        .branch        (branch),
        .branch_taken  (branch_taken),
        .jump          (jump),
        .jalr          (jalr),
        .link          (link),
        .next_pc       (next_pc),
        .pc_plus4_out  (pc_plus4_out)
    );

    task check_output;
        input [127:0] name;
        input [31:0]  expected_next_pc;
        input [31:0]  expected_pc_plus4;
        begin
            #2;
            tests = tests + 1;

            if ((next_pc !== expected_next_pc) ||
                (pc_plus4_out !== expected_pc_plus4)) begin

                $display("[FAIL] %-28s | pc=%b imm=%b r1=%b | br=%b taken=%b jump=%b jalr=%b link=%b | expected next=%b link=%b actual next=%b link=%b",
                         name, pc, imm, rdata1,
                         branch, branch_taken, jump, jalr, link,
                         expected_next_pc, expected_pc_plus4,
                         next_pc, pc_plus4_out);
                errors = errors + 1;
            end
            else begin
                $display("[PASS] %-28s | next_pc=%b pc_plus4_out=%b",
                         name, next_pc, pc_plus4_out);
            end
        end
    endtask

    task test_default;
        input [127:0] name;
        input [31:0]  t_pc;
        input [31:0]  t_imm;
        input [31:0]  t_rdata1;
        input         t_link;
        begin
            pc           = t_pc;
            imm          = t_imm;
            rdata1       = t_rdata1;
            branch       = 1'b0;
            branch_taken = 1'b0;
            jump         = 1'b0;
            jalr         = 1'b0;
            link         = t_link;

            check_output(name, t_pc + 32'd4,
                         t_link ? (t_pc + 32'd4) : 32'b0);
        end
    endtask

    task test_branch;
        input [127:0] name;
        input [31:0]  t_pc;
        input [31:0]  t_imm;
        input         t_taken;
        input         t_link;
        begin
            pc           = t_pc;
            imm          = t_imm;
            rdata1       = 32'b10101010101010101010101010101010;
            branch       = 1'b1;
            branch_taken = t_taken;
            jump         = 1'b0;
            jalr         = 1'b0;
            link         = t_link;

            if (t_taken)
                check_output(name, t_pc + t_imm,
                             t_link ? (t_pc + 32'd4) : 32'b0);
            else
                check_output(name, t_pc + 32'd4,
                             t_link ? (t_pc + 32'd4) : 32'b0);
        end
    endtask

    task test_jump;
        input [127:0] name;
        input [31:0]  t_pc;
        input [31:0]  t_imm;
        input         t_link;
        begin
            pc           = t_pc;
            imm          = t_imm;
            rdata1       = 32'b11001100110011001100110011001100;
            branch       = 1'b0;
            branch_taken = 1'b0;
            jump         = 1'b1;
            jalr         = 1'b0;
            link         = t_link;

            check_output(name, t_pc + t_imm,
                         t_link ? (t_pc + 32'd4) : 32'b0);
        end
    endtask

    task test_jalr;
        input [127:0] name;
        input [31:0]  t_pc;
        input [31:0]  t_imm;
        input [31:0]  t_rdata1;
        input         t_link;
        begin
            pc           = t_pc;
            imm          = t_imm;
            rdata1       = t_rdata1;
            branch       = 1'b0;
            branch_taken = 1'b0;
            jump         = 1'b0;
            jalr         = 1'b1;
            link         = t_link;

            check_output(name, t_rdata1 + t_imm,
                         t_link ? (t_pc + 32'd4) : 32'b0);
        end
    endtask

    task test_priority_branch_over_jump;
        input [127:0] name;
        input [31:0]  t_pc;
        input [31:0]  t_imm;
        input         t_taken;
        input         t_rdata1;
        begin
            pc           = t_pc;
            imm          = t_imm;
            rdata1       = {31'b0, t_rdata1};
            branch       = 1'b1;
            branch_taken = t_taken;
            jump         = 1'b1;
            jalr         = 1'b1;
            link         = 1'b1;

            if (t_taken)
                check_output(name, t_pc + t_imm, t_pc + 32'd4);
            else
                // Branch condition is false, so jump has priority over JALR.
                check_output(name, t_pc + t_imm, t_pc + 32'd4);
        end
    endtask

    task test_priority_jump_over_jalr;
        input [127:0] name;
        input [31:0]  t_pc;
        input [31:0]  t_imm;
        input [31:0]  t_rdata1;
        begin
            pc           = t_pc;
            imm          = t_imm;
            rdata1       = t_rdata1;
            branch       = 1'b0;
            branch_taken = 1'b0;
            jump         = 1'b1;
            jalr         = 1'b1;
            link         = 1'b1;

            check_output(name, t_pc + t_imm, t_pc + 32'd4);
        end
    endtask

    initial begin
        tests  = 0;
        errors = 0;

        pc            = 32'b0;
        imm           = 32'b0;
        rdata1        = 32'b0;
        branch        = 1'b0;
        branch_taken  = 1'b0;
        jump          = 1'b0;
        jalr          = 1'b0;
        link          = 1'b0;

        $dumpfile("pc_control_gls_power.vcd");
        $dumpvars(0, tb_pc_control_gls_power);

        // =====================================================
        // 1. BASIC PC + 4 / LINK WORKLOAD
        // =====================================================

        test_default("DEFAULT NO LINK",
                     32'b00000000000000000000000010011000,
                     32'b11111111111111111111000000000000,
                     32'b10101010101010101010101010101010,
                     1'b0);

        test_default("DEFAULT WITH LINK",
                     32'b00000000000000000000100100000000,
                     32'b00000000000000000000000101010101,
                     32'b01010101010101010101010101010101,
                     1'b1);

        test_default("DEFAULT NOISY INPUTS",
                     32'b00000000000000010000000000000000,
                     32'b11110000111100001111000011110000,
                     32'b00001111000011110000111100001111,
                     1'b0);

        // =====================================================
        // 2. BRANCH WORKLOAD
        // =====================================================

        test_branch("BRANCH TAKEN POSITIVE",
                    32'b00000000000000000000000011001000,
                    32'b00000000000000000000000000001000,
                    1'b1,
                    1'b0);

        test_branch("BRANCH TAKEN NEGATIVE",
                    32'b00000000000000000000000100000000,
                    32'b11111111111111111111111111110000,
                    1'b1,
                    1'b0);

        test_branch("BRANCH NOT TAKEN",
                    32'b00000000000000000000000100010000,
                    32'b00000000000000000000000000100000,
                    1'b0,
                    1'b0);

        test_branch("BRANCH TAKEN WITH LINK",
                    32'b00000000000000000000000101000000,
                    32'b00000000000000000000000000010000,
                    1'b1,
                    1'b1);

        // =====================================================
        // 3. JUMP WORKLOAD
        // =====================================================

        test_jump("JUMP NO LINK",
                  32'b00000000000000000000000110000000,
                  32'b00000000000000000000000000110000,
                  1'b0);

        test_jump("JUMP WITH LINK",
                  32'b00000000000000000000000111000000,
                  32'b11111111111111111111111111100000,
                  1'b1);

        // =====================================================
        // 4. JALR WORKLOAD
        // =====================================================

        test_jalr("JALR NO LINK",
                  32'b00000000000000000000001000000000,
                  32'b00000000000000000000000000010100,
                  32'b00000000000000000000100000000000,
                  1'b0);

        test_jalr("JALR WITH LINK",
                  32'b00000000000000000000001001000000,
                  32'b11111111111111111111111111111000,
                  32'b00000000000000000000101000000000,
                  1'b1);

        test_jalr("JALR NEGATIVE IMM",
                  32'b00000000000000000000001010000000,
                  32'b11111111111111111111111111110100,
                  32'b00000000000000000000110000000000,
                  1'b0);

        // =====================================================
        // 5. PRIORITY CHECKS
        //
        // Source priority:
        //   branch && taken
        //   else jump
        //   else jalr
        // =====================================================

        test_priority_branch_over_jump(
                  "PRIORITY BRANCH OVER JUMP",
                  32'b00000000000000000000110100000000,
                  32'b00000000000000000000000000000100,
                  1'b1,
                  1'b1);

        test_priority_branch_over_jump(
                  "FALSE BRANCH -> JUMP",
                  32'b00000000000000000000110110000000,
                  32'b00000000000000000000000000001000,
                  1'b0,
                  1'b1);

        test_priority_jump_over_jalr(
                  "PRIORITY JUMP OVER JALR",
                  32'b00000000000000000000111000000000,
                  32'b00000000000000000000000000001100,
                  32'b00000000000000000001000000000000);

        // =====================================================
        // 6. SAME-STYLE DETERMINISTIC ACTIVITY WORKLOAD
        //
        // Common stimulus sequence to reuse for baseline.
        // Inputs remain active while controls vary.
        // =====================================================

        for (k = 0; k < 64; k = k + 1) begin
            pc = 32'b00000000000000000001000000000000
                 + (k * 32'd4);

            imm = 32'b00000000000000000000000000000000
                  + (k * 32'd12);

            rdata1 = 32'b10100101101001011010010110100101
                     ^ (k * 32'b00000000000000010001000100010001);

            branch = k[0];
            branch_taken = k[1];
            jump = k[2];
            jalr = k[3];
            link = k[4];

            #1;
        end

        // =====================================================
        // 7. INACTIVE WINDOWS WITH NOISY OPERANDS
        //
        // These are particularly useful for showing activity
        // isolation in VCD-based power analysis.
        // =====================================================

        branch       = 1'b0;
        branch_taken = 1'b0;
        jump         = 1'b0;
        jalr         = 1'b0;
        link         = 1'b0;

        for (k = 0; k < 32; k = k + 1) begin
            pc = 32'b00110011001100110011001100110011
                 ^ (k * 32'b00000000000000010010010010010010);

            imm = 32'b11110000111100001111000011110000
                  ^ (k * 32'b00000000000000110101010101010101);

            rdata1 = 32'b01010101010101010101010101010101
                     ^ (k * 32'b00000000000000001100110011001100);

            #1;
        end

        // =====================================================
        // 8. FINAL FUNCTIONAL CHECK
        // =====================================================

        test_default("FINAL PC + 4",
                     32'b00000000000000000000111100000000,
                     32'b00000000000000000000000000000101,
                     32'b11111111111111111111111111111111,
                     1'b0);

        $display("================================================");
        $display("PC CONTROL GLS TEST SUMMARY");
        $display("TOTAL TESTS  = %0d", tests);
        $display("TOTAL ERRORS = %0d", errors);

        if (errors == 0)
            $display("GATE-LEVEL PC CONTROL SELF-TEST PASSED");
        else
            $display("GATE-LEVEL PC CONTROL SELF-TEST FAILED");

        $display("================================================");

        $finish;
    end

endmodule
