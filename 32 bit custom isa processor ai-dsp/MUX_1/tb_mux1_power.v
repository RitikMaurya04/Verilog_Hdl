`timescale 1ns/1ps

module tb_mux_1_power;

    reg        clk;
    reg [31:0] SrcC;
    reg [31:0] IMM;
    reg        alumuxsel1;
    reg        alumuxen1;

    wire [31:0] out;

    // DUT
    mux_1 dut (
        .SrcC(SrcC),
        .IMM(IMM),
        .alumuxsel1(alumuxsel1),
        .alumuxen1(alumuxen1),
        .out(out)
    );

    // 100 MHz clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("mux_1_workload.vcd");
        $dumpvars(0, tb_mux_1_power);

        // Initial values
        SrcC       = 32'd0;
        IMM        = 32'd0;
        alumuxsel1 = 1'b0;
        alumuxen1  = 1'b0;

        #20;

        // =========================================================
        // WORKLOAD 1: MUX ACTIVE
        // Same workload as baseline
        // =========================================================

        alumuxen1 = 1'b1;

        SrcC = 32'd100;
        IMM  = 32'd500;
        alumuxsel1 = 1'b0;

        #20;

        SrcC = 32'd200;

        #20;

        SrcC = 32'd300;

        #20;

        SrcC = 32'd400;

        #20;

        // =========================================================
        // WORKLOAD 2: IMM selected
        // =========================================================

        alumuxsel1 = 1'b1;

        #20;

        IMM = 32'd600;

        #20;

        IMM = 32'd700;

        #20;

        IMM = 32'd800;

        #20;

        // =========================================================
        // WORKLOAD 3: Toggle select
        // =========================================================

        alumuxsel1 = 1'b0;

        #20;

        alumuxsel1 = 1'b1;

        #20;

        alumuxsel1 = 1'b0;

        #20;

        alumuxsel1 = 1'b1;

        #20;

        // =========================================================
        // WORKLOAD 4: Both inputs change
        // =========================================================

        SrcC = 32'd1000;
        IMM  = 32'd2000;

        #20;

        SrcC = 32'd3000;
        IMM  = 32'd4000;

        #20;

        SrcC = 32'd5000;
        IMM  = 32'd6000;

        #20;

        SrcC = 32'd7000;
        IMM  = 32'd8000;

        #20;

        // =========================================================
        // WORKLOAD 5: MUX DISABLED
        //
        // Inputs continue switching exactly like a real inactive
        // datapath, but alumuxen1 isolates the output.
        // =========================================================

        alumuxen1 = 1'b0;

        repeat (20) begin
            #10;
            SrcC = $random;
            IMM  = $random;
            alumuxsel1 = ~alumuxsel1;
        end

        // =========================================================
        // WORKLOAD 6: MUX ACTIVE AGAIN
        // =========================================================

        alumuxen1 = 1'b1;

        repeat (20) begin
            #10;
            SrcC = $random;
            IMM  = $random;
            alumuxsel1 = ~alumuxsel1;
        end

        #50;

        $finish;
    end

endmodule