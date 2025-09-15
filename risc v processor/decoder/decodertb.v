// Testbench for main_decoder
module decoder_tb();

  // Inputs
  reg [4:0] opcode; 
  reg       zero;    // <-- declared but not used (safe to keep for now)

  // Outputs
  wire [2:0] aluop;
  wire       regwrite, memwrite, memread;
  wire       alumuxen1, alumuxen2;
  wire       alumuxsel1, alumuxsel2, resultsel, branch, jump;
  wire [1:0] d_dmuxsel, selr;

  // DUT instantiation
  main_decoder uut (
    .opcode(opcode),
    .aluop(aluop),
    .regwrite(regwrite),
    .memwrite(memwrite),
    .memread(memread),
    .alumuxen1(alumuxen1),
    .alumuxen2(alumuxen2),
    .alumuxsel1(alumuxsel1),
    .alumuxsel2(alumuxsel2),
    .d_dmuxsel(d_dmuxsel),
    .resultsel(resultsel),
    .selr(selr),
    .branch(branch),
    .jump(jump)
  );

  // Stimulus
  initial begin
    opcode = 5'b01101; #10;  // R4 TYPE CONTROL
    opcode = 5'b00011; #10;  // R3 TYPE Instruction
    opcode = 5'b00001; #10;  // R2 TYPE Instructions
    opcode = 5'b00101; #10;  // R2 MOV TYPE Instruction
    opcode = 5'b10111; #10;  // Load Word
    opcode = 5'b10001; #10;  // Store Word
    opcode = 5'b01010; #10;  // Branch
    opcode = 5'b11101; #10;  // I-type
    opcode = 5'b01111; #10;  // JALR-type
    opcode = 5'b11110; #10;  // JAL-type
    $finish;
  end

  // Monitor
  initial begin
    $monitor("time=%0t | opcode=%b | aluop=%b | regwrite=%b | memwrite=%b | memread=%b | alumuxen1=%b | alumuxen2=%b | alumuxsel1=%b | alumuxsel2=%b | d_dmuxsel=%b | resultsel=%b | selr=%b | branch=%b | jump=%b",
              $time, opcode, aluop, regwrite, memwrite, memread, alumuxen1, alumuxen2, alumuxsel1, alumuxsel2, d_dmuxsel, resultsel, selr, branch, jump);
  end

endmodule
