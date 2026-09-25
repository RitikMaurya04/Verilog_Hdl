`timescale 1ns/1ps

module data_memory_tb;

    reg        clk;
    reg [31:0] waddr;
    reg [31:0] raddr;
    reg [31:0] wdata;
    reg        wen;
    reg        ren;

    wire [31:0] rdata;

    data_memory dut (
        .clk   (clk),
        .waddr (waddr),
        .raddr (raddr),
        .wdata (wdata),
        .memwrite (wen),
        .memread (ren),
        .rdata (rdata)
    );

    // 100 MHz clock
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin

        $dumpfile("data_memory.vcd");
        $dumpvars(0, data_memory_tb);

        // Initial values
        waddr = 0;
        raddr = 0;
        wdata = 0;
        wen   = 0;
        ren   = 0;

        // ----------------------------------
        // Write some memory locations
        // ----------------------------------
        repeat (16) begin
            @(negedge clk);
            wen   = 1;
            waddr = waddr + 4;
            wdata = wdata + 32'h11111111;
        end

        @(negedge clk);
        wen = 0;

        // ----------------------------------
        // READ ENABLE = 1
        // Read activity enabled
        // ----------------------------------
        ren = 1;

        repeat (100) begin
            @(negedge clk);
            raddr = raddr + 4;
        end

        // ----------------------------------
        // READ ENABLE = 0
        // Read output disabled
        // ----------------------------------
        ren = 0;

        repeat (100) begin
            @(negedge clk);
            raddr = raddr + 4;
        end

        // ----------------------------------
        // Mixed activity
        // ----------------------------------
        repeat (100) begin
            @(negedge clk);

            raddr = raddr + 8;
            ren   = ~ren;
        end

        #20;
        $finish;

    end

endmodule
