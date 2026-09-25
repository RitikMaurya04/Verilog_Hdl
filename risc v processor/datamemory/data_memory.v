module data_memory (
    input        clk,
    input [31:0] waddr,
    input [31:0] raddr,
    input [31:0] wdata,
    input        memwrite,
    input        memread,
    output wire [31:0] rdata
);

    // 256 words × 32 bits = 8,192 bits = 1 KB
    reg [31:0] data [0:255];

    // Synchronous write
    always @(posedge clk) begin
        if (memwrite)
            data[waddr[9:2]] <= wdata;
    end

    // Asynchronous read
    assign rdata = memread ? data[raddr[9:2]] : 32'b0;

endmodule
