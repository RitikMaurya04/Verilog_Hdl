// ============================================================
// BASELINE IMMEDIATE GENERATOR
//
// No ImmEnable and no input-isolation muxes.
// Immediate generation remains combinational and functionally
// equivalent to the supplied RTL.
// ============================================================

module immext_baseline #(
    parameter Width = 32
)(
    input  [31:0] instruction,
    input  [2:0]  ImmType,
    input  [1:0]  ImmMode,
    output reg [Width-1:0] Out
);

    always @(*) begin
        Out = {Width{1'b0}};

                   case (ImmType)
        
                    // =================================================
                    // I-TYPE
                    // IMM = instruction[26:15]
                    // =================================================
        
                    3'b001: begin
        
                        case (ImmMode)
        
                            // Sign extend
                            2'b00:
                                Out = {
                                    {(Width-12){instruction[26]}},
                                    instruction[26:15]
                                };
        
                            // Zero extend
                            2'b01:
                                Out = {
                                    {(Width-12){1'b0}},
                                    instruction[26:15]
                                };
        
                            // Sign extend then shift left by 2
                            2'b10:
                                Out = (
                                    {
                                        {(Width-12){instruction[26]}},
                                        instruction[26:15]
                                    }
                                ) << 2;
        
                            // Custom pattern
                            2'b11:
                                Out = {
                                    20'hABCDF,
                                    instruction[26:15]
                                };
        
                            default:
                                Out = {Width{1'b0}};
        
                        endcase
        
                    end
        
        
                    // =================================================
                    // S-TYPE
                    // IMM = instruction[26:20],instruction[9:5]
                    // =================================================
        
                    3'b010: begin
        
                        case (ImmMode)
        
                            // Sign extend
                            2'b00:
                                Out = {
                                    {(Width-12){instruction[26]}},
                                    instruction[26:20],instruction[9:5]
                                };
        
                            // Zero extend
                            2'b01:
                                Out = {
                                    {(Width-12){1'b0}},
                                    instruction[26:20],instruction[9:5]
                                };
        
                            // Sign extend then shift left by 2
                            2'b10:
                                Out = (
                                    {
                                        {(Width-12){instruction[26]}},
                                        instruction[26:20],instruction[9:5]
                                    }
                                ) << 2;
        
                            // Custom pattern
                            2'b11:
                                Out = {
                                    20'hABCDF,
                                    instruction[26:20],instruction[9:5]
                                };
        
                            default:
                                Out = {Width{1'b0}};
        
                        endcase
        
                    end
        
        
                    // =================================================
                    // B-TYPE
                    // IMM = instruction[26:20],instruction[9:5]
        
                    // =================================================
        
                    3'b011: begin
        
                        case (ImmMode)
        
                            // Sign extend
                            2'b00:
                                Out = {
                                    {(Width-12){instruction[26]}},
                                    instruction[26:20],instruction[9:5]
        
                                };
        
                            // Zero extend
                            2'b01:
                                Out = {
                                    {(Width-12){1'b0}},
                                    instruction[26:20],instruction[9:5]
        
                                };
        
                            // Sign extend then shift left by 1
                            2'b10:
                                Out = (
                                    {
                                        {(Width-12){instruction[26]}},
                                        instruction[26:20],instruction[9:5]
        
                                    }
                                ) << 1;
        
                            // Custom pattern
                            2'b11:
                                Out = {
                                    20'hABCDF,
                                    instruction[26:20],instruction[9:5]
        
                                };
        
                            default:
                                Out = {Width{1'b0}};
        
                        endcase
        
                    end
        
        
                    // =================================================
                    // J-TYPE
                    // IMM = instruction[31:10]
                    // 22-bit signed immediate
                    // =================================================
        
                    3'b100: begin
        
                        case (ImmMode)
        
                            // Sign extend 22-bit immediate
                            2'b00:
                                Out = {
                                    {(Width-22){instruction[31]}},
                                    instruction[31:10]
                                };
        
                            // Zero extend
                            2'b01:
                                Out = {
                                    {(Width-22){1'b0}},
                                    instruction[31:10]
                                };
        
                            // Sign extend then shift left by 1
                            2'b10:
                                Out = (
                                    {
                                        {(Width-22){instruction[31]}},
                                        instruction[31:10]
                                    }
                                ) << 1;
        
                            // Custom pattern
                            2'b11:
                                Out = {
                                    10'h2AA,
                                    instruction[31:10]
                                };
                             default:
                                Out = {Width{1'b0}};
                             endcase
        
                         end
                    // =================================================
                    // R3I-TYPE
                            // IMM = instruction[24:20]
                    // =================================================
        
                             3'b101: begin
        
                        case (ImmMode)
        
                            // Sign extend 5-bit immediate
                            2'b00:
                                Out = {
                                    {(Width-5){instruction[24]}},
                                    instruction[24:20]
                                };
        
                            // Zero extend
                            2'b01:
                                Out = {
                                    {(Width-5){1'b0}},
                                    instruction[24:20]
                                };
        
                            // Sign extend then shift left by 1
                            2'b10:
                                Out = (
                                    {
                                        {(Width-5){instruction[24]}},
                                        instruction[24:20]
                                    }
                                ) << 1;
        
                            // Custom pattern
                            2'b11:
                                Out = {
                                    27'h2AAFBC1,
                                    instruction[24:20]
                                };
        
                            default:
                                Out = {Width{1'b0}};
        
                        endcase
        
                    end
                 // =================================================
                    // JALR-TYPE
                    // IMM = instruction[31:15]
        
                    // =================================================
        
                    3'b110: begin
        
                        case (ImmMode)
        
                            // Sign extend
                            2'b00:
                                Out = {
                                    {(Width-17){instruction[31]}},
                                    instruction[31:15]
        
                                };
        
                            // Zero extend
                            2'b01:
                                Out = {
                                    {(Width-17){1'b0}},
                                    instruction[31:15]
        
                                };
        
                            // Sign extend then shift left by 1
                            2'b10:
                                Out = (
                                    {
                                        {(Width-17){instruction[31]}},
                                        instruction[31:15]
        
                                    }
                                ) << 1;
        
                            // Custom pattern
                            2'b11:
                                Out = {
                                    15'hABCDF,
                                    instruction[31:15]
        
                                };
        
                            default:
                                Out = {Width{1'b0}};
        
                        endcase
        
                    end
        
        
        
        
        
                    // =================================================
                    // NONE / INVALID
                    // =================================================
        
                    default:
                        Out = {Width{1'b0}};
        
                endcase
    end
endmodule
