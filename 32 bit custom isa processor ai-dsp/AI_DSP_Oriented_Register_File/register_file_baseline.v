// Baseline register file.
// Three asynchronous read ports are always active.
// regwrite1/regwrite2 remain as functional write enables.

module register_file_baseline (
    input clk,
    input rst,

    input regwrite1,
    input regwrite2,

    input [4:0] raddr1,
    input [4:0] raddr2,
    input [4:0] raddr3,

    input [4:0] waddr1,
    input [4:0] waddr2,

    input [31:0] wdata1,
    input [31:0] wdata2,

    output wire [31:0] rdata1,
    output wire [31:0] rdata2,
    output wire [31:0] rdata3
);

    reg [31:0] regis [0:31];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regis[i] <= 32'd0;
        end
        else begin
            if (regwrite1 && (waddr1 != 5'd0))
                regis[waddr1] <= wdata1;

            if (regwrite2 &&
                (waddr2 != 5'd0) &&
                !(regwrite1 && (waddr1 == waddr2)))
                regis[waddr2] <= wdata2;
        end
    end

    assign rdata1 = (raddr1 == 5'd0) ? 32'd0 : regis[raddr1];
    assign rdata2 = (raddr2 == 5'd0) ? 32'd0 : regis[raddr2];
    assign rdata3 = (raddr3 == 5'd0) ? 32'd0 : regis[raddr3];

endmodule
