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
    input miso,
    input [11:0] din,

    output reg mosi,
    output reg sclk,
    output reg cs,
    output reg done,
    output reg [11:0] dout
);

reg [11:0] tx_shift;
reg [11:0] rx_shift;
reg [3:0] bitcount;

reg sclk_prev;

parameter IDLE = 0,
          LOAD = 1,
          TRANSFER = 2,
          DONE = 3;

reg [1:0] state = IDLE;

always @(posedge clk)
begin
    sclk_prev <= sclk;

    case(state)

    IDLE:
    begin
        cs <= 1;
        sclk <= CPOL;
        done <= 0;

        if(start)
            state <= LOAD;
    end

    LOAD:
    begin
        cs <= 0;
        tx_shift <= din;
        rx_shift <= 0;
        bitcount <= 0;
        state <= TRANSFER;
    end

    TRANSFER:
    begin
        sclk <= ~sclk;

        if((CPHA==0 && sclk_prev==CPOL) ||
           (CPHA==1 && sclk_prev!=CPOL))
        begin
            mosi <= tx_shift[11];
            tx_shift <= tx_shift << 1;

            rx_shift <= {rx_shift[10:0], miso};

            bitcount <= bitcount + 1;
        end

        if(bitcount == 12)
            state <= DONE;
    end

    DONE:
    begin
        cs <= 1;
        dout <= rx_shift;
        done <= 1;
        state <= IDLE;
    end

    endcase
end

endmodule
