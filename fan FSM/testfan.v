`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2025 12:24:42 PM
// Design Name: 
// Module Name: testfan
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testfan();
reg clk;
reg elec;
reg [2:0]mod;
wire [2:0]speed;

fan uut(.clk(clk),.elec(elec),.mod(mod),.speed(speed));

initial clk = 0;
always #5 clk = ~clk;

initial begin 
$monitor("mode = %d \t speed = %d",mod,speed); //will monitor all changes
#5 elec = 1; mod =1 ; //when elec is given and rotated fan regulator to 1 then should go to speed 1
#10 elec = 0; mod =1 ;//when elec is not given and rotated fan regulator to 1 then nothing happen
#15 elec = 1; mod = 2;//when elec is given and rotated fan regulator to 2 then should go to speed 2
#20 elec = 0; mod = 2;//when elec is given and rotated fan regulator to 2 then nothing happen
#25 elec = 1; mod = 3;//when elec is given and rotated fan regulator to 3 then should go to speed 3
#30 elec = 0; mod = 3;//when elec is given and rotated fan regulator to 3 then nothing happen
#40 $stop;
$finish;
end
endmodule
