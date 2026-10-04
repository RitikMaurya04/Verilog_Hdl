// Code your design here
module pc_control (
    input  [31:0] pc,
    input  [31:0] imm,
    input  [31:0] rdata1,

    input         branch,
    input         branch_taken,
    input         jump,
    input         jalr,
    input         link,

    output reg [31:0] next_pc,
    output reg [31:0] pc_plus4_out
);

    wire [31:0] pc_plus4;

    assign pc_plus4 = pc + 32'd4;

    wire [31:0] branch_imm_iso;
    wire [31:0] jump_imm_iso;
    wire [31:0] jalr_imm_iso;
    wire [31:0] rdata1_iso;

    assign branch_imm_iso =
        (branch && branch_taken) ? imm : 32'b0;

    assign jump_imm_iso =
        jump ? imm : 32'b0;

    assign jalr_imm_iso =
        jalr ? imm : 32'b0;

    assign rdata1_iso =
        jalr ? rdata1 : 32'b0;

    always @(*) begin

        next_pc = pc_plus4;
        pc_plus4_out = 32'b0;

        if (link)
            pc_plus4_out = pc_plus4;
      

        if (branch && branch_taken)
            next_pc = pc + branch_imm_iso;

        else if (jump)
            next_pc = pc + jump_imm_iso;

        else if (jalr)
            next_pc = rdata1_iso + jalr_imm_iso;

    end

endmodule