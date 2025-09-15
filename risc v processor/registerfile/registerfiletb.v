// Register file Code your testbench here
// or browse Examples
module testbench ;
  reg clk; reg rst;
  reg regwrite; reg[4:0]raddr1;
  reg [4:0]raddr2; reg [4:0]waddr1; reg [4:0]waddr2; reg [31:0] wdata1;      reg [31:0] wdata2;  wire [31:0]rdata1; wire [31:0]rdata2;
  
  
  register_file uut(.clk(clk), .rst(rst),.regwrite(regwrite),.raddr1(raddr1),
             .raddr2(raddr2), .waddr1(waddr1), .waddr2(waddr2), .wdata1( wdata1),.wdata2(wdata2), .rdata1(rdata1), .rdata2(rdata2));
  
  initial clk =0;
  always #5 clk = ~clk;
  
  initial
    begin
      // $monitor("%b\t"rst,regwrite,waddr1,waddr2,wdata2,wdata1,raddr1,raddr2);
     #2 rst=1; regwrite = 0;
      #25 rst = 0; regwrite =1; waddr1 = 5'd4; waddr2 = 5'd2; wdata1 = 32'd5; wdata2 = 32'd4;
      #10 regwrite = 0;
      #10 raddr1 = 5'd4; raddr2 = 5'd2;
      #10 $display("first address = reg[%d] ,Second address = reg[%d] ,Data at reg 4 = %d , Data at reg 2 = %d",raddr1,raddr2,rdata1,rdata2);
      
      #10 raddr1 = 5'd6; raddr2 = 5'd8;
      #10 $display("first address = reg[%d] ,Second address = reg[%d] ,Data at reg 4 = %d , Data at reg 2 = %d",raddr1,raddr2,rdata1,rdata2);
    
      #10 $finish;
      
    end

endmodule 