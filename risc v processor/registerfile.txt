// Register File Code your design here
module register_file(input clk,input rst,input regwrite,input [4:0]raddr1,input [4:0]raddr2,input [4:0]waddr1,input [4:0]waddr2, input [31:0] wdata1,input [31:0] wdata2, output reg [31:0]rdata1,output reg [31:0]rdata2);
  
  reg [31:0] regis [0:31];
  
  always @(posedge clk or posedge rst)
    begin
      if(rst==1) //will reset the register and all it value to zero
        begin
          regis[0] <= 32'd0;
          for(int i=1;i<32;i++)
            regis[i] <= 32'd0;
          
        end
      if (waddr1 == waddr2 && regwrite) //will check if trying to write in same register will give error
    $display("Warning: Attempt to write to same register from both ports:%d", waddr1);
      
      if(regwrite == 1 && waddr1 != 5'b00000 && waddr2 != 5'b00000 && waddr1 != waddr2) //will not write in register zero and same address register as register zero value will be fixed to zero
        begin
          regis[waddr1] <= wdata1; //first write port operation
          regis[waddr2] <= wdata2; //second write port operation
        end
    
    end
  
  
  always @(*)
    begin
      rdata1 = (raddr1 == 5'b00000) ? 32'd0 : regis[raddr1]; //gives output data at rdata1 port
      rdata2 = (raddr2 == 5'b00000) ? 32'd0 : regis[raddr2]; //gives output data at rdata1 port
    
    end
  
endmodule 
  