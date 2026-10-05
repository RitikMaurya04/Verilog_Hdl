// Code your design here
module resultmux(
  input  [31:0] Result,   // Input 0
  input  [31:0] RData1, 
  input [31:0] Regdata1,
  input [31:0] pc_4,
  input   [1:0] resultsel,// Select signal
  input resulten, //enable signal
  output reg [31:0] out1    // Output
);
  
  always @(*)
    begin
    out1 = 32'd0;
  if(resulten)
    begin
    case(resultsel)
      2'b00: out1 = Result;
      2'b01: out1 = RData1;
      2'b10: out1 = Regdata1;
      2'b11: out1 = pc_4;
      default : out1 = 32'd0;
    endcase
    end
    end
  
  
   
endmodule