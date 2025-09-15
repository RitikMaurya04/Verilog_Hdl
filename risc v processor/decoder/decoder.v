module main_decoder(input [4:0]opcode,input zero,output reg [2:0]aluop, reg regwrite,reg memwrite,reg memread,reg alumuxen1,reg  alumuxen2,reg alumuxsel1,reg alumuxsel2,reg [1:0]d_dmuxsel,reg resultsel,reg [1:0]selr, reg branch,reg jump

    );
 
  
   always @(*) begin
     case(opcode)
            5'b01101 : begin  //R4 Type Instructions
               regwrite = 1;
               aluop =010;
                
                memwrite = 0;
                memread =0;
               alumuxen1 =1;
              alumuxen2 =1;
              alumuxsel1 =0;
              alumuxsel2 =0;
              d_dmuxsel =00;
              resultsel = 0;
              selr =00;
              branch =0;
              jump = 0;
              
            end
            5'b00011 : begin //R3 Type Instructions
               regwrite = 1;
               aluop =100;
                memwrite = 0;
                memread =0;
                alumuxen1 =1;
              alumuxen2 =0;
              alumuxsel1 =0;
              alumuxsel2 =0;
              d_dmuxsel =00;
              
               resultsel = 0;
              selr =00;
              aluop =0;
              branch =0;
              jump = 0;
              
            end
            5'b0001 : begin  //R2 Type Instructions
               regwrite = 1; 
               aluop =110;
              memwrite= 0;
                memread =0;
                alumuxen1 =0;
              alumuxen2 =0;
              alumuxsel1 =0;
              alumuxsel2 =0;
              d_dmuxsel =00;
              branch =0;
               resultsel = 0;
             selr =00;
             
              jump = 0;
              
            end
         
            5'b00101 : begin  //R2 MOV Type Instructions
               regwrite = 1; 
               aluop =000;
              memwrite = 0;
                memread =0;
                alumuxen1 =0;
              alumuxen2 =0;
              alumuxsel1 =0;
              alumuxsel2 =0;
              d_dmuxsel =00;
              
               resultsel = 0;
              selr =01;
              aluop =0;
              branch =0;
              jump = 0;
              
            end
          
           5'b10111: begin // Load Word Instruction
                regwrite = 1;
                 aluop =011;
                memwrite = 0;
                memread =1;
                alumuxen1 =0;
              	alumuxen2 =1;
              	alumuxsel1 =0;
              	alumuxsel2 =1;
              	d_dmuxsel =01;
              	branch =0;
              resultsel = 1;
              selr =00;
             
             jump = 0;
               end
            5'b10001: begin // Store Word Instruction
                regwrite = 0;
                aluop =011;
                memwrite = 1;
                memread =0;
                alumuxen1 =0;
              	alumuxen2 =1;
              	alumuxsel1 =0;
              	alumuxsel2 =1;
              	d_dmuxsel =10;
              	
               resultsel = 0;
              selr=00;
              	
              branch =0;
              jump = 0;
              
            end
            5'b01010: begin // Branch Instruction
                regwrite = 0;
                aluop =110;
                memwrite = 0;
                memread =0;
                alumuxen1 =1;
              	alumuxen2 =0;
              	alumuxsel1 =0;
              	alumuxsel2 =0;
              	d_dmuxsel =00;
              	
               resultsel = 0;
               selr =00;
              
              branch =1;
              jump = 0;
            end
            5'b11101: begin // I-type Instruction
                regwrite = 1;
                 aluop =111;
                memwrite = 0;
                memread =0;
                alumuxen1 =0;
              	alumuxen2 =1;
              	alumuxsel1 =0;
              	alumuxsel2 =1;
              	d_dmuxsel =00;
              	branch =0;
               resultsel = 0;
              selr=00;
              	aluop =0;
              branch =0;
              jump = 0;
              
            end
           5'b01111: begin // JALR-type Instruction
                regwrite = 1;
                aluop =010;
                memwrite = 0;
                memread =0;
                alumuxen1 =0;
              	alumuxen2 =1;
              	alumuxsel1 =0;
              	alumuxsel2 =1;
              	d_dmuxsel =10;
              	 resultsel = 0;
                
              	selr =11;
             branch =0;
             jump = 1;
              
            end
           5'b11110: begin // JAL-type Instruction
                regwrite = 1;
                 aluop =010;
                memwrite = 0;
                memread =0;
                alumuxen1 =0;
              	alumuxen2 =0;
              	alumuxsel1 =0;
              	alumuxsel2 =0;
              	d_dmuxsel =00;
              resultsel = 0;
               selr=11;
              	branch =0;
               jump = 1;
              
             end
       
            default: begin
                regwrite = 0;
                 aluop =000;
                memwrite = 0;
                memread =0;
                alumuxen1 =0;
              	alumuxen2 =0;
              	alumuxsel1 =0;
              	alumuxsel2 =0;
              	d_dmuxsel =00;
              resultsel = 0;
               selr=00;
              	branch =0;
             jump = 0;
            end
        endcase
    end
endmodule

