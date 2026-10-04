`timescale 1ns/1ps

module tb_program_counter_power;

    reg         clk;
    reg         rst;
    reg         pcen;
    reg  [31:0] pcinst;
    wire [31:0] pcoutinst;

    // DUT
    program_counter dut (
        .clk      (clk),
        .rst      (rst),
        .pcen     (pcen),
        .pcinst   (pcinst),
        .pcoutinst(pcoutinst)
    );

    // 10 ns clock = 100 MHz
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("program_counter_workload.vcd");
        $dumpvars(0, tb_program_counter_power);

        rst   = 1'b1;
        pcen  = 1'b0;
        pcinst = 32'd0;

        $display("==============================================================");
        $display(" Program Counter Workload / Gate-Level Power Analysis");
        $display("==============================================================");
        $display(" Time(ns)   RST   PCEN       PC Input       PC Output");
        $display("--------------------------------------------------------------");

        // ----------------------------------------------------------
        // RESET
        // ----------------------------------------------------------

        #2;

        $display(" %8t    %1b     %1b     %10d     %10d   <-- RESET",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);

        rst = 1'b0;
        pcen = 1'b1;
        pcinst = 32'd0;

        // ----------------------------------------------------------
        // NORMAL SEQUENTIAL INSTRUCTION FETCH
        // PC = 0, 4, 8, 12, ...
        // ----------------------------------------------------------

        @(negedge clk);
        pcinst = 32'd0;
        #1;
        $display(" %8t    %1b     %1b     %10d     %10d",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd4;
        #1;
        $display(" %8t    %1b     %1b     %10d     %10d",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd8;
        #1;
        $display(" %8t    %1b     %1b     %10d     %10d",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd12;
        #1;
        $display(" %8t    %1b     %1b     %10d     %10d",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd16;
        #1;
        $display(" %8t    %1b     %1b     %10d     %10d",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd20;
        #1;
        $display(" %8t    %1b     %1b     %10d     %10d",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd24;
        #1;
        $display(" %8t    %1b     %1b     %10d     %10d",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd28;
        #1;
        $display(" %8t    %1b     %1b     %10d     %10d",
                 $time, rst, pcen, pcinst, pcoutinst);

        // ----------------------------------------------------------
        // PC HOLD / ENABLE DISABLED
        // ----------------------------------------------------------

        @(negedge clk);
        pcen = 1'b0;
        pcinst = 32'd100;
        #1;

        $display(" %8t    %1b     %1b     %10d     %10d   <-- PC HOLD",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd200;
        #1;

        $display(" %8t    %1b     %1b     %10d     %10d   <-- PC HOLD",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd300;
        #1;

        $display(" %8t    %1b     %1b     %10d     %10d   <-- PC HOLD",
                 $time, rst, pcen, pcinst, pcoutinst);

        // ----------------------------------------------------------
        // RE-ENABLE PC
        // ----------------------------------------------------------

        @(negedge clk);
        pcen = 1'b1;
        pcinst = 32'd32;
        #1;

        $display(" %8t    %1b     %1b     %10d     %10d   <-- PC ENABLED",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd36;
        #1;

        $display(" %8t    %1b     %1b     %10d     %10d",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd40;
        #1;

        $display(" %8t    %1b     %1b     %10d     %10d",
                 $time, rst, pcen, pcinst, pcoutinst);

        // ----------------------------------------------------------
        // BRANCH / JUMP-LIKE PC VALUES
        // ----------------------------------------------------------

        @(negedge clk);
        pcinst = 32'd128;
        #1;

        $display(" %8t    %1b     %1b     %10d     %10d   <-- BRANCH TARGET",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd132;
        #1;

        $display(" %8t    %1b     %1b     %10d     %10d",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd136;
        #1;

        $display(" %8t    %1b     %1b     %10d     %10d",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd512;
        #1;

        $display(" %8t    %1b     %1b     %10d     %10d   <-- JUMP TARGET",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd516;
        #1;

        $display(" %8t    %1b     %1b     %10d     %10d",
                 $time, rst, pcen, pcinst, pcoutinst);

        // ----------------------------------------------------------
        // SECOND PC HOLD PERIOD
        // ----------------------------------------------------------

        @(negedge clk);
        pcen = 1'b0;
        pcinst = 32'd1000;
        #1;

        $display(" %8t    %1b     %1b     %10d     %10d   <-- PC HOLD",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd2000;
        #1;

        $display(" %8t    %1b     %1b     %10d     %10d   <-- PC HOLD",
                 $time, rst, pcen, pcinst, pcoutinst);

        // ----------------------------------------------------------
        // FINAL ENABLE
        // ----------------------------------------------------------

        @(negedge clk);
        pcen = 1'b1;
        pcinst = 32'd520;
        #1;

        $display(" %8t    %1b     %1b     %10d     %10d   <-- PC ENABLED",
                 $time, rst, pcen, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd524;
        #1;

        $display(" %8t    %1b     %1b     %10d     %10d",
                 $time, rst, pcen, pcinst, pcoutinst);

        $display("--------------------------------------------------------------");
        $display("Workload complete.");
        $display("VCD: program_counter_workload.vcd");
        $display("==============================================================");

        #10;
        $finish;
    end

endmodule