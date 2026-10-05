// Baseline ALU operand MUX: no activity-gating enable.
module mux_1_baseline(
    input  [31:0] SrcC,
    input  [31:0] IMM,
    input         alumuxsel1,
    output reg [31:0] out
);
    always @(*) begin
        out = (alumuxsel1 == 1'b0) ? SrcC : IMM;
    end
endmodule
