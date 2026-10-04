module data_memory_baseline (
    input        clk,
    input [31:0] addr,
   
    input [31:0] wdata,
    input        memwrite,
    input        memread,
    output wire [31:0] rdata
);

reg [31:0] data [0:32];

always @(posedge clk) begin
    if (memwrite)
        data[addr[6:2]] <= wdata;
end

assign rdata = memread ? data[addr[6:2]] : 32'b0;

endmodule