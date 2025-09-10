// Code your design here
module main_decoder(input [4:0]opcode,input zero,output reg [2:0]aluop regwrite,memwrite,memread,alumuxen1,alumuxen2,alumuxsel1,alumuxsel2,[1:0]d_dmuxsel,resultsel,[1:0]selr,aluop,branch,jump);
  
   always @(*) begin
        case(op)
            5'b01101 : begin  //R4 Type Instructions
               regWrite <= 1;
               aluop <=010;
                
                memWrite <= 0;
                memread <=0;
               alumuxen1 <=1;
              alumuxen2 <=1;
              alumuxsel1 <=0;
              alumuxsel2 <=0;
              d_dmuxsel <=00;
              resultsel <= 0;
              selr <=00;
              branch <=0;
              jump <= 0;
              
            
            end
            5'b00011 : begin //R3 Type Instructions
               regWrite <= 1;
               aluop <=100;
                memWrite <= 0;
                memread <=0;
                alumuxen1 <=1;
              alumuxen2 <=0;
              alumuxsel1 <=0;
              alumuxsel2 <=0;
              d_dmuxsel <=00;
              
               resultsel <= 0;
              selr <=00;
              aluop <=0;
              branch <=0;
              jump <= 0;
              
            end
            5'b0001 : begin  //R2 Type Instructions
               regWrite <= 1; 
               aluop <=110;
              memWrite <= 0;
                memread <=0;
                alumuxen1 <=0;
              alumuxen2 <=0;
              alumuxsel1 <=0;
              alumuxsel2 <=0;
              d_dmuxsel <=00;
              branch <=0;
               resultsel <= 0;
             selr <=00;
             
              jump <= 0;
              
            end
          end
            5'b00101 : begin  //R2 MOV Type Instructions
               regWrite <= 1; 
               aluop <=000;
              memWrite <= 0;
                memread <=0;
                alumuxen1 <=0;
              alumuxen2 <=0;
              alumuxsel1 <=0;
              alumuxsel2 <=0;
              d_dmuxsel <=00;
              
               resultsel <= 0;
              selr <=01;
              aluop <=0;
              branch <=0;
              jump <= 0;
              
            end
          
           5'b10111: begin // Load Word Instruction
                regWrite <= 1;
                 aluop <=011;
                memWrite <= 0;
                memread <=1;
                alumuxen1 <=0;
              	alumuxen2 <=1;
              	alumuxsel1 <=0;
              	alumuxsel2 <=1;
              	d_dmuxsel <=01;
              	branch <=0;
              resultsel <= 1;
              selr <=00;
             
             jump <= 0;
              
            end
            5'b10001: begin // Store Word Instruction
                regWrite <= 0;
                aluop <=011;
                memWrite <= 1;
                memread <=0;
                alumuxen1 <=0;
              	alumuxen2 <=1;
              	alumuxsel1 <=0;
              	alumuxsel2 <=1;
              	d_dmuxsel <=10;
              	
               resultsel <= 0;
              selr<=00;
              	
              branch <=0;
              jump <= 0;
              
            end
            5'b01010: begin // Branch Instruction
                regWrite <= 0;
                aluop <=110;
                memWrite <= 0;
                memread <=0;
                alumuxen1 <=1;
              	alumuxen2 <=0;
              	alumuxsel1 <=0;
              	alumuxsel2 <=0;
              	d_dmuxsel <=00;
              	
               resultsel <= 0;
               selr <=00;
              
              branch <=1;
              jump <= 0;
            end
            5'b11101: begin // I-type Instruction
                regWrite <= 1;
                 aluop <=111;
                memWrite <= 0;
                memread <=0;
                alumuxen1 <=0;
              	alumuxen2 <=1;
              	alumuxsel1 <=0;
              	alumuxsel2 <=1;
              	d_dmuxsel <=00;
              	branch <=0;
               resultsel <= 0;
              selr<=00;
              	aluop <=0;
              branch <=0;
              jump <= 0;
              
            end
           5'b01111: begin // JALR-type Instruction
                regWrite <= 1;
                aluop <=010;
                memWrite <= 0;
                memread <=0;
                alumuxen1 <=0;
              	alumuxen2 <=1;
              	alumuxsel1 <=0;
              	alumuxsel2 <=1;
              	d_dmuxsel <=10;
              	 resultsel <= 0;
                
              	selr <=11;
             branch <=0;
             jump <= 1;
              
            end
           5'b11110: begin // JAL-type Instruction
                regWrite <= 1;
                 aluop <=010;
                memWrite <= 0;
                memread <=0;
                alumuxen1 <=0;
              	alumuxen2 <=0;
              	alumuxsel1 <=0;
              	alumuxsel2 <=0;
              	d_dmuxsel <=00;
              resultsel <= 0;
               selr<=11;
              	branch <=0;
             jump <= 1;
              
            end
            default: begin
                regWrite <= 0;
                 aluop <=000;
                memWrite <= 0;
                memread <=0;
                alumuxen1 <=0;
              	alumuxen2 <=0;
              	alumuxsel1 <=0;
              	alumuxsel2 <=0;
              	d_dmuxsel <=00;
              resultsel <= 0;
               selr<=00;
              	branch <=0;
             jump <= 0;
            end
        endcase
    end
endmodule
