// Baseline result mux: no resulten/isolation gate.
module resultmux_baseline(
    input  [31:0] Result,
    input  [31:0] RData1,
    input  [31:0] Regdata1,
    input  [31:0] pc_4,
    input  [1:0]  resultsel,
    output reg [31:0] out1
);
    always @(*) begin
        case (resultsel)
            2'b00:   out1 = Result;
            2'b01:   out1 = RData1;
            2'b10:   out1 = Regdata1;
            2'b11:   out1 = pc_4;
            default: out1 = 32'b0;
        endcase
    end
endmodule
