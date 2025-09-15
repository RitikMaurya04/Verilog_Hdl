// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module alu_control_tb;

  // Inputs
  reg [2:0] aluop;
  reg [2:0] func3;
  reg [3:0] func7;

  // Outputs
  wire [1:0] mode;
  wire [4:0] control;

  // Instantiate the DUT (Device Under Test)
  alu_control uut (
    .aluop(aluop),
    .func3(func3),
    .func7(func7),
    .mode(mode),
    .control(control)
  );

  // Test procedure
  initial begin
    $display("Time\taluop\tfunc7\tfunc3\tmode\tcontrol");

    // Test Case 1: LW/SW instruction
    aluop = 3'b011; func7 = 4'b0000; func3 = 3'b000;
    #10 $display("%0dns\t%b\t%b\t%b\t%b\t%b", $time, aluop, func7, func3, mode, control);
     aluop = 3'b010; func7 = 4'b0110; func3 = 3'b100;
    #10 $display("%0dns\t%b\t%b\t%b\t%b\t%b", $time, aluop, func7, func3, mode, control);

    // Test Case 2: R4 TYPE add
    aluop = 3'b010; func7 = 4'b0000; func3 = 3'b000;
    #10 $display("%0dns\t%b\t%b\t%b\t%b\t%b", $time, aluop, func7, func3, mode, control);

    // Test Case 3: R3 TYPE sub
    aluop = 3'b100; func7 = 4'b0001; func3 = 3'b000;
    #10 $display("%0dns\t%b\t%b\t%b\t%b\t%b", $time, aluop, func7, func3, mode, control);

    // Test Case 4: R2 TYPE neg
    aluop = 3'b110; func7 = 4'b0000; func3 = 3'b000;
    #10 $display("%0dns\t%b\t%b\t%b\t%b\t%b", $time, aluop, func7, func3, mode, control);

    // Test Case 5: I TYPE addi
    aluop = 3'b111; func7 = 4'b0000; func3 = 3'b000;
    #10 $display("%0dns\t%b\t%b\t%b\t%b\t%b", $time, aluop, func7, func3, mode, control);

    // Test Case 6: Unknown instruction (default case)
    aluop = 3'b001; func7 = 4'b1111; func3 = 3'b111;
    #10 $display("%0dns\t%b\t%b\t%b\t%b\t%b", $time, aluop, func7, func3, mode, control);

    $finish;
  end
endmodule