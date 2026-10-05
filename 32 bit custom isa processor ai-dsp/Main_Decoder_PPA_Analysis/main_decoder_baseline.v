// Code your design here
module main_decoder_baseline (
    input  [4:0] opcode,
  input  [4:0] func,
    output reg [3:0] aluop,
    output reg       regwrite1,
    output reg       regwrite2,
    output reg       memwrite,
    output reg       memread,
    output reg       alumuxsel1,
    output reg [1:0] resultsel,
    output reg [2:0] ImmType,
    output reg [1:0] ImmMode,

   

    // Branch control
    output reg       branch,
    output reg [4:0] branchtype,

    // Jump control
    output reg       jump,
    output reg       jalr,
    output reg       link
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
    // Main Decoder
    //==========================================================

    always @(*) begin

        //======================================================
        // Default values
        //======================================================

        aluop       = 4'b0000;

        regwrite1   = 1'b0;
        regwrite2   = 1'b0;

        memwrite    = 1'b0;
        memread     = 1'b0;

        alumuxsel1  = 1'b0;

        resultsel   = 2'b00;

        

        ImmType     = 3'b000;
        ImmMode     = 2'b00;


        branch      = 1'b0;
        branchtype  = NONE;

        jump        = 1'b0;
        jalr        = 1'b0;
        link        = 1'b0;


        //======================================================
        // Opcode decoding
        //======================================================

        case (opcode)


            //==================================================
            // R4 TYPE
            //==================================================

            5'b00001: begin

                regwrite1  = 1'b1;
                regwrite2  = 1'b0;

                aluop      = 4'b0010;

                ImmType    = 3'b000;
                ImmMode    = 2'b00;

                memwrite   = 1'b0;
                memread    = 1'b0;

                alumuxsel1 = 1'b0;

                resultsel  = 2'b00;

             
                branch     = 1'b0;
                branchtype = NONE;
                jump        = 1'b0;
                jalr        = 1'b0;
        	link        = 1'b0;


            end


            //==================================================
            // R3 TYPE
            //==================================================

            5'b00010: begin

                regwrite1  = 1'b1;
                regwrite2  = 1'b0;

                aluop      = 4'b0101;

                ImmType    = 3'b000;
                ImmMode    = 2'b00;

                memwrite   = 1'b0;
                memread    = 1'b0;

                alumuxsel1 = 1'b0;

                resultsel  = 2'b00;

                
              	branch     = 1'b0;
                branchtype = NONE;
		        jump        = 1'b0;
        	    jalr        = 1'b0;
        	    link        = 1'b0;


            end


            //==================================================
            // R3I TYPE
            //==================================================

            5'b00011: begin

                regwrite1  = 1'b1;
                regwrite2  = 1'b0;

                aluop      = 4'b0100;

                ImmType    = 3'b101;
                ImmMode    = 2'b00;

                memwrite   = 1'b0;
                memread    = 1'b0;

                alumuxsel1 = 1'b1;

                resultsel  = 2'b00;


                branch     = 1'b0;
                branchtype = NONE;
 	        jump        = 1'b0;
        	jalr        = 1'b0;
        	link        = 1'b0;



            end


            //==================================================
            // R4 MOVE TYPE
            //==================================================

            5'b01000: begin

                regwrite1  = 1'b1;
                regwrite2  = 1'b1;

                aluop      = 4'b0011;

                ImmType    = 3'b000;
                ImmMode    = 2'b00;

                memwrite   = 1'b0;
                memread    = 1'b0;

                alumuxsel1 = 1'b0;

                resultsel  = 2'b10;

              
                branch     = 1'b0;
                branchtype = NONE;
		jump        = 1'b0;
        	jalr        = 1'b0;
        	link        = 1'b0;



            end


            //==================================================
            // R2  TYPE
            //==================================================

            5'b01011: begin

                regwrite1  = 1'b1;
                regwrite2  = 1'b0;

                aluop      = 4'b0110;

                ImmType    = 3'b000;
                ImmMode    = 2'b00;

                memwrite   = 1'b0;
                memread    = 1'b0;

                alumuxsel1 = 1'b0;

                resultsel  = 2'b00;


                branch     = 1'b0;
                branchtype = NONE;

            end
             //==================================================
            // R2  MOV TYPE
            //==================================================

             5'b01010: begin

                regwrite1  = 1'b1;
                regwrite2  = 1'b0;

                aluop      = 4'b0110;

                ImmType    = 3'b000;
                ImmMode    = 2'b00;

                memwrite   = 1'b0;
                memread    = 1'b0;

                alumuxsel1 = 1'b0;

                resultsel  = 2'b10;


                branch     = 1'b0;
                branchtype = NONE;

            end


            //==================================================
            // I TYPE
            //==================================================

            5'b00100: begin

                regwrite1  = 1'b1;
                regwrite2  = 1'b0;

                aluop      = 4'b1000;

                ImmType    = 3'b001;
                ImmMode    = 2'b00;

                memwrite   = 1'b0;
                memread    = 1'b0;

                alumuxsel1 = 1'b1;

                resultsel  = 2'b00;

               
                branch     = 1'b0;
                branchtype = NONE;
		jump        = 1'b0;
        	jalr        = 1'b0;
        	link        = 1'b0;



            end


            //==================================================
            // LOAD WORD
            //==================================================

            5'b00111: begin

                regwrite1  = 1'b1;
                regwrite2  = 1'b0;

                aluop      = 4'b0001;

                ImmType    = 3'b001;
                ImmMode    = 2'b00;

                memwrite   = 1'b0;
                memread    = 1'b1;

                alumuxsel1 = 1'b1;

                resultsel  = 2'b01;


                branch     = 1'b0;
                branchtype = NONE;
		jump        = 1'b0;
        	jalr        = 1'b0;
        	link        = 1'b0;


            end


            //==================================================
            // STORE WORD
            //==================================================

            5'b00101: begin

                regwrite1  = 1'b0;
                regwrite2  = 1'b0;

                aluop      = 4'b0001;

                ImmType    = 3'b010;
                ImmMode    = 2'b00;

                memwrite   = 1'b1;
                memread    = 1'b0;

                alumuxsel1 = 1'b1;

                resultsel  = 2'b00;


                branch     = 1'b0;
                branchtype = NONE;
		jump        = 1'b0;
        	jalr        = 1'b0;
        	link        = 1'b0;


            end


            //==================================================
            // BRANCH
            //
            // FUNC is translated into branchtype here.
            // Branch Unit receives branchtype, not func.
            //==================================================

            5'b00110: begin

                regwrite1  = 1'b0;
                regwrite2  = 1'b0;

                aluop      = 4'b0000;

                ImmType    = 3'b011;
                ImmMode    = 2'b00;

                memwrite   = 1'b0;
                memread    = 1'b0;

                alumuxsel1 = 1'b0;

                resultsel  = 2'b00;



                branch     = 1'b1;

                // RS1 is required by every branch type
                case (func)

                    BEQ,
                    BNEQ,
                    BGT,
                    BLT,
                    BGST,
                    BLST: begin
                        branchtype = func;
                    end

                    BLTZ,
                    BGTZ,
                    BGEZ,
                    BLEZ,
                    BEQZ,
                    BNEZ: begin
                        branchtype = func;
                    end

                    default: begin
                        branchtype = NONE;
                        branch = 1'b0;
                    end
                endcase

            end
//==================================================
            // JALR TYPE
            //
            // PC target = RS1 + Imm
            // rd = PC + 4
            //==================================================

            5'b01111: begin

                regwrite1  = 1'b1;
                regwrite2  = 1'b0;

                aluop      = 4'b0000;

                ImmType    = 3'b110;
                ImmMode    = 2'b00;

                memwrite   = 1'b0;
                memread    = 1'b0;

                alumuxsel1 = 1'b0;

                resultsel  = 2'b11;

              

                branch     = 1'b0;
                branchtype = NONE;
                jump       = 1'b0;
                jalr       = 1'b1;
                link       = 1'b1;

            end


            //==================================================
            // JAL TYPE
            //
            // PC target = PC + Imm
            // rd = PC + 4
            //==================================================

            5'b11110: begin

                regwrite1  = 1'b1;
                regwrite2  = 1'b0;

                aluop      = 4'b0000;

                ImmType    = 3'b100;
                ImmMode    = 2'b00;

                memwrite   = 1'b0;
                memread    = 1'b0;

                alumuxsel1 = 1'b0;

                resultsel  = 2'b11;

                

                branch     = 1'b0;
                branchtype = NONE;
                jump       = 1'b1;
                jalr       = 1'b0;
                link       = 1'b1;

            end


            //==================================================
            // DEFAULT / INVALID
            //==================================================

            default: begin

                regwrite1  = 1'b0;
                regwrite2  = 1'b0;

                aluop      = 4'b0000;

                ImmType    = 3'b000;
                ImmMode    = 2'b00;

                memwrite   = 1'b0;
                memread    = 1'b0;

                alumuxsel1 = 1'b0;

                resultsel  = 2'b00;



                branch     = 1'b0;
                branchtype = NONE;

                jump       = 1'b0;
                jalr       = 1'b0;
                link       = 1'b0;

            end

        endcase

    end

endmodule