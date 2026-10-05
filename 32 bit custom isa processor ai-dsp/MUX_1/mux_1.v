// Code your design here
module mux_1(
  input  [31:0] SrcC,   // Input 0
  input  [31:0] IMM,   // Input 1
    input   alumuxsel1,// Select signal
  input alumuxen1,
    output reg [31:0] out    // Output
);
  always @(*)
    begin
    if(alumuxen1==1)
      out = (alumuxsel1 == 1'b0) ? SrcC : IMM;
    else
      out = 32'd0;
    end
endmodule