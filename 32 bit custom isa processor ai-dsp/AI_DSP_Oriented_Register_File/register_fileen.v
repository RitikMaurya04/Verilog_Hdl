module register_fileen (

    // Clock and Reset
    input  clk,
    input  rst,

    // Write Enable Signals
    input  regwrite1,
    input  regwrite2,

    // Read Enable Signals
    input  regread1,
    input  regread2,
    input  regread3,

    // Read Addresses
    input  [4:0] raddr1,
    input  [4:0] raddr2,
    input  [4:0] raddr3,

    // Write Addresses
    input  [4:0] waddr1,
    input  [4:0] waddr2,

    // Write Data
    input  [31:0] wdata1,
    input  [31:0] wdata2,

    // Read Data
    output reg [31:0] rdata1,
    output reg [31:0] rdata2,
    output reg [31:0] rdata3

);

    //========================================================
    // Register Storage
    //========================================================

    reg [31:0] regis [0:31];

    integer i;


    //========================================================
    // Sequential Logic
    //
    // - Asynchronous Reset
    // - Two Synchronous Write Ports
    // - Write Port 1 has priority during conflicts
    //========================================================

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            for (i = 0; i < 32; i = i + 1)
                regis[i] <= 32'd0;

        end

        else begin

            // Write Port 1
            if (regwrite1 && (waddr1 != 5'd0))
                regis[waddr1] <= wdata1;

            // Write Port 2
            // Port 1 has priority if both target same register
            if (regwrite2 &&
                (waddr2 != 5'd0) &&
                !(regwrite1 && (waddr1 == waddr2)))
                regis[waddr2] <= wdata2;

        end

    end


    //========================================================
    // Combinational Read Logic
    //
    // Three asynchronous read ports
    //
    // Read enable = 0 --> output forced to zero
    // Read enable = 1 --> normal register-file read
    // x0 always returns zero
    //========================================================

    always @(*) begin

        if (regread1)
            rdata1 = (raddr1 == 5'd0) ? 32'd0 : regis[raddr1];
        else
            rdata1 = 32'd0;

        if (regread2)
            rdata2 = (raddr2 == 5'd0) ? 32'd0 : regis[raddr2];
        else
            rdata2 = 32'd0;

        if (regread3)
            rdata3 = (raddr3 == 5'd0) ? 32'd0 : regis[raddr3];
        else
            rdata3 = 32'd0;

    end

endmodule