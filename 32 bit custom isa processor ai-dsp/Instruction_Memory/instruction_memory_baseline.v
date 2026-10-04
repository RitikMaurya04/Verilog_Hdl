module instruction_memory_baseline #(
    parameter width = 32
)(
    input [width-1:0] addr,
    output wire [width-1:0] data
);

    reg [width-1:0] mem [0:127];

    initial begin
        $readmemh("program.hex", mem);
    end

    assign data = mem[addr[8:2]];

endmodule
