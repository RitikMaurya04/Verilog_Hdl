// ============================================================
// POWER-AWARE ALU
//
// ALUEnable = 1 : ALU operates normally
// ALUEnable = 0 : ALU datapath and control inputs are isolated
//
// Operand isolation:
//     A, B, C
//
// Control isolation:
//     alucontrol, mode
//
// mode encoding:
//     00 -> R4 type: three-input ALU operations
//     01 -> R3 type: two-input ALU operations + AI operations
//     10 -> R2 type: single-input ALU operations + AI operation
//     11 -> I type / address operations: A op C
// ============================================================

module alu_ai (

    input  [31:0] A,
    input  [31:0] B,
    input  [31:0] C,

    // Global ALU enable
    input         ALUEnable,

    // Operand-level enables
    input         alu_enA,
    input         alu_enB,
    input         alu_enC,

    // ALU operation selection
    input  [4:0]  alucontrol,

    // ALU operating mode
    input  [1:0]  mode,

    output reg [31:0] Result,
    output            zero
);


    // =========================================================
    // OPERAND ISOLATION
    //
    // If ALUEnable = 0, all ALU operands are forced to zero.
    // If ALUEnable = 1, individual operand enables determine
    // which operands are allowed into the ALU.
    // =========================================================

    wire [31:0] SrcA;
    wire [31:0] SrcB;
    wire [31:0] SrcC;

    assign SrcA = (ALUEnable && alu_enA) ? A : 32'b0;
    assign SrcB = (ALUEnable && alu_enB) ? B : 32'b0;
    assign SrcC = (ALUEnable && alu_enC) ? C : 32'b0;


    // =========================================================
    // CONTROL SIGNAL ISOLATION
    //
    // When ALUEnable = 0:
    //   alucontrol is forced to a constant value
    //   mode is forced to a constant value
    //
    // This prevents unnecessary switching in ALU control
    // selection logic.
    // =========================================================

    wire [4:0] alucontrol_iso;
    wire [1:0] mode_iso;

    assign alucontrol_iso = ALUEnable ? alucontrol : 5'b11111;
    assign mode_iso       = ALUEnable ? mode       : 2'b00;


    // =========================================================
    // ZERO FLAG
    //
    // zero = 1 when the ALU result is exactly zero.
    // =========================================================

    assign zero = (Result == 32'b0);


    // =========================================================
    // ALU COMBINATIONAL LOGIC
    // =========================================================

    always @(*) begin

        // Safe default output
        Result = 32'b0;


        // =====================================================
        // ALU DISABLED
        //
        // When ALUEnable = 0, the ALU does not perform any
        // operation and the result is forced to zero.
        // =====================================================

        if (!ALUEnable) begin

            Result = 32'b0;

        end

        else begin

            case (mode_iso)


                //================================================
                // R4 TYPE
                //
                // Three ALU operands are available:
                //     SrcA, SrcB, SrcC
                //================================================

                2'b00: begin

                    case (alucontrol_iso)


                        // ----------------------------------------
                        // ADD
                        // Result = A + B + C
                        // ----------------------------------------

                        5'b00000:
                            Result = SrcA + SrcB + SrcC;


                        // ----------------------------------------
                        // SUB
                        // Result = A - B - C
                        // ----------------------------------------

                        5'b00001:
                            Result = SrcA - SrcB - SrcC;


                        // ----------------------------------------
                        // OR
                        // Three-input bitwise OR
                        // Result = A | B | C
                        // ----------------------------------------

                        5'b00010:
                            Result = SrcA | SrcB | SrcC;


                        // ----------------------------------------
                        // AND
                        // Three-input bitwise AND
                        // Result = A & B & C
                        // ----------------------------------------

                        5'b00011:
                            Result = SrcA & SrcB & SrcC;


                        // ----------------------------------------
                        // NAND
                        // Inverted three-input AND
                        // Result = ~(A & B & C)
                        // ----------------------------------------

                        5'b00100:
                            Result = ~(SrcA & SrcB & SrcC);


                        // ----------------------------------------
                        // NOR
                        // Inverted three-input OR
                        // Result = ~(A | B | C)
                        // ----------------------------------------

                        5'b00101:
                            Result = ~(SrcA | SrcB | SrcC);


                        // ----------------------------------------
                        // XOR
                        // Three-input bitwise XOR
                        // Result = A ^ B ^ C
                        // ----------------------------------------

                        5'b00110:
                            Result = SrcA ^ SrcB ^ SrcC;


                        // ----------------------------------------
                        // XNOR
                        // Inverted three-input XOR
                        // Result = ~(A ^ B ^ C)
                        // ----------------------------------------

                        5'b00111:
                            Result = ~(SrcA ^ SrcB ^ SrcC);


                        // ----------------------------------------
                        // XOR-AND
                        // First calculate A & B, then XOR with C
                        //
                        // Result = (A & B) ^ C
                        // ----------------------------------------

                        5'b10110:
                            Result = (SrcA & SrcB) ^ SrcC;


                        // ----------------------------------------
                        // NOT-AND-XOR
                        // Invert the result of (A & B) ^ C
                        //
                        // Result = ~((A & B) ^ C)
                        // ----------------------------------------

                        5'b10101:
                            Result = ~((SrcA & SrcB) ^ SrcC);


                        // ----------------------------------------
                        // NOT-OR-AND
                        // First OR A and B, invert the result,
                        // then AND with C
                        //
                        // Result = ~(A | B) & C
                        // ----------------------------------------

                        5'b11001:
                            Result = ~(SrcA | SrcB) & SrcC;


                        // ----------------------------------------
                        // AND-NOT2
                        // A AND NOT B AND NOT C
                        //
                        // Result = A & ~B & ~C
                        // ----------------------------------------

                        5'b11010:
                            Result = SrcA & ~SrcB & ~SrcC;


                        // ----------------------------------------
                        // R4 INC
                        //
                        // Current implementation:
                        // Result = A + B + C + 3
                        //
                        // Note:
                        // This is the actual operation implemented
                        // by your RTL.
                        // ----------------------------------------

                        5'b01001:
                            Result = SrcA + SrcB + SrcC + 32'd3;


                        // ----------------------------------------
                        // R4 DEC
                        //
                        // Current implementation:
                        // Result = A + B + C - 3
                        //
                        // Note:
                        // This is the actual operation implemented
                        // by your RTL.
                        // ----------------------------------------

                        5'b01010:
                            Result = SrcA + SrcB + SrcC - 32'd3;


                        // ----------------------------------------
                        // MAX
                        //
                        // Returns the largest signed value among
                        // A, B and C.
                        // ----------------------------------------

                        5'b01100:
                            Result =
                                ($signed(SrcA) > $signed(SrcB)) ?
                                (($signed(SrcA) > $signed(SrcC)) ?
                                 SrcA : SrcC) :
                                (($signed(SrcB) > $signed(SrcC)) ?
                                 SrcB : SrcC);


                        // ----------------------------------------
                        // MIN
                        //
                        // Returns the smallest signed value among
                        // A, B and C.
                        // ----------------------------------------

                        5'b01101:
                            Result =
                                ($signed(SrcA) < $signed(SrcB)) ?
                                (($signed(SrcA) < $signed(SrcC)) ?
                                 SrcA : SrcC) :
                                (($signed(SrcB) < $signed(SrcC)) ?
                                 SrcB : SrcC);


                        // ----------------------------------------
                        // MAC
                        // Multiply-Accumulate
                        //
                        // Result = (A * B) + C
                        // ----------------------------------------

                        5'b01110:
                            Result = (SrcA * SrcB) + SrcC;


                        // ----------------------------------------
                        // MSC
                        // Multiply-Subtract
                        //
                        // Result = (A * B) - C
                        // ----------------------------------------

                        5'b01111:
                            Result = (SrcA * SrcB) - SrcC;


                        // ----------------------------------------
                        // Invalid / unused control
                        // Result = 0
                        // ----------------------------------------

                        default:
                            Result = 32'b0;

                    endcase

                end


                //================================================
                // R3 TYPE + AI EXTENSIONS
                //
                // Two ALU operands are used:
                //     SrcA and SrcB
                //================================================

                2'b01: begin

                    case (alucontrol_iso)


                        // ----------------------------------------
                        // ADD
                        // Result = A + B
                        // ----------------------------------------

                        5'b00000:
                            Result = SrcA + SrcB;


                        // ----------------------------------------
                        // SUB
                        // Result = A - B
                        // ----------------------------------------

                        5'b00001:
                            Result = SrcA - SrcB;


                        // ----------------------------------------
                        // OR
                        // Result = A | B
                        // ----------------------------------------

                        5'b00010:
                            Result = SrcA | SrcB;


                        // ----------------------------------------
                        // AND
                        // Result = A & B
                        // ----------------------------------------

                        5'b00011:
                            Result = SrcA & SrcB;


                        // ----------------------------------------
                        // NAND
                        // Result = ~(A & B)
                        // ----------------------------------------

                        5'b00100:
                            Result = ~(SrcA & SrcB);


                        // ----------------------------------------
                        // NOR
                        // Result = ~(A | B)
                        // ----------------------------------------

                        5'b00101:
                            Result = ~(SrcA | SrcB);


                        // ----------------------------------------
                        // XOR
                        // Result = A ^ B
                        // ----------------------------------------

                        5'b00110:
                            Result = SrcA ^ SrcB;


                        // ----------------------------------------
                        // XNOR
                        // Result = ~(A ^ B)
                        // ----------------------------------------

                        5'b00111:
                            Result = ~(SrcA ^ SrcB);


                        // ----------------------------------------
                        // AND-NOT
                        // Result = A & ~B
                        // ----------------------------------------

                        5'b11100:
                            Result = SrcA & ~SrcB;


                        // ----------------------------------------
                        // OR-NOT
                        // Result = A | ~B
                        // ----------------------------------------

                        5'b11011:
                            Result = SrcA | ~SrcB;


                        // ----------------------------------------
                        // INC
                        // Increment A by 1
                        // Result = A + 1
                        // ----------------------------------------

                        5'b01001:
                            Result = SrcA + 32'd1;


                        // ----------------------------------------
                        // DEC
                        // Decrement A by 1
                        // Result = A - 1
                        // ----------------------------------------

                        5'b01010:
                            Result = SrcA - 32'd1;


                        // ----------------------------------------
                        // SLL
                        // Logical left shift
                        //
                        // Result = A << B[4:0]
                        // ----------------------------------------

                        5'b10000:
                            Result = SrcA << SrcB[4:0];


                        // ----------------------------------------
                        // SLT
                        // Set Less Than (signed)
                        //
                        // Result = 1 when A < B
                        // Result = 0 otherwise
                        // ----------------------------------------

                        5'b10001:
                            Result =
                                ($signed(SrcA) < $signed(SrcB)) ?
                                32'd1 : 32'd0;


                        // ----------------------------------------
                        // SRL
                        // Logical right shift
                        //
                        // Result = A >> B[4:0]
                        // ----------------------------------------

                        5'b10010:
                            Result = SrcA >> SrcB[4:0];


                        // ----------------------------------------
                        // SRA
                        // Arithmetic right shift
                        //
                        // Sign bit is preserved.
                        // ----------------------------------------

                        5'b10011:
                            Result = $signed(SrcA) >>> SrcB[4:0];


                        // ----------------------------------------
                        // SGT
                        // Set Greater Than (signed)
                        //
                        // Result = 1 when A > B
                        // Result = 0 otherwise
                        // ----------------------------------------

                        5'b10100:
                            Result =
                                ($signed(SrcA) > $signed(SrcB)) ?
                                32'd1 : 32'd0;


                        // ----------------------------------------
                        // MAX
                        //
                        // Returns the larger signed value of
                        // A and B.
                        // ----------------------------------------

                        5'b01100:
                            Result =
                                ($signed(SrcA) > $signed(SrcB)) ?
                                SrcA : SrcB;


                        // ----------------------------------------
                        // MIN
                        //
                        // Returns the smaller signed value of
                        // A and B.
                        // ----------------------------------------

                        5'b01101:
                            Result =
                                ($signed(SrcA) < $signed(SrcB)) ?
                                SrcA : SrcB;


                        // ----------------------------------------
                        // MUL
                        //
                        // Signed/unsigned behavior follows the
                        // operand declarations used by this RTL.
                        //
                        // Result = A * B
                        // ----------------------------------------

                        5'b11111:
                            Result = SrcA * SrcB;


                        //================================================
                        // AI OPERATION: VADD8
                        //
                        // Performs four independent 8-bit additions:
                        //
                        // lane 0 : A[7:0]   + B[7:0]
                        // lane 1 : A[15:8]  + B[15:8]
                        // lane 2 : A[23:16] + B[23:16]
                        // lane 3 : A[31:24] + B[31:24]
                        //
                        // This is SIMD-style INT8 addition.
                        //================================================

                        5'b10111: begin

                            Result[7:0] =
                                SrcA[7:0] + SrcB[7:0];

                            Result[15:8] =
                                SrcA[15:8] + SrcB[15:8];

                            Result[23:16] =
                                SrcA[23:16] + SrcB[23:16];

                            Result[31:24] =
                                SrcA[31:24] + SrcB[31:24];

                        end


                        //================================================
                        // AI OPERATION: VMAX8
                        //
                        // Performs four independent signed INT8
                        // maximum operations.
                        //
                        // Each 8-bit lane selects the larger value.
                        //================================================

                        5'b11000: begin

                            Result[7:0] =
                                ($signed(SrcA[7:0]) >
                                 $signed(SrcB[7:0])) ?
                                SrcA[7:0] : SrcB[7:0];

                            Result[15:8] =
                                ($signed(SrcA[15:8]) >
                                 $signed(SrcB[15:8])) ?
                                SrcA[15:8] : SrcB[15:8];

                            Result[23:16] =
                                ($signed(SrcA[23:16]) >
                                 $signed(SrcB[23:16])) ?
                                SrcA[23:16] : SrcB[23:16];

                            Result[31:24] =
                                ($signed(SrcA[31:24]) >
                                 $signed(SrcB[31:24])) ?
                                SrcA[31:24] : SrcB[31:24];

                        end


                        //================================================
                        // AI OPERATION: SDOTP4
                        //
                        // Signed 4-lane INT8 dot product:
                        //
                        // A0*B0 + A1*B1 + A2*B2 + A3*B3
                        //
                        // Each operand is treated as a signed 8-bit
                        // value before multiplication.
                        //================================================

                        5'b11101: begin

                            Result =
                                ($signed(SrcA[7:0])   *
                                 $signed(SrcB[7:0])) +

                                ($signed(SrcA[15:8])  *
                                 $signed(SrcB[15:8])) +

                                ($signed(SrcA[23:16]) *
                                 $signed(SrcB[23:16])) +

                                ($signed(SrcA[31:24]) *
                                 $signed(SrcB[31:24]));

                        end


                        // ----------------------------------------
                        // Invalid / unused control
                        // Result = 0
                        // ----------------------------------------

                        default:
                            Result = 32'b0;

                    endcase

                end


                //================================================
                // R2 TYPE + AI EXTENSION
                //
                // Primarily uses SrcA.
                //================================================

                2'b10: begin

                    case (alucontrol_iso)


                        // ----------------------------------------
                        // NEG
                        //
                        // Two's complement negation:
                        // Result = -A
                        // ----------------------------------------

                        5'b00000:
                            Result = -$signed(SrcA);


                        // ----------------------------------------
                        // ABS
                        //
                        // Absolute value of signed A.
                        //
                        // If A < 0 -> -A
                        // Otherwise -> A
                        // ----------------------------------------

                        5'b00001:
                            Result =
                                ($signed(SrcA) < 0) ?
                                -$signed(SrcA) : SrcA;


                        // ----------------------------------------
                        // NOT
                        //
                        // Bitwise inversion:
                        // Result = ~A
                        // ----------------------------------------

                        5'b01000:
                            Result = ~SrcA;


                        // ----------------------------------------
                        // INC
                        //
                        // Result = A + 1
                        // ----------------------------------------

                        5'b01001:
                            Result = SrcA + 32'd1;


                        // ----------------------------------------
                        // DEC
                        //
                        // Result = A - 1
                        // ----------------------------------------

                        5'b01010:
                            Result = SrcA - 32'd1;


                        //================================================
                        // AI OPERATION: VRELU8
                        //
                        // ReLU applied independently to four
                        // signed INT8 lanes.
                        //
                        // If lane is negative -> 0
                        // Otherwise preserve lane value.
                        //================================================

                        5'b10110: begin

                            Result[7:0] =
                                SrcA[7] ? 8'd0 : SrcA[7:0];

                            Result[15:8] =
                                SrcA[15] ? 8'd0 : SrcA[15:8];

                            Result[23:16] =
                                SrcA[23] ? 8'd0 : SrcA[23:16];

                            Result[31:24] =
                                SrcA[31] ? 8'd0 : SrcA[31:24];

                        end


                        // ----------------------------------------
                        // Invalid / unused control
                        // ----------------------------------------

                        default:
                            Result = 32'b0;

                    endcase

                end


                //================================================
                // I TYPE
                //
                // Uses SrcA and immediate/third operand SrcC.
                //
                // Typical examples:
                //     ADDI, SUBI, ORI, ANDI, XORI
                //     SLLI, SRLI, SRAI
                //================================================

                2'b11: begin

                    case (alucontrol_iso)


                        // ----------------------------------------
                        // ADDI
                        //
                        // Result = A + Immediate
                        // ----------------------------------------

                        5'b00000:
                            Result = SrcA + SrcC;


                        // ----------------------------------------
                        // SUBI
                        //
                        // Result = A - Immediate
                        // ----------------------------------------

                        5'b00001:
                            Result = SrcA - SrcC;


                        // ----------------------------------------
                        // ORI
                        //
                        // Result = A | Immediate
                        // ----------------------------------------

                        5'b00010:
                            Result = SrcA | SrcC;


                        // ----------------------------------------
                        // ANDI
                        //
                        // Result = A & Immediate
                        // ----------------------------------------

                        5'b00011:
                            Result = SrcA & SrcC;


                        // ----------------------------------------
                        // XORI
                        //
                        // Result = A ^ Immediate
                        // ----------------------------------------

                        5'b00110:
                            Result = SrcA ^ SrcC;


                        // ----------------------------------------
                        // SLLI
                        //
                        // Logical left shift by immediate amount.
                        // ----------------------------------------

                        5'b10000:
                            Result = SrcA << SrcC[4:0];


                        // ----------------------------------------
                        // SRLI
                        //
                        // Logical right shift by immediate amount.
                        // ----------------------------------------

                        5'b10010:
                            Result = SrcA >> SrcC[4:0];


                        // ----------------------------------------
                        // SRAI
                        //
                        // Arithmetic right shift by immediate amount.
                        // Sign bit is preserved.
                        // ----------------------------------------

                        5'b10011:
                            Result = $signed(SrcA) >>> SrcC[4:0];
                        
                       


                        // ----------------------------------------
                        // Invalid / unused control
                        // ----------------------------------------

                        default:
                            Result = 32'b0;

                    endcase

                end


                //================================================
                // INVALID MODE
                //================================================

                default:
                    Result = 32'b0;

            endcase

        end

    end

endmodule
