`timescale 1ns/1ps

module tb_resultmux_baseline_power;

    reg        clk;
    reg [31:0] Result;
    reg [31:0] RData1;
    reg [31:0] Regdata1;
    reg [31:0] pc_4;
    reg [1:0]  resultsel;

    wire [31:0] out1;

    resultmux_baseline dut (
        .Result(Result),
        .RData1(RData1),
        .Regdata1(Regdata1),
        .pc_4(pc_4),
        .resultsel(resultsel),
        .out1(out1)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Display whenever the output changes
    always @(out1) begin
        $display("TIME=%0t ns | SEL=%b | Result=%0d | RData1=%0d | Regdata1=%0d | PC+4=%0d | OUT=%0d",
                 $time, resultsel, Result, RData1, Regdata1, pc_4, out1);
    end

    initial begin
        $dumpfile("resultmux_baseline_workload.vcd");
        $dumpvars(0, tb_resultmux_baseline_power);

        Result    = 32'd0;
        RData1    = 32'd0;
        Regdata1  = 32'd0;
        pc_4      = 32'd0;
        resultsel = 2'b00;

        #20;

        // Result
        resultsel = 2'b00;
        Result    = 32'd100;
        RData1    = 32'd200;
        Regdata1  = 32'd300;
        pc_4      = 32'd104;
        #20;

        Result = 32'd110;
        #20;
        Result = 32'd120;
        #20;

        // RData1
        resultsel = 2'b01;
        #20;
        RData1 = 32'd210;
        #20;
        RData1 = 32'd220;
        #20;

        // Regdata1
        resultsel = 2'b10;
        #20;
        Regdata1 = 32'd310;
        #20;
        Regdata1 = 32'd320;
        #20;

        // PC + 4
        resultsel = 2'b11;
        #20;
        pc_4 = 32'd124;
        #20;
        pc_4 = 32'd128;
        #20;

        // Same workload as enable version's disabled period
        repeat (30) begin
            #10;
            Result    = $random;
            RData1    = $random;
            Regdata1  = $random;
            pc_4      = pc_4 + 32'd4;
            resultsel = resultsel + 2'b01;
        end

        // Active workload
        resultsel = 2'b00;
        Result    = 32'd1000;
        RData1    = 32'd2000;
        Regdata1  = 32'd3000;
        pc_4      = 32'd4000;
        #20;

        resultsel = 2'b01;
        #20;
        resultsel = 2'b10;
        #20;
        resultsel = 2'b11;
        #20;

        // Same high-activity workload
        repeat (40) begin
            #10;
            Result    = $random;
            RData1    = $random;
            Regdata1  = $random;
            pc_4      = $random;
            resultsel = $random;
        end

        // Final active period
        Result    = 32'd1111;
        RData1    = 32'd2222;
        Regdata1  = 32'd3333;
        pc_4      = 32'd4444;

        resultsel = 2'b00;
        #20;
        resultsel = 2'b01;
        #20;
        resultsel = 2'b10;
        #20;
        resultsel = 2'b11;
        #20;

        #50;
        $finish;
    end

endmodule
