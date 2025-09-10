// Code your design here
module alu(input [31:0]SrcA, input [31:0]SrcB , input [31:0]SrcC, input [4:0] alucontrol , input [1:0]mode, output reg [31:0]Result , output zero);
  
  always @(*)
    begin
      if(mode== 00)         //R4 TYPE
       begin
       case(alucontrol)
        5'b00000 :  Result = SrcA + SrcB + SrcC; //add
      	5'b00001 :  Result = SrcA + SrcB + SrcC; //sub
        5'b00010 :  Result = SrcA | SrcB | SrcC;  //or
      	5'b00011:  Result = SrcA & SrcB & SrcC; //and
         5'b00100:  Result = ~(SrcA & SrcB & SrcC); //nand
         5'b00101:  Result = ~(SrcA | SrcB |SrcC); //nor
        5'b00110:  Result = SrcA ^ SrcB ^ SrcC; //xor
         5'b00111:  Result = ~(SrcA ^ SrcB ^ SrcC); //xnor
         5'b10110:  Result = (SrcA & SrcB) ^ SrcC; //xor and
         5'b10101:  Result = ~((SrcA & SrcB) ^ SrcC); //not and xor
         5'b11001: Result = ~(SrcA | SrcB) & SrcC;  //not or and
         5'b11010:  Result = SrcA & ~SrcB & ~SrcC; //and not2
         5'b01001:  Result = (SrcA+1) + (SrcB+1) + (SrcC+1); //inc
         5'b01010:  Result = (SrcA-1) + (SrcB-1) + (SrcC-1); //dec
         //5'b10000;  Result = SrcA + SrcB + SrcC; //sll
      	//5'b10001;  Result = SrcA + SrcB + SrcC; //slt
         //5'b10010;  Result = SrcA + SrcB + SrcC; //srl
      	//5'b10011; Result = SrcA + SrcB + SrcC;  //sra
      	//5'b10100; Result = SrcA + SrcB + SrcC;  //sgt
        5'b01100: begin Result = (SrcA > SrcB) ? ((SrcA > SrcC) ? SrcA : SrcC) :((SrcB > SrcC) ? SrcB : SrcC); end //max
      	5'b01101: begin Result = (SrcA < SrcB) ?((SrcA < SrcC) ? SrcA : SrcC) :((SrcB < SrcC) ? SrcB : SrcC); end  //min
         5'b01110: Result = (SrcA * SrcB) + SrcC;  //mac
         5'b01111:  Result = (SrcA * SrcB) - SrcC; //msc 
         default : Result = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
       endcase
       end
         
      if(mode== 01)      //R3 TYPE
       begin
       if(branch==0)
       case(alucontrol)
        5'b00000 :  Result = SrcA + SrcB ; //add
      	5'b00001 :  Result = SrcA + SrcB ; //sub
        5'b00010 :  Result = SrcA | SrcB ;  //or
      	5'b00011:  Result = SrcA & SrcB ; //and
         5'b00100:  Result = ~(SrcA & SrcB ); //nand
         5'b00101:  Result = ~(SrcA | SrcB ); //nor
        5'b00110:  Result = SrcA ^ SrcB ; //xor
         5'b00111:  Result = ~(SrcA ^ SrcB); //xnor
         5'b11100:  Result = SrcA & ~SrcB; //not and
         5'b11011: Result = SrcA | ~SrcB;  //not or
         5'b01001:  Result = (SrcA+1) + (SrcB+1) ; //inc
         5'b01010:  Result = (SrcA-1) + (SrcB-1) ; //dec
         5'b10000:  Result = SrcA << SrcB[4:0]; //sll
      	5'b10001:  Result = (SrcA < SrcB) ? 1 : 0; //slt
         5'b10010: Result = SrcA >> SrcB[4:0];  //srl
      	5'b10011: Result = $signed(SrcA) >>> SrcB ;  //sra
      	5'b10100: Result = (SrcA > SrcB) ? 1 : 0;  //sgt
       5'b01100:  Result = (SrcA > SrcB) ? SrcA : SrcB; //max
       	5'b01101: Result = (SrcA < SrcB) ? SrcA : SrcB; //min
         5'b11111: Result = SrcA * SrcB; //mul
       default : Result = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
       endcase
       end
      if(mode== 10)      //R2 TYPE
       begin
       case(alucontrol)
         5'b00000 :  Result = - $signed(SrcA) ; //neg      	
         5'b00001 : Result = ($signed(SrcA) < 0) ? -$signed(SrcA) : SrcA; // ABS
//         5'b00010 :  Result = SrcA | SrcB   //or
//       	5'b00011;  Result = SrcA & SrcB  //and
//          5'b00100;  Result = ~(SrcA & SrcB ); //nand
//          5'b00101;  Result = ~(SrcA | SrcB ); //nor
//         5'b00110;  Result = SrcA ^ SrcB ; //xor
//          5'b00111;  Result = ~(SrcA ^ SrcB); //xnor
         5'b01000:  Result = ~SrcA ;//not
        // 5'b11011; Result = SrcA | ~SrcB;  //not or
         5'b01001:  Result = (SrcA+1);  //inc
         5'b01010:  Result = (SrcA-1) ; //dec
        // 5'b10000;  Result = SrcA << SrcB; //sll
      	//5'b10001;  Result = (SrcA < SrcB) ? 1 : 0; //slt
        // 5'b10010; Result = SrcA >> SrcB;  //srl
      	//5'b10011; Result = $signed(SrcA) >>> SrcB; ;  //sra
      	//5'b10100; Result = (SrcA > SrcB) ? 1 : 0;  //sgt
       //5'b01100;  Result = Result = (SrcA > SrcB) ? SrcA : SrcB; //max
      	//5'b01101; Result = Result = (SrcA < SrcB) ? SrcA : SrcB; //min
       default : Result = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
       endcase
       end
         
            if(mode <= 11)
              begin
              case(alucontrol)					//I TYPE
             5'b00000: Result = SrcA + SrcC; //addi
      		 5'b00001: Result = SrcA - SrcC;//subi
             5'b00010: Result = SrcA | SrcC; //ori
      		  5'b00011: Result = SrcA & SrcC;//andi
      		 //7'b0010_010 :control <= 00100; //nandi
      		 //7'b0010_100 :control <= 00101; //nori
             5'b00110: Result = SrcA ^ SrcC; //xori
      		 //7'b0010_101 :control <= 00111; //xnori
      		// 7'b0010_011 :control <= 00000; //noti
      		 //7'b0100_000 :control <= 00000; //inci
            //7'b0100_000 :control <= 00000; //deci
               5'b10000: Result = SrcA << SrcC[4:0]; //slli
      		// 7'b0100_010 :control <= 00000; //slti
                5'b10010: Result = SrcA >> SrcC[4:0]; //srli
                5'b10011: Result = $signed(SrcA) >>> SrcC[4:0];  //srai
      		 //7'b0100_101 :control <= 00000; //sgti
       		 //7'b0110_100 :control <= 00000; //maxi
      		 //7'b0110_110 :control <= 00000; //mini
             default : Result = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
              endcase
                end 
      end 
     endmodule
    
