`timescale 1ns/1ps

module tb_program_counter_baseline_power;

    reg         clk;
    reg         rst;
    reg  [31:0] pcinst;
    wire [31:0] pcoutinst;

    // DUT
    program_counter_baseline dut (
        .clk       (clk),
        .rst       (rst),
        .pcinst    (pcinst),
        .pcoutinst (pcoutinst)
    );

    // 10 ns clock = 100 MHz
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("program_counter_baseline_workload.vcd");
        $dumpvars(0, tb_program_counter_baseline_power);

        rst    = 1'b1;
        pcinst = 32'd0;

        $display("==============================================================");
        $display(" Program Counter Baseline Workload / Gate-Level Power Analysis");
        $display("==============================================================");
        $display(" Time(ns)   RST       PC Input       PC Output");
        $display("--------------------------------------------------------------");

        // ----------------------------------------------------------
        // RESET
        // ----------------------------------------------------------
        #2;

        $display(" %8t    %1b     %10d     %10d   <-- RESET",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        rst = 1'b0;

        // ----------------------------------------------------------
        // SAME PC WORKLOAD AS THE ENABLE VERSION
        // Normal sequential instruction fetch
        // ----------------------------------------------------------

        @(negedge clk);
        pcinst = 32'd0;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd4;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd8;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd12;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd16;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd20;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd24;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd28;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        // ----------------------------------------------------------
        // Same PC values used during the PCEN=0 period in the
        // enable version. Baseline always captures them.
        // ----------------------------------------------------------

        @(negedge clk);
        pcinst = 32'd100;
        #1;
        $display(" %8t    %1b     %10d     %10d   <-- BASELINE UPDATE",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd200;
        #1;
        $display(" %8t    %1b     %10d     %10d   <-- BASELINE UPDATE",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd300;
        #1;
        $display(" %8t    %1b     %10d     %10d   <-- BASELINE UPDATE",
                 $time, rst, pcinst, pcoutinst);

        // ----------------------------------------------------------
        // Re-enable equivalent workload
        // ----------------------------------------------------------

        @(negedge clk);
        pcinst = 32'd32;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd36;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd40;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        // ----------------------------------------------------------
        // Branch / jump-like PC values
        // ----------------------------------------------------------

        @(negedge clk);
        pcinst = 32'd128;
        #1;
        $display(" %8t    %1b     %10d     %10d   <-- BRANCH TARGET",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd132;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd136;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd512;
        #1;
        $display(" %8t    %1b     %10d     %10d   <-- JUMP TARGET",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd516;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        // ----------------------------------------------------------
        // Same workload values as the second PCEN=0 period.
        // Baseline still updates every cycle.
        // ----------------------------------------------------------

        @(negedge clk);
        pcinst = 32'd1000;
        #1;
        $display(" %8t    %1b     %10d     %10d   <-- BASELINE UPDATE",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd2000;
        #1;
        $display(" %8t    %1b     %10d     %10d   <-- BASELINE UPDATE",
                 $time, rst, pcinst, pcoutinst);

        // ----------------------------------------------------------
        // Final PC updates
        // ----------------------------------------------------------

        @(negedge clk);
        pcinst = 32'd520;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        @(negedge clk);
        pcinst = 32'd524;
        #1;
        $display(" %8t    %1b     %10d     %10d",
                 $time, rst, pcinst, pcoutinst);

        $display("--------------------------------------------------------------");
        $display("Workload complete.");
        $display("VCD: program_counter_baseline_workload.vcd");
        $display("==============================================================");

        #10;
        $finish;
    end

endmodule
