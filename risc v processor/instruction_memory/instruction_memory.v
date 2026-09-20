module instruction_memory #(
    parameter width = 32
)(
    input ren,
    input [width-1:0] addr,
    output wire [width-1:0] data
);

    reg [width-1:0] mem [0:127];

    initial begin
        $readmemh("program.hex", mem);
    end

    assign data = ren ? mem[addr[8:2]] : {width{1'b0}};

endmodule