`timescale 1ns/1ps

module tb_instruction_memory_power;

    reg         ren;
    reg  [31:0] addr;
    wire [31:0] data;

    // DUT
    instruction_memory dut (
        .ren  (ren),
        .addr (addr),
        .data (data)
    );

    // Clock used only to control the workload.
    // The instruction memory itself is asynchronous.
    reg clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    integer i;

    initial begin
        $dumpfile("instruction_memory_workload.vcd");
        $dumpvars(0, tb_instruction_memory_power);

        ren  = 1'b0;
        addr = 32'd0;

        // Allow initialization / program.hex loading to complete.
        #10;

        $display("==============================================================");
        $display(" Instruction Memory Workload / Power Analysis");
        $display("==============================================================");
        $display(" Time(ns)   REN   Address      Word Index    Instruction");
        $display("--------------------------------------------------------------");

        // ----------------------------------------------------------
        // Workload:
        // Sequential instruction fetch through the 128-word memory.
        // The DUT indexes memory with addr[8:2], so addresses are
        // 0, 4, 8, ... 508.
        // ----------------------------------------------------------
        ren = 1'b1;

        for (i = 0; i < 128; i = i + 1) begin
            @(negedge clk);
            addr = i * 4;

            #1;
            $display(" %8t    %1b    %8d      %8d      %08h",
                     $time, ren, addr, i, data);
        end

        // ----------------------------------------------------------
        // Read-disable / isolation activity
        // ----------------------------------------------------------
        @(negedge clk);
        ren = 1'b0;
        addr = 32'd0;
        #1;
        $display(" %8t    %1b    %8d      %8d      %08h   <-- READ DISABLED",
                 $time, ren, addr, 0, data);

        @(negedge clk);
        addr = 32'd128;
        #1;
        $display(" %8t    %1b    %8d      %8d      %08h   <-- READ DISABLED",
                 $time, ren, addr, 32, data);

        @(negedge clk);
        addr = 32'd256;
        #1;
        $display(" %8t    %1b    %8d      %8d      %08h   <-- READ DISABLED",
                 $time, ren, addr, 64, data);

        // Re-enable read and fetch a few instructions again.
        ren = 1'b1;

        @(negedge clk);
        addr = 32'd0;
        #1;
        $display(" %8t    %1b    %8d      %8d      %08h",
                 $time, ren, addr, 0, data);

        @(negedge clk);
        addr = 32'd4;
        #1;
        $display(" %8t    %1b    %8d      %8d      %08h",
                 $time, ren, addr, 1, data);

        @(negedge clk);
        addr = 32'd8;
        #1;
        $display(" %8t    %1b    %8d      %8d      %08h",
                 $time, ren, addr, 2, data);

        $display("--------------------------------------------------------------");
        $display("Workload complete. VCD: instruction_memory_workload.vcd");
        $display("==============================================================");

        #10;
        $finish;
    end

endmodule
