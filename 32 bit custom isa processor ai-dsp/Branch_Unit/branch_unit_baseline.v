// Baseline branch unit: no operand isolation.
// The normal branch control and branch-type signals remain.

module branch_unit_baseline (
    input         branch,
    input  [31:0] rdata1,
    input  [31:0] rdata2,
    input  [4:0]  branchtype,
    output reg    branch_taken
);

    localparam [4:0] NONE = 5'd0;
    localparam [4:0] BEQ  = 5'd1;
    localparam [4:0] BNEQ = 5'd2;
    localparam [4:0] BGT  = 5'd3;
    localparam [4:0] BLT  = 5'd4;
    localparam [4:0] BGST = 5'd5;
    localparam [4:0] BLST = 5'd6;
    localparam [4:0] BLTZ = 5'd7;
    localparam [4:0] BGTZ = 5'd8;
    localparam [4:0] BGEZ = 5'd9;
    localparam [4:0] BLEZ = 5'd10;
    localparam [4:0] BEQZ = 5'd11;
    localparam [4:0] BNEZ = 5'd12;

    always @(*) begin
        branch_taken = 1'b0;

        if (branch) begin
            case (branchtype)
                BEQ : branch_taken = (rdata1 == rdata2);
                BNEQ: branch_taken = (rdata1 != rdata2);
                BGT : branch_taken = (rdata1 > rdata2);
                BLT : branch_taken = (rdata1 < rdata2);

                BGST: branch_taken =
                    ($signed(rdata1) > $signed(rdata2));

                BLST: branch_taken =
                    ($signed(rdata1) < $signed(rdata2));

                BLTZ: branch_taken = ($signed(rdata1) < 0);
                BGTZ: branch_taken = ($signed(rdata1) > 0);
                BGEZ: branch_taken = ($signed(rdata1) >= 0);
                BLEZ: branch_taken = ($signed(rdata1) <= 0);
                BEQZ: branch_taken = (rdata1 == 32'b0);
                BNEZ: branch_taken = (rdata1 != 32'b0);

                default: branch_taken = 1'b0;
            endcase
        end
    end
endmodule
