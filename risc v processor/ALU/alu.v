// Code your design here
module alu_ai (
    input  [31:0] A,
    input  [31:0] B,
    input  [31:0] C,
    input         alu_en,
    input  [4:0]  alucontrol,
    input  [1:0]  mode,

    output reg [31:0] Result,
    output            zero
);

wire [31:0] SrcA;
wire [31:0] SrcB;
wire [31:0] SrcC;

assign SrcA = alu_en ? A : 32'b0;
assign SrcB = alu_en ? B : 32'b0;
assign SrcC = alu_en ? C : 32'b0;

assign zero = (Result == 32'b0);


always @(*) begin

    Result = 32'b0;

    case (mode)

        //========================================
        // R4 TYPE
        //========================================
        2'b00: begin

            case (alucontrol)

                5'b00000: Result = SrcA + SrcB + SrcC;
                5'b00001: Result = SrcA - SrcB - SrcC;

                5'b00010: Result = SrcA | SrcB | SrcC;
                5'b00011: Result = SrcA & SrcB & SrcC;

                5'b00100: Result = ~(SrcA & SrcB & SrcC);
                5'b00101: Result = ~(SrcA | SrcB | SrcC);

                5'b00110: Result = SrcA ^ SrcB ^ SrcC;
                5'b00111: Result = ~(SrcA ^ SrcB ^ SrcC);

                5'b10110: Result = (SrcA & SrcB) ^ SrcC;
                5'b10101: Result = ~((SrcA & SrcB) ^ SrcC);

                5'b11001: Result = ~(SrcA | SrcB) & SrcC;
                5'b11010: Result = SrcA & ~SrcB & ~SrcC;

                5'b01001: Result = SrcA + SrcB + SrcC + 32'd3;
                5'b01010: Result = SrcA + SrcB + SrcC - 32'd3;

                5'b01100:
                    Result = ($signed(SrcA) > $signed(SrcB)) ?
                             (($signed(SrcA) > $signed(SrcC)) ? SrcA : SrcC) :
                             (($signed(SrcB) > $signed(SrcC)) ? SrcB : SrcC);

                5'b01101:
                    Result = ($signed(SrcA) < $signed(SrcB)) ?
                             (($signed(SrcA) < $signed(SrcC)) ? SrcA : SrcC) :
                             (($signed(SrcB) < $signed(SrcC)) ? SrcB : SrcC);

                5'b01110: Result = (SrcA * SrcB) + SrcC;
                5'b01111: Result = (SrcA * SrcB) - SrcC;

                default: Result = 32'b0;

            endcase
        end


        //========================================
        // R3 TYPE + AI EXTENSIONS
        //========================================
        2'b01: begin

            case (alucontrol)

                // Existing scalar operations
                5'b00000: Result = SrcA + SrcB;
                5'b00001: Result = SrcA - SrcB;

                5'b00010: Result = SrcA | SrcB;
                5'b00011: Result = SrcA & SrcB;

                5'b00100: Result = ~(SrcA & SrcB);
                5'b00101: Result = ~(SrcA | SrcB);

                5'b00110: Result = SrcA ^ SrcB;
                5'b00111: Result = ~(SrcA ^ SrcB);

                5'b11100: Result = SrcA & ~SrcB;
                5'b11011: Result = SrcA | ~SrcB;

                5'b01001: Result = SrcA + 32'd1;
                5'b01010: Result = SrcA - 32'd1;

                5'b10000: Result = SrcA << SrcB[4:0];

                5'b10001:
                    Result = ($signed(SrcA) < $signed(SrcB)) ?
                             32'd1 : 32'd0;

                5'b10010:
                    Result = SrcA >> SrcB[4:0];

                5'b10011:
                    Result = $signed(SrcA) >>> SrcB[4:0];

                5'b10100:
                    Result = ($signed(SrcA) > $signed(SrcB)) ?
                             32'd1 : 32'd0;

                5'b01100:
                    Result = ($signed(SrcA) > $signed(SrcB)) ?
                             SrcA : SrcB;

                5'b01101:
                    Result = ($signed(SrcA) < $signed(SrcB)) ?
                             SrcA : SrcB;

                5'b11111:
                    Result = SrcA * SrcB;


                //====================================
                // AI: VADD8
                // 4 independent INT8 additions
                //====================================
                5'b10111: begin

                    Result[7:0]   = SrcA[7:0]   + SrcB[7:0];
                    Result[15:8]  = SrcA[15:8]  + SrcB[15:8];
                    Result[23:16] = SrcA[23:16] + SrcB[23:16];
                    Result[31:24] = SrcA[31:24] + SrcB[31:24];

                end


                //====================================
                // AI: VMAX8
                // 4 signed INT8 maximum operations
                //====================================
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


                //====================================
                // AI: SDOTP4
                // Signed 4 x INT8 Dot Product
                //====================================
                5'b11101: begin

                    Result =
                        ($signed(SrcA[7:0])   * $signed(SrcB[7:0])) +
                        ($signed(SrcA[15:8])  * $signed(SrcB[15:8])) +
                        ($signed(SrcA[23:16]) * $signed(SrcB[23:16])) +
                        ($signed(SrcA[31:24]) * $signed(SrcB[31:24]));

                end

                default:
                    Result = 32'b0;

            endcase
        end


        //========================================
        // R2 TYPE + AI EXTENSION
        //========================================
        2'b10: begin

            case (alucontrol)

                5'b00000: Result = -$signed(SrcA);

                5'b00001:
                    Result = ($signed(SrcA) < 0) ?
                             -$signed(SrcA) : SrcA;

                5'b01000: Result = ~SrcA;
                5'b01001: Result = SrcA + 32'd1;
                5'b01010: Result = SrcA - 32'd1;


                //====================================
                // AI: VRELU8
                //====================================
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

                default:
                    Result = 32'b0;

            endcase
        end


        //========================================
        // I TYPE
        //========================================
        2'b11: begin

            case (alucontrol)

                5'b00000: Result = SrcA + SrcC;
                5'b00001: Result = SrcA - SrcC;

                5'b00010: Result = SrcA | SrcC;
                5'b00011: Result = SrcA & SrcC;

                5'b00110: Result = SrcA ^ SrcC;

                5'b10000:
                    Result = SrcA << SrcC[4:0];

                5'b10010:
                    Result = SrcA >> SrcC[4:0];

                5'b10011:
                    Result = $signed(SrcA) >>> SrcC[4:0];

                default:
                    Result = 32'b0;

            endcase
        end

        default:
            Result = 32'b0;

    endcase

end

endmodule
