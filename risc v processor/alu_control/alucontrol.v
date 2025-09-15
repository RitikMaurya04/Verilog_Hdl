// Code your design here
module alu_control(input [2:0]aluop,input [2:0]func3,input [3:0]func7,output reg [1:0]mode,output reg [4:0]control);
  
  always @(*)
    begin
  case(aluop)
    3'b011 :begin mode = 2'b11; control = 5'b00000; end//LW SW Instruction
    3'b010 :begin  				//R4 TYPE
            mode = 2'b00;
      		case({func7,func3})     //R4 TYPE
             7'b0000_000 :control = 5'b00000; //add
      		 7'b0001_000 :control = 5'b00001; //sub
             7'b0010_000 :control = 5'b00010; //or
      		 7'b0010_001 :control = 5'b00011; //and
      		 7'b0010_010 :control = 5'b00100; //nand
      		 7'b0010_100 :control = 5'b00101; //nor
             7'b0010_011 :control = 5'b00110; //xor
      		 7'b0010_101 :control = 5'b00111; //xnor
      		 7'b1100_010 :control = 5'b10110; //xor and
             7'b1100_011 :control = 5'b10101; //not and xor
             7'b1100_101 :control = 5'b11001; //not or and
             7'b1100_001 :control = 5'b11010; //and not2
      		 7'b0100_000 :control = 5'b01001; //inc
             7'b0101_000 :control = 5'b01010; //dec
      		 //7'b0100_001 :control <= 10000; //sll
      		 //7'b0100_010 :control <= 10001; //slt
             //7'b0100_100 :control <= 10010; //srl
      		 //7'b0100_110 :control <= 10011; //sra
      		 //7'b0100_101 :control <= 10100; //sgt
       		 7'b0110_100 :control = 5'b01100; //max
      		 7'b0110_110 :control = 5'b01101; //min
      		 7'b0110_101 :control = 5'b01110; //mac
      		 7'b0110_011 :control = 5'b01111; //msc
             default : control = 5'b11111 ;
             endcase
             end
      3'b100 : begin
             mode = 2'b01;
        	case({func7,func3})					//R3 TYPE
             7'b0000_000 :control = 5'b00000; //add
      		 7'b0001_000 :control = 5'b00001; //sub
             7'b0010_000 :control = 5'b00010; //or
      		 7'b0010_001 :control = 5'b00011; //and
      		 7'b0010_010 :control = 5'b00100; //nand
      		 7'b0010_100 :control = 5'b00101; //nor
             7'b0010_011 :control = 5'b00110; //xor
      		 7'b0010_101 :control = 5'b00111; //xnor
      		 7'b1100_010 :control = 5'b11011; //or not
             7'b1100_011 :control = 5'b11100; //and not
             7'b0100_000 :control = 5'b01001; //inc
             7'b0101_000 :control = 5'b01010; //dec
      		 7'b0100_001 :control = 5'b10000; //sll
      		 7'b0100_010 :control = 5'b10001; //slt
             7'b0100_100 :control = 5'b10010; //srl
      		 7'b0100_110 :control = 5'b10011; //sra
      		 7'b0100_101 :control = 5'b10100; //sgt
       		 7'b0110_100 :control = 5'b01100; //max
      		 7'b0110_110 :control = 5'b01101; //min
             7'b0110_001 :control = 5'b11000;  //mul
             default : control =  5'b11111;
            endcase
      		end 
     3'b110 : begin
             mode = 2'b10;
       		 case({func7,func3})					//R2 TYPE
             7'b0000_000 :control <= 5'b00000; //neg
      		 7'b0001_000 :control <= 5'b00001; //abs
            // 7'b0010_000 :control <= 00010; //or
      		// 7'b0010_001 :control <= 00011; //and
      		// 7'b0010_010 :control <= 00100; //nand
      		// 7'b0010_100 :control <= 00101; //nor
            // 7'b0010_011 :control <= 00110; //xor
      		// 7'b0010_101 :control <= 00111; //xnor
      		 7'b0010_011 :control = 5'b01000; //not
      		 7'b0100_000 :control = 5'b01001; //inc
             7'b0101_000 :control = 5'b01010; //dec
      		 //7'b0100_001 :control = 5'b10000; //sll
      		 //7'b0100_010 :control <= 10001; //slt
             //7'b0100_100 :control = 5'b10010; //srl
      		 //7'b0100_110 :control <= 10011; //sra
      		 //7'b0100_101 :control <= 10100; //sgt
       		 //7'b0110_100 :control <= 01100; //max
      		 //7'b0110_110 :control <= 01101; //min
             default : control = 5'b11111;
            endcase
      		end  
    3'b111 : begin
             mode = 2'b11;
      		 case({func7,func3})					//I TYPE
             7'b0000_000 :control = 5'b00000; //addi
      		 7'b0001_000 :control = 5'b00001; //subi
             7'b0010_000 :control = 5'b00010; //ori
      		 7'b0010_001 :control = 5'b00011; //andi
      		 //7'b0010_010 :control <= 00100; //nandi
      		 //7'b0010_100 :control <= 00101; //nori
             7'b0010_011 :control = 5'b00110; //xori
      		 //7'b0010_101 :control <= 00111; //xnori
      		// 7'b0010_011 :control <= 00000; //noti
      		 //7'b0100_000 :control <= 00000; //inci
            //7'b0100_000 :control <= 00000; //deci
      		 7'b0100_001 :control = 5'b10000; //slli
      		// 7'b0100_010 :control <= 00000; //slti
             7'b0100_100 :control = 5'b10010; //srli
      		 7'b0100_110 :control = 5'b10011; //srai
      		 //7'b0100_101 :control <= 00000; //sgti
       		 7'b0110_100 :control = 5'b00111; //maxi
      		 7'b0110_110 :control = 5'b10100; //mini
             default : control =  5'b11111;
            endcase
      		end 
        default: begin
        mode = 2'b00;
        control =  5'b11111; // default safe
        end
  endcase
   	end	 
    endmodule     		 
      		 
      		 
      		 