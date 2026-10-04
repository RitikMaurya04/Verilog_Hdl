`timescale 1ns/1ps

// ============================================================
// Gate-Level / Power-Analysis Testbench for Power-Aware ALU
//
// DUT:
//   alu_ai
//
// Purpose:
//   1. Verify the synthesized gate-level ALU.
//   2. Exercise all implemented operation classes.
//   3. Create switching activity for VCD-based OpenSTA power.
//   4. Stress the isolation path while ALUEnable = 0 by
//      changing A/B/C/alucontrol/mode.
//
// IMPORTANT:
//   Use the same stimulus sequence for the matching no-enable
//   ALU so the power comparison remains fair.
// ============================================================

module tb_alu_ai_enable_gls_power;

    reg [31:0] A;
    reg [31:0] B;
    reg [31:0] C;

    reg        ALUEnable;
    reg        alu_enA;
    reg        alu_enB;
    reg        alu_enC;

    reg [4:0]  alucontrol;
    reg [1:0]  mode;

    wire [31:0] Result;
    wire        zero;

    alu_ai dut (
        .A(A),
        .B(B),
        .C(C),
        .ALUEnable(ALUEnable),
        .alu_enA(alu_enA),
        .alu_enB(alu_enB),
        .alu_enC(alu_enC),
        .alucontrol(alucontrol),
        .mode(mode),
        .Result(Result),
        .zero(zero)
    );

    integer errors;
    integer k;

    // ---------------------------------------------------------
    // Helper task: apply one functional vector and verify.
    // ---------------------------------------------------------
    task run_case;
        input [127:0] name;
        input [1:0]   mode_i;
        input [4:0]   control_i;
        input [31:0]  A_i;
        input [31:0]  B_i;
        input [31:0]  C_i;
        input [31:0]  expected_i;

        begin
            A          = A_i;
            B          = B_i;
            C          = C_i;
            mode       = mode_i;
            alucontrol = control_i;

            // Match operand usage for each ALU mode.
            case (mode_i)
                2'b00: begin
                    alu_enA = 1'b1;
                    alu_enB = 1'b1;
                    alu_enC = 1'b1;
                end

                2'b01: begin
                    alu_enA = 1'b1;
                    alu_enB = 1'b1;
                    alu_enC = 1'b0;
                end

                2'b10: begin
                    alu_enA = 1'b1;
                    alu_enB = 1'b0;
                    alu_enC = 1'b0;
                end

                2'b11: begin
                    alu_enA = 1'b1;
                    alu_enB = 1'b0;
                    alu_enC = 1'b1;
                end

                default: begin
                    alu_enA = 1'b0;
                    alu_enB = 1'b0;
                    alu_enC = 1'b0;
                end
            endcase

            ALUEnable = 1'b1;
            #3;

            if (Result !== expected_i) begin
                $display("[FAIL] %-16s expected=%h actual=%h",
                         name, expected_i, Result);
                errors = errors + 1;
            end
            else begin
                $display("[PASS] %-16s expected=%h actual=%h",
                         name, expected_i, Result);
            end

            // Additional enabled switching activity.
            // This is not checked; it is part of the power window.
            for (k = 0; k < 3; k = k + 1) begin
                A          = A_i ^ (32'h11111111 << k);
                B          = B_i ^ (32'h22222222 >> k);
                C          = C_i ^ (32'h33333333 << k);
                alucontrol = control_i ^ k[4:0];
                mode       = mode_i;
                #1;
            end
        end
    endtask

    // ---------------------------------------------------------
    // Disabled/isolation activity window.
    //
    // The external inputs continue toggling while ALUEnable=0.
    // In the isolated implementation, these transitions should
    // be blocked from the ALU datapath/control logic.
    // ---------------------------------------------------------
    task run_disabled_window;
        input integer cycles;
        begin
            ALUEnable = 1'b0;
            alu_enA   = 1'b1;
            alu_enB   = 1'b1;
            alu_enC   = 1'b1;

            for (k = 0; k < cycles; k = k + 1) begin
                A          = 32'h13579BDF ^ (k * 32'h01010101);
                B          = 32'h2468ACE0 ^ (k * 32'h10101010);
                C          = 32'h0F1E2D3C ^ (k * 32'h00110011);
                alucontrol = k[4:0];
                mode       = k[1:0];
                #1;
            end
        end
    endtask

    initial begin
        errors = 0;

        // Initial values.
        A          = 32'b0;
        B          = 32'b0;
        C          = 32'b0;
        ALUEnable  = 1'b0;
        alu_enA    = 1'b0;
        alu_enB    = 1'b0;
        alu_enC    = 1'b0;
        alucontrol = 5'b11110;
        mode       = 2'b00;

        $dumpfile("alu_ai_enable_gls_power.vcd");
        $dumpvars(0, tb_alu_ai_enable_gls_power);

        // -----------------------------------------------------
        // Baseline disabled activity before functional tests.
        // -----------------------------------------------------
        run_disabled_window(40);

        // =====================================================
        // R4 TESTS
        //
        // A = 10, B = 20, C = 30
        // =====================================================
        run_case("R4 ADD",          2'b00, 5'b00000,
                 32'd10, 32'd20, 32'd30, 32'd60);

        run_case("R4 SUB",          2'b00, 5'b00001,
                 32'd10, 32'd20, 32'd30, 32'hFFFFFFD8);

        run_case("R4 OR",           2'b00, 5'b00010,
                 32'd10, 32'd20, 32'd30, 32'd30);

        run_case("R4 AND",          2'b00, 5'b00011,
                 32'd10, 32'd20, 32'd30, 32'd0);

        run_case("R4 NAND",         2'b00, 5'b00100,
                 32'd10, 32'd20, 32'd30, 32'hFFFFFFFF);

        run_case("R4 NOR",          2'b00, 5'b00101,
                 32'd10, 32'd20, 32'd30, 32'hFFFFFFE1);

        run_case("R4 XOR",          2'b00, 5'b00110,
                 32'd10, 32'd20, 32'd30, 32'd0);

        run_case("R4 XNOR",         2'b00, 5'b00111,
                 32'd10, 32'd20, 32'd30, 32'hFFFFFFFF);

        run_case("R4 XOR-AND",      2'b00, 5'b10110,
                 32'd10, 32'd20, 32'd30, 32'd30);

        run_case("R4 NOT-AND-XOR",  2'b00, 5'b10101,
                 32'd10, 32'd20, 32'd30, 32'hFFFFFFE1);

        run_case("R4 NOT-OR-AND",   2'b00, 5'b11001,
                 32'd10, 32'd20, 32'd30, 32'd0);

        run_case("R4 AND-NOT2",     2'b00, 5'b11010,
                 32'd10, 32'd20, 32'd30, 32'd0);

        run_case("R4 INC",          2'b00, 5'b01001,
                 32'd10, 32'd20, 32'd30, 32'd63);

        run_case("R4 DEC",          2'b00, 5'b01010,
                 32'd10, 32'd20, 32'd30, 32'd57);

        run_case("R4 MAX",          2'b00, 5'b01100,
                 32'd10, 32'd20, 32'd30, 32'd30);

        run_case("R4 MIN",          2'b00, 5'b01101,
                 32'd10, 32'd20, 32'd30, 32'd10);

        run_case("R4 MAC",          2'b00, 5'b01110,
                 32'd10, 32'd20, 32'd30, 32'd230);

        run_case("R4 MSC",          2'b00, 5'b01111,
                 32'd10, 32'd20, 32'd30, 32'd170);

        run_disabled_window(40);

        // =====================================================
        // R3 TESTS
        // =====================================================
        run_case("R3 ADD",          2'b01, 5'b00000,
                 32'h12345678, 32'h01020304, 32'd0, 32'h1336597C);

        run_case("R3 SUB",          2'b01, 5'b00001,
                 32'h12345678, 32'h01020304, 32'd0, 32'h11325374);

        run_case("R3 OR",           2'b01, 5'b00010,
                 32'h12345678, 32'h01020304, 32'd0, 32'h1336577C);

        run_case("R3 AND",          2'b01, 5'b00011,
                 32'h12345678, 32'h01020304, 32'd0, 32'h00000200);

        run_case("R3 NAND",         2'b01, 5'b00100,
                 32'h12345678, 32'h01020304, 32'd0, 32'hFFFFFDFF);

        run_case("R3 NOR",          2'b01, 5'b00101,
                 32'h12345678, 32'h01020304, 32'd0, 32'hECC9A883);

        run_case("R3 XOR",          2'b01, 5'b00110,
                 32'h12345678, 32'h01020304, 32'd0, 32'h1336557C);

        run_case("R3 XNOR",         2'b01, 5'b00111,
                 32'h12345678, 32'h01020304, 32'd0, 32'hECC9AA83);

        run_case("R3 AND-NOT",      2'b01, 5'b11100,
                 32'h12345678, 32'h01020304, 32'd0, 32'h12345478);

        run_case("R3 OR-NOT",       2'b01, 5'b11011,
                 32'h12345678, 32'h01020304, 32'd0, 32'hFEFDFEFB);

        run_case("R3 INC",          2'b01, 5'b01001,
                 32'h12345678, 32'h01020304, 32'd0, 32'h12345679);

        run_case("R3 DEC",          2'b01, 5'b01010,
                 32'h12345678, 32'h01020304, 32'd0, 32'h12345677);

        run_case("R3 SLL",          2'b01, 5'b10000,
                 32'h12345678, 32'd4, 32'd0, 32'h23456780);

        run_case("R3 SLT",          2'b01, 5'b10001,
                 32'hFFFFFFFF, 32'd1, 32'd0, 32'd1);

        run_case("R3 SRL",          2'b01, 5'b10010,
                 32'h80000000, 32'd4, 32'd0, 32'h08000000);

        run_case("R3 SRA",          2'b01, 5'b10011,
                 32'h80000000, 32'd4, 32'd0, 32'hF8000000);

        run_case("R3 SGT",          2'b01, 5'b10100,
                 32'd10, 32'd3, 32'd0, 32'd1);

        run_case("R3 MAX",          2'b01, 5'b01100,
                 32'hFFFFFFFF, 32'd3, 32'd0, 32'd3);

        run_case("R3 MIN",          2'b01, 5'b01101,
                 32'hFFFFFFFF, 32'd3, 32'd0, 32'hFFFFFFFF);

        run_case("R3 MUL",          2'b01, 5'b11111,
                 32'h00000123, 32'h00000011, 32'd0, 32'h00001353);

        run_case("R3 VADD8",        2'b01, 5'b10111,
                 32'h12345678, 32'h01020304, 32'd0, 32'h1336597C);

        run_case("R3 VMAX8",        2'b01, 5'b11000,
                 32'h7F80FF01, 32'h0102FE03, 32'd0, 32'h7F02FF03);

        run_case("R3 SDOTP4",       2'b01, 5'b11101,
                 32'h01020304, 32'h04030201, 32'd0, 32'd20);

        run_disabled_window(40);

        // =====================================================
        // R2 TESTS
        // =====================================================
        run_case("R2 NEG",          2'b10, 5'b00000,
                 32'hFFFFFF80, 32'd0, 32'd0, 32'd128);

        run_case("R2 ABS",          2'b10, 5'b00001,
                 32'hFFFFFF80, 32'd0, 32'd0, 32'd128);

        run_case("R2 NOT",          2'b10, 5'b01000,
                 32'hFFFFFF80, 32'd0, 32'd0, 32'h0000007F);

        run_case("R2 INC",          2'b10, 5'b01001,
                 32'hFFFFFF80, 32'd0, 32'd0, 32'hFFFFFF81);

        run_case("R2 DEC",          2'b10, 5'b01010,
                 32'hFFFFFF80, 32'd0, 32'd0, 32'hFFFFFF7F);

        run_case("R2 VRELU8",       2'b10, 5'b10110,
                 32'h807FFF01, 32'd0, 32'd0, 32'h007F0001);

        // =====================================================
        // I-TYPE / ADDRESS TESTS
        // =====================================================
        run_case("I ADD",           2'b11, 5'b00000,
                 32'h12345678, 32'd0, 32'd7, 32'h1234567F);

        run_case("I SUB",           2'b11, 5'b00001,
                 32'h12345678, 32'd0, 32'd7, 32'h12345671);

        run_case("I OR",            2'b11, 5'b00010,
                 32'h12345678, 32'd0, 32'd7, 32'h1234567F);

        run_case("I AND",           2'b11, 5'b00011,
                 32'h12345678, 32'd0, 32'd7, 32'h00000000);

        run_case("I XOR",           2'b11, 5'b00110,
                 32'h12345678, 32'd0, 32'd7, 32'h1234567F);

        run_case("I SLL",           2'b11, 5'b10000,
                 32'h12345678, 32'd0, 32'd7, 32'h1A2B3C00);

        run_case("I SRL",           2'b11, 5'b10010,
                 32'h12345678, 32'd0, 32'd7, 32'h002468AC);

        run_case("I SRA",           2'b11, 5'b10011,
                 32'h92345678, 32'd0, 32'd7, 32'hFF2468AC);

        run_disabled_window(80);

        // -----------------------------------------------------
        // Extra long activity window.
        // Enables and disables the ALU repeatedly while inputs
        // keep changing. This expands the VCD power-analysis
        // window without changing the functional behavior.
        // -----------------------------------------------------
        for (k = 0; k < 200; k = k + 1) begin

            A          = 32'h13579BDF ^ (k * 32'h01020301);
            B          = 32'h2468ACE0 ^ (k * 32'h10203040);
            C          = 32'h0F1E2D3C ^ (k * 32'h00112233);
            alucontrol = k[4:0];
            mode       = k[1:0];

            if ((k % 4) == 0) begin
                ALUEnable = 1'b0;
                alu_enA   = 1'b1;
                alu_enB   = 1'b1;
                alu_enC   = 1'b1;
            end
            else begin
                ALUEnable = 1'b1;

                // Rotate through operand-use patterns.
                case (k[1:0])
                    2'b00: begin
                        alu_enA = 1'b1;
                        alu_enB = 1'b1;
                        alu_enC = 1'b1;
                    end

                    2'b01: begin
                        alu_enA = 1'b1;
                        alu_enB = 1'b1;
                        alu_enC = 1'b0;
                    end

                    2'b10: begin
                        alu_enA = 1'b1;
                        alu_enB = 1'b0;
                        alu_enC = 1'b0;
                    end

                    default: begin
                        alu_enA = 1'b1;
                        alu_enB = 1'b0;
                        alu_enC = 1'b1;
                    end
                endcase
            end

            #1;
        end

        #5;

        $display("========================================");
        if (errors == 0) begin
            $display("GATE-LEVEL ALU ENABLE SELF-TEST PASSED");
            $display("All R4/R3/R2/I-type and AI operations verified.");
            $display("Power-analysis VCD generated successfully.");
        end
        else begin
            $display("GATE-LEVEL ALU ENABLE SELF-TEST FAILED");
            $display("ERRORS = %0d", errors);
        end
        $display("========================================");

        $finish;
    end

endmodule
