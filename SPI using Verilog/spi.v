//SPI



`timescale 1ns/1ps

module spi_master
#(
    parameter CPOL = 0,
    parameter CPHA = 0
)
(
    input clk,
    input start,
    input [11:0] din,

    output reg mosi,
    output reg cs,
    output reg done,
    output reg sclk
);

//////////////////////////////////////
// clock divider
//////////////////////////////////////

reg [3:0] clkdiv = 0;

always @(posedge clk)
begin
    clkdiv <= clkdiv + 1;
end

wire spi_clk_en = (clkdiv == 0);

//////////////////////////////////////
// FSM
//////////////////////////////////////

parameter IDLE = 0,
          LOAD = 1,
          TRANSFER = 2,
          DONE = 3;

reg [1:0] state = IDLE;

reg [11:0] shift_reg;
reg [3:0] bitcount;

//////////////////////////////////////
// SCLK generation
//////////////////////////////////////

always @(posedge clk)
begin
    if(state == IDLE)
        sclk <= CPOL;
    else if(spi_clk_en)
        sclk <= ~sclk;
end

//////////////////////////////////////
// SPI FSM
//////////////////////////////////////

always @(posedge clk)
begin
    case(state)

    IDLE:
    begin
        cs <= 1;
        done <= 0;

        if(start)
            state <= LOAD;
    end

    LOAD:
    begin
        cs <= 0;
        shift_reg <= din;
        bitcount <= 0;
        state <= TRANSFER;
    end

    TRANSFER:
    begin
        if(spi_clk_en)
        begin

            if((CPHA==0 && sclk==~CPOL) || (CPHA==1 && sclk==CPOL))
            begin
                mosi <= shift_reg[11];
                shift_reg <= shift_reg << 1;
                bitcount <= bitcount + 1;
            end

            if(bitcount == 12)
                state <= DONE;

        end
    end

    DONE:
    begin
        cs <= 1;
        done <= 1;
        state <= IDLE;
    end

    endcase
end

endmodule
