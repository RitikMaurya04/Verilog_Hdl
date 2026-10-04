`timescale 1ns/1ps

module tb_instruction_memory_baseline_power;

    reg  [31:0] addr;
    wire [31:0] data;

    // DUT
    instruction_memory_baseline dut (
        .addr (addr),
        .data (data)
    );

    // Clock used to sequence the same workload
    reg clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    integer i;

    initial begin
        $dumpfile("instruction_memory_baseline_workload.vcd");
        $dumpvars(0, tb_instruction_memory_baseline_power);

        addr = 32'd0;

        #10;

        $display("==============================================================");
        $display(" Instruction Memory Baseline Workload / Power Analysis");
        $display("==============================================================");
        $display(" Time(ns)   Address      Word Index    Instruction");
        $display("--------------------------------------------------------------");

        // ----------------------------------------------------------
        // SAME WORKLOAD AS REN VERSION
        // Sequential instruction fetch through all 128 locations.
        // Memory uses addr[8:2] as the word index.
        // ----------------------------------------------------------

        for (i = 0; i < 128; i = i + 1) begin
            @(negedge clk);

            addr = i * 4;

            #1;

            $display(" %8t    %8d      %8d      %08h",
                     $time, addr, i, data);
        end

        // ----------------------------------------------------------
        // Repeat selected accesses to create additional activity.
        // This is the same type of activity used in the REN version.
        // ----------------------------------------------------------

        @(negedge clk);
        addr = 32'd0;
        #1;
        $display(" %8t    %8d      %8d      %08h",
                 $time, addr, 0, data);

        @(negedge clk);
        addr = 32'd128;
        #1;
        $display(" %8t    %8d      %8d      %08h",
                 $time, addr, 32, data);

        @(negedge clk);
        addr = 32'd256;
        #1;
        $display(" %8t    %8d      %8d      %08h",
                 $time, addr, 64, data);

        @(negedge clk);
        addr = 32'd508;
        #1;
        $display(" %8t    %8d      %8d      %08h",
                 $time, addr, 127, data);

        $display("--------------------------------------------------------------");
        $display("Workload complete.");
        $display("VCD: instruction_memory_baseline_workload.vcd");
        $display("==============================================================");

        #10;
        $finish;
    end

endmodule