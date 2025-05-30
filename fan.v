`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2025 11:24:27 AM
// Design Name: 
// Module Name: fan
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


module fan( input clk ,input elec,input [2:0]mod,output reg[2:0]speed);
parameter SP1 = 1 , SP2 = 2 , SP3 = 3;
reg elect;

parameter mode1 = 1 , mode2 = 2 , mode3 = 3;

//reg [1:0]state;
always @(posedge clk or negedge clk)
begin
if(elec) //checks whether electricity is provided or not
begin
if( mod == mode1)
begin
speed <= SP1;    // for speed in mode 1
end
if( mod == mode2)
begin
speed <= SP2;    // for speed in mode 2
end
if(mod == mode3)
begin
speed <= SP3;     // for speed in mode 3
end
end
else $display("No electricity"); // if no electricity is there display it
end
endmodule
