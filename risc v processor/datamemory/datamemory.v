// Code your design here
module data_memory(input clk,input rst,input write,input read,input [31:0]addr1,input [31:0]addr2,input [31:0]waddr1,input [31:0]waddr2, input [31:0] wdata1,input [31:0] wdata2, output reg [31:0]rdata1,output reg [31:0]rdata2);
  
  reg [31:0] data [0:511];
  integer i;
  
  always @(posedge clk or posedge rst)
    begin
      if(rst==1) //will reset the register and all it value to zero
        begin
          
          for(i=0;i<512;i=i+1)
            data[i] <= 32'd0;
          end
      else if(write==1)
        begin
         if (waddr1 == waddr2) //will check if trying to write in same register will give error
               $display("Warning: Attempt to write to same register from both ports:%d", waddr1);
         
         else //will not write in register zero and same address register as register zero value will be fixed to zero
         begin
          data[waddr1] <= wdata1; //first write port operation
          data[waddr2] <= wdata2; //second write port operation
        end
        end
    
    end
  
  
  always @(*)
    begin
      if(read==1)
        begin
         rdata1 = data[addr1]; //gives output data at rdata1 port
         rdata2 = data[addr2]; //gives output data at rdata1 port
        end
        else 
          begin
            $display("First Turn on Read...");
            rdata1 = 32'd0;
            rdata2 = 32'd0;
          end
    end
  
endmodule 
  