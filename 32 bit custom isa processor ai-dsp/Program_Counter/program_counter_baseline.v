module program_counter_baseline(
    input clk,
    input rst,
    input [31:0] pcinst,
    output reg [31:0] pcoutinst
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            pcoutinst <= 32'd0;
        else
            pcoutinst <= pcinst;
    end

endmodule
