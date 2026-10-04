// Baseline PC control: no immediate/register input isolation.

module pc_control_baseline (
    input  [31:0] pc,
    input  [31:0] imm,
    input  [31:0] rdata1,

    input branch,
    input branch_taken,
    input jump,
    input jalr,
    input link,

    output reg [31:0] next_pc,
    output reg [31:0] pc_plus4_out
);

    wire [31:0] pc_plus4;
    assign pc_plus4 = pc + 32'd4;

    always @(*) begin
        next_pc = pc_plus4;
        pc_plus4_out = 32'b0;

        if (link)
            pc_plus4_out = pc_plus4;

        if (branch && branch_taken)
            next_pc = pc + imm;
        else if (jump)
            next_pc = pc + imm;
        else if (jalr)
            next_pc = rdata1 + imm;
    end

endmodule
