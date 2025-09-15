module alutb();
  // Inputs
  reg signed [31:0] A, B, C;
  reg [4:0] alucontrol;
  reg rst, branch;
  reg [1:0] mode;

  // Outputs
  wire signed [31:0] Result;
  wire zero;

  // DUT instantiation
  alu uut (
    .SrcA(A),
    .SrcB(B),
    .SrcC(C),
    .alucontrol(alucontrol),
    .rst(rst),
    .branch(branch),
    .mode(mode),
    .Result(Result),
    .zero(zero)   // use DUT’s zero output
  );

  initial begin
    // Reset test
    rst = 1; mode = 2'b00; branch = 0;
    A = 32'd0; B = 32'd0; C = 32'd0;
    alucontrol = 5'd0;
    #10;

    rst = 0; // Release reset

    // ---------------- R4 TYPE ----------------
    mode = 2'b00;
    A = -10; B = 32'd20; C = 32'd30;
    alucontrol = 5'b00000; #10; // add
    alucontrol = 5'b00010; #10; // or
    alucontrol = 5'b01100; #10; // max
    alucontrol = 5'b01110; #10; // mac

    // ---------------- R3 TYPE ----------------
    mode = 2'b01;
    A = 32'd15; B = 32'd5;
    alucontrol = 5'b00000; #10; // add
    alucontrol = 5'b00011; #10; // and
    alucontrol = 5'b10001; #10; // slt
    alucontrol = 5'b10000; #10; // sll

    // ---------------- R2 TYPE ----------------
    mode = 2'b10;
    A = 25;
    alucontrol = 5'b00000; #10; // neg
    alucontrol = 5'b00001; #10; // abs
    alucontrol = 5'b01000; #10; // not
    alucontrol = 5'b01001; #10; // inc
     alucontrol = 5'b01010; #10; // inc

    // ---------------- I TYPE ----------------
    mode = 2'b11;
    A = 32'd40; C = 32'd5;
    alucontrol = 5'b00000; #10; // addi
    alucontrol = 5'b00001; #10; // subi
    alucontrol = 5'b10000; #10; // slli
    alucontrol = 5'b10010; #10; // srli

    $finish;
  end

  initial begin
    $monitor("time=%0t | mode=%b | alucontrol=%b | SrcA=%d | SrcB=%d | SrcC=%d | Result=%d | zero=%b",
              $time, mode, alucontrol, A, B, C, Result, zero);
  end

endmodule