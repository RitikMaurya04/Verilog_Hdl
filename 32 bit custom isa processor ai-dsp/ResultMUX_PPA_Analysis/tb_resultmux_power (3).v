`timescale 1ns/1ps

module tb_resultmux_power;

    reg        clk;
    reg [31:0] Result;
    reg [31:0] RData1;
    reg [31:0] Regdata1;
    reg [31:0] pc_4;
    reg [1:0]  resultsel;
    reg        resulten;

    wire [31:0] out1;

    resultmux dut (
        .Result(Result),
        .RData1(RData1),
        .Regdata1(Regdata1),
        .pc_4(pc_4),
        .resultsel(resultsel),
        .resulten(resulten),
        .out1(out1)
    );

    // 100 MHz reference clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Print whenever output changes
    always @(out1) begin
        $display("TIME=%0t ns | EN=%b | SEL=%b | Result=%0d | RData1=%0d | Regdata1=%0d | PC+4=%0d | OUT=%0d",
                 $time, resulten, resultsel, Result, RData1, Regdata1, pc_4, out1);
    end

    initial begin
        $dumpfile("resultmux_workload.vcd");
        $dumpvars(0, tb_resultmux_power);

        // =========================================================
        // INITIAL STATE
        // =========================================================
        Result    = 32'd0;
        RData1    = 32'd0;
        Regdata1  = 32'd0;
        pc_4      = 32'd0;
        resultsel = 2'b00;
        resulten  = 1'b0;

        #20;

        // =========================================================
        // ACTIVE PERIOD 1
        // Normal result selection
        // =========================================================
        resulten  = 1'b1;
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

        resultsel = 2'b01;
        RData1 = 32'd210;
        #20;

        RData1 = 32'd220;
        #20;

        // =========================================================
        // DISABLED PERIOD 1
        // 300 ns
        // Inputs change with exact decimal values, but output
        // remains isolated at zero.
        // =========================================================
        resulten = 1'b0;

        #20;
        Result   = 32'd1000;
        RData1   = 32'd2000;
        Regdata1 = 32'd3000;
        pc_4     = 32'd4000;
        resultsel = 2'b10;

        #20;
        Result   = 32'd1111;
        RData1   = 32'd2222;
        Regdata1 = 32'd3333;
        pc_4     = 32'd4444;
        resultsel = 2'b11;

        #20;
        Result   = 32'd1234;
        RData1   = 32'd2345;
        Regdata1 = 32'd3456;
        pc_4     = 32'd4567;
        resultsel = 2'b00;

        #20;
        Result   = 32'd5000;
        RData1   = 32'd6000;
        Regdata1 = 32'd7000;
        pc_4     = 32'd8000;
        resultsel = 2'b01;

        #20;
        Result   = 32'd1357;
        RData1   = 32'd2468;
        Regdata1 = 32'd3579;
        pc_4     = 32'd4680;
        resultsel = 2'b10;

        #20;
        Result   = 32'd9000;
        RData1   = 32'd8000;
        Regdata1 = 32'd7000;
        pc_4     = 32'd6000;
        resultsel = 2'b11;

        #20;
        Result   = 32'd1010;
        RData1   = 32'd2020;
        Regdata1 = 32'd3030;
        pc_4     = 32'd4040;
        resultsel = 2'b00;

        #20;
        Result   = 32'd111;
        RData1   = 32'd222;
        Regdata1 = 32'd333;
        pc_4     = 32'd444;
        resultsel = 2'b01;

        #20;
        Result   = 32'd4321;
        RData1   = 32'd5432;
        Regdata1 = 32'd6543;
        pc_4     = 32'd7654;
        resultsel = 2'b10;

        #20;
        Result   = 32'd7777;
        RData1   = 32'd8888;
        Regdata1 = 32'd9999;
        pc_4     = 32'd1111;
        resultsel = 2'b11;

        #20;
        Result   = 32'd2468;
        RData1   = 32'd1357;
        Regdata1 = 32'd9876;
        pc_4     = 32'd5432;
        resultsel = 2'b00;

        #20;
        Result   = 32'd3141;
        RData1   = 32'd2718;
        Regdata1 = 32'd1618;
        pc_4     = 32'd1414;
        resultsel = 2'b01;

        #20;
        Result   = 32'd4096;
        RData1   = 32'd8192;
        Regdata1 = 32'd16384;
        pc_4     = 32'd32768;
        resultsel = 2'b10;

        #20;
        Result   = 32'd5555;
        RData1   = 32'd6666;
        Regdata1 = 32'd7777;
        pc_4     = 32'd8888;
        resultsel = 2'b11;

        // =========================================================
        // ACTIVE PERIOD 2
        // =========================================================
        resulten = 1'b1;

        resultsel = 2'b00;
        Result = 32'd10000;
        #20;

        Result = 32'd11000;
        #20;

        resultsel = 2'b01;
        RData1 = 32'd12000;
        #20;

        resultsel = 2'b10;
        Regdata1 = 32'd13000;
        #20;

        resultsel = 2'b11;
        pc_4 = 32'd14000;
        #20;

        // =========================================================
        // DISABLED PERIOD 2
        // 500 ns, long inactive interval
        // =========================================================
        resulten = 1'b0;

        #20;
        Result = 32'd15000; RData1 = 32'd16000; Regdata1 = 32'd17000; pc_4 = 32'd18000; resultsel = 2'b00;
        #20;
        Result = 32'd19000; RData1 = 32'd20000; Regdata1 = 32'd21000; pc_4 = 32'd22000; resultsel = 2'b01;
        #20;
        Result = 32'd23000; RData1 = 32'd24000; Regdata1 = 32'd25000; pc_4 = 32'd26000; resultsel = 2'b10;
        #20;
        Result = 32'd27000; RData1 = 32'd28000; Regdata1 = 32'd29000; pc_4 = 32'd30000; resultsel = 2'b11;
        #20;
        Result = 32'd31000; RData1 = 32'd32000; Regdata1 = 32'd33000; pc_4 = 32'd34000; resultsel = 2'b00;
        #20;
        Result = 32'd35000; RData1 = 32'd36000; Regdata1 = 32'd37000; pc_4 = 32'd38000; resultsel = 2'b01;
        #20;
        Result = 32'd39000; RData1 = 32'd40000; Regdata1 = 32'd41000; pc_4 = 32'd42000; resultsel = 2'b10;
        #20;
        Result = 32'd43000; RData1 = 32'd44000; Regdata1 = 32'd45000; pc_4 = 32'd46000; resultsel = 2'b11;
        #20;
        Result = 32'd47000; RData1 = 32'd48000; Regdata1 = 32'd49000; pc_4 = 32'd50000; resultsel = 2'b00;
        #20;
        Result = 32'd51000; RData1 = 32'd52000; Regdata1 = 32'd53000; pc_4 = 32'd54000; resultsel = 2'b01;
        #20;
        Result = 32'd55000; RData1 = 32'd56000; Regdata1 = 32'd57000; pc_4 = 32'd58000; resultsel = 2'b10;
        #20;
        Result = 32'd59000; RData1 = 32'd60000; Regdata1 = 32'd61000; pc_4 = 32'd62000; resultsel = 2'b11;
        #20;
        Result = 32'd63000; RData1 = 32'd64000; Regdata1 = 32'd65000; pc_4 = 32'd66000; resultsel = 2'b00;
        #20;
        Result = 32'd67000; RData1 = 32'd68000; Regdata1 = 32'd69000; pc_4 = 32'd70000; resultsel = 2'b01;
        #20;
        Result = 32'd71000; RData1 = 32'd72000; Regdata1 = 32'd73000; pc_4 = 32'd74000; resultsel = 2'b10;
        #20;
        Result = 32'd75000; RData1 = 32'd76000; Regdata1 = 32'd77000; pc_4 = 32'd78000; resultsel = 2'b11;
        #20;
        Result = 32'd79000; RData1 = 32'd80000; Regdata1 = 32'd81000; pc_4 = 32'd82000; resultsel = 2'b00;
        #20;
        Result = 32'd83000; RData1 = 32'd84000; Regdata1 = 32'd85000; pc_4 = 32'd86000; resultsel = 2'b01;
        #20;
        Result = 32'd87000; RData1 = 32'd88000; Regdata1 = 32'd89000; pc_4 = 32'd90000; resultsel = 2'b10;
        #20;
        Result = 32'd91000; RData1 = 32'd92000; Regdata1 = 32'd93000; pc_4 = 32'd94000; resultsel = 2'b11;

        // =========================================================
        // FINAL ACTIVE PERIOD
        // =========================================================
        resulten = 1'b1;
        Result = 32'd1111;
        RData1 = 32'd2222;
        Regdata1 = 32'd3333;
        pc_4 = 32'd4444;

        resultsel = 2'b00; #20;
        resultsel = 2'b01; #20;
        resultsel = 2'b10; #20;
        resultsel = 2'b11; #20;

        #50;
        $finish;
    end

endmodule
