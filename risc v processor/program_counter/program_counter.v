module program_counter(input clk,input rst_pc,input pcen,input [31:0]pcinst , output reg [31:0]pcoutinst);
  
  always @(posedge clk or negedge rst_pc)
    begin
      if(!rst_pc)
      pcoutinst <= 32'd0;
      else if(pcen)
      pcoutinst <= pcinst;
    end
endmodule