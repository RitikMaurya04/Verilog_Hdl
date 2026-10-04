// Code your design here
//==============================================================
// Branch Unit
//
// Purpose:
//   Evaluates the branch condition selected by the decoder.
//
// Inputs:
//   branch     : Enables the branch unit
//   branchrs1  : Enables/isolate RS1 operand
//   branchrs2  : Enables/isolate RS2 operand
//   rdata1     : Register-file read data 1
//   rdata2     : Register-file read data 2
//   branchtype : Branch condition selected by decoder
//
// Output:
//   branch_taken : Indicates whether the branch condition is true
//
// Power Optimization:
//   Operand isolation prevents changing register-file outputs
//   from propagating into the branch comparison logic when
//   those operands are not required.
//
// Branch target calculation is handled by PCControl.
//==============================================================

module branch_unit (
    input         branch,
    input         branchrs1,
    input         branchrs2,

    input  [31:0] rdata1,
    input  [31:0] rdata2,

  input  [4:0]  branchtype,

    output reg    branch_taken
);

    //==========================================================
    // Branch Type Encoding
    //==========================================================

  localparam [4:0] NONE = 5'd0;

    // Two-register comparisons
  localparam [4:0] BEQ  = 5'd1;   // Equal
  localparam [4:0] BNEQ = 5'd2;   // Not equal

  localparam [4:0] BGT  = 5'd3;   // Greater than, unsigned
  localparam [4:0] BLT  = 5'd4;   // Less than, unsigned

  localparam [4:0] BGST = 5'd5;   // Greater than, signed
  localparam [4:0] BLST = 5'd6;   // Less than, signed

    // Single-register signed comparisons
  localparam [4:0] BLTZ = 5'd7;   // Less than zero
  localparam [4:0] BGTZ = 5'd8;   // Greater than zero
  localparam [4:0] BGEZ = 5'd9;   // Greater than or equal to zero
  localparam [4:0] BLEZ = 5'd10;  // Less than or equal to zero

    // Single-register equality comparisons
  localparam [4:0] BEQZ = 5'd11;  // Equal to zero
  localparam [4:0] BNEZ = 5'd12;  // Not equal to zero


    //==========================================================
    // Operand Isolation
    //
    // RS1 and RS2 can be independently isolated depending on
    // whether the selected branch condition actually requires
    // them.
    //==========================================================

    wire [31:0] rdata1_iso;
    wire [31:0] rdata2_iso;
  wire [4:0]  branchtype_iso;

    assign rdata1_iso =
        (branch && branchrs1) ? rdata1 : 32'b0;

    assign rdata2_iso =
        (branch && branchrs2) ? rdata2 : 32'b0;

    assign branchtype_iso =
        branch ? branchtype : NONE;


    //==========================================================
    // Branch Condition Evaluation
    //==========================================================

    always @(*) begin

        // Default: branch is not taken
        branch_taken = 1'b0;

        if (branch) begin

            case (branchtype_iso)

                //================================================
                // Two-register comparisons
                //================================================

                BEQ:
                    branch_taken = (rdata1_iso == rdata2_iso);

                BNEQ:
                    branch_taken = (rdata1_iso != rdata2_iso);

                // Unsigned comparisons
                BGT:
                    branch_taken = (rdata1_iso > rdata2_iso);

                BLT:
                    branch_taken = (rdata1_iso < rdata2_iso);

                // Signed comparisons
                BGST:
                    branch_taken =
                        ($signed(rdata1_iso) >
                         $signed(rdata2_iso));

                BLST:
                    branch_taken =
                        ($signed(rdata1_iso) <
                         $signed(rdata2_iso));


                //================================================
                // Single-register signed comparisons
                //================================================

                BLTZ:
                    branch_taken =
                        ($signed(rdata1_iso) < 0);

                BGTZ:
                    branch_taken =
                        ($signed(rdata1_iso) > 0);

                BGEZ:
                    branch_taken =
                        ($signed(rdata1_iso) >= 0);

                BLEZ:
                    branch_taken =
                        ($signed(rdata1_iso) <= 0);


                //================================================
                // Single-register zero comparisons
                //================================================

                BEQZ:
                    branch_taken =
                        (rdata1_iso == 32'b0);

                BNEZ:
                    branch_taken =
                        (rdata1_iso != 32'b0);


                //================================================
                // Invalid / no branch
                //================================================

                default:
                    branch_taken = 1'b0;

            endcase

        end

    end

endmodule