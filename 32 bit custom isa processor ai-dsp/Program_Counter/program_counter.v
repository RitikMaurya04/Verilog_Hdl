module program_counter(input clk,input rst,input [31:0]pcinst , output reg [31:0]pcoutinst);

wire pcen;
assign pcen = 1'b1;
  
  always @(posedge clk or posedge rst)
    begin
      if(rst)
      pcoutinst <= 32'd0;
      else if(pcen)
      pcoutinst <= pcinst;
    end
endmodule