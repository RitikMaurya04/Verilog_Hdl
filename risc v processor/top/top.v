// Code your design here
module top (
    input clk,
    input rst
);

    //==========================================================
    // PC / Instruction
    //==========================================================

    wire [31:0] pc;
    wire [31:0] next_pc;
    wire [31:0] instruction;

    wire [4:0] opcode;
    wire [4:0] func;
    wire [6:0] func_r;
    wire [4:0] func_i;

    assign opcode = instruction[4:0];
    assign func   = instruction[31:27];

    // Function fields for ALU control
    assign func_r = instruction[31:25];
    assign func_i = instruction[31:27];


    //==========================================================
    // Register addresses
    //==========================================================

    wire [4:0] raddr1;
    wire [4:0] raddr2;
    wire [4:0] raddr3;

    wire [4:0] waddr1;
    wire [4:0] waddr2;

    assign raddr1 = instruction[14:10];
    assign raddr2 = instruction[19:15];
    assign raddr3 = instruction[24:20];

    assign waddr1 = instruction[9:5];
    assign waddr2 = instruction[19:15];


    //==========================================================
    // Register file data
    //==========================================================

    wire [31:0] rdata1;
    wire [31:0] rdata2;
    wire [31:0] rdata3;

    wire [31:0] write_data;


    //==========================================================
    // Decoder controls
    //==========================================================

    wire [3:0] aluop;

    wire regwrite1;
    wire regwrite2;

    wire regread1;
    wire regread2;
    wire regread3;

    wire memwrite;
    wire memread;

    wire Aluenable;

    wire alumuxen1;
    wire alumuxsel1;

    wire resulten;
    wire [1:0] resultsel;

    wire [2:0] ImmType;
    wire [1:0] ImmMode;
    wire ImmEnable;


    //==========================================================
    // Branch controls
    //==========================================================

    wire branch;
    wire branchrs1;
    wire branchrs2;
    wire [4:0] branchtype;
    wire branch_taken;


    //==========================================================
    // Jump controls
    //==========================================================

    wire jump;
    wire jalr;
    wire link;


    //==========================================================
    // Immediate
    //==========================================================

    wire [31:0] imm_out;


    //==========================================================
    // ALU operand MUX
    //==========================================================

    wire [31:0] muxout;


    //==========================================================
    // ALU control
    //==========================================================

    wire [1:0] alu_mode;
    wire [4:0] alu_control;

    wire alu_enA;
    wire alu_enB;
    wire alu_enC;


    //==========================================================
    // ALU
    //==========================================================

    wire [31:0] alu_result;


    //==========================================================
    // Data memory
    //==========================================================

    wire [31:0] mem_rdata;


    //==========================================================
    // PC control
    //==========================================================

    wire [31:0] pc_plus4_out;


    //==========================================================
    // Program Counter
    //==========================================================

    program_counter pc_reg (
        .clk       (clk),
        .rst       (rst),
        .pcinst    (next_pc),
        .pcoutinst (pc)
    );


    //==========================================================
    // Instruction Memory
    //==========================================================

    instruction_memory imem (
        .ren  (1'b1),
        .addr (pc),
        .data (instruction)
    );


    //==========================================================
    // Main Decoder
    //==========================================================

    main_decoder decoder (
        .opcode     (opcode),
        .func       (func),

        .aluop      (aluop),

        .regwrite1  (regwrite1),
        .regwrite2  (regwrite2),

        .regread1   (regread1),
        .regread2   (regread2),
        .regread3   (regread3),

        .memwrite   (memwrite),
        .memread    (memread),

        .Aluenable  (Aluenable),

        .alumuxen1  (alumuxen1),
        .alumuxsel1 (alumuxsel1),

        .resulten   (resulten),
        .resultsel  (resultsel),

        .ImmType    (ImmType),
        .ImmMode    (ImmMode),
        .ImmEnable  (ImmEnable),

        .branch     (branch),
        .branchrs1  (branchrs1),
        .branchrs2  (branchrs2),
        .branchtype (branchtype),

        .jump       (jump),
        .jalr       (jalr),
        .link       (link)
    );


    //==========================================================
    // Register File
    //==========================================================

    register_fileen rf (
        .clk       (clk),
        .rst       (rst),

        .regwrite1 (regwrite1),
        .regwrite2 (regwrite2),

        .regread1  (regread1),
        .regread2  (regread2),
        .regread3  (regread3),

        .raddr1    (raddr1),
        .raddr2    (raddr2),
        .raddr3    (raddr3),

        .waddr1    (waddr1),
        .waddr2    (waddr2),

        .wdata1    (write_data),
        .wdata2    (rdata3),

        .rdata1    (rdata1),
        .rdata2    (rdata2),
        .rdata3    (rdata3)
    );


    //==========================================================
    // Immediate Generator
    //==========================================================

    immext imm_unit (
        .instruction (instruction),
        .ImmEnable   (ImmEnable),
        .ImmType     (ImmType),
        .ImmMode     (ImmMode),
        .Out         (imm_out)
    );


    //==========================================================
    // ALU Operand MUX
    //==========================================================

    mux_1 alu_mux (
        .SrcC        (rdata3),
        .IMM         (imm_out),
        .alumuxsel1  (alumuxsel1),
        .alumuxen1   (alumuxen1),
        .out         (muxout)
    );


    //==========================================================
    // ALU Control
    //==========================================================

    alu_control alu_ctrl (
        .aluop      (aluop),
        .func_r     (func_r),
        .func_i     (func_i),
        .AluEnable  (Aluenable),

        .mode       (alu_mode),
        .control    (alu_control),

        .alu_enA    (alu_enA),
        .alu_enB    (alu_enB),
        .alu_enC    (alu_enC)
    );


    //==========================================================
    // ALU
    //==========================================================

    alu_ai alu (
        .A          (rdata1),
        .B          (rdata2),
        .C          (muxout),

        .ALUEnable  (Aluenable),

        .alu_enA    (alu_enA),
        .alu_enB    (alu_enB),
        .alu_enC    (alu_enC),

        .alucontrol (alu_control),
        .mode       (alu_mode),

        .Result     (alu_result),
        .zero       ()
    );
  


    //==========================================================
    // Data Memory
    //==========================================================

    data_memory dmem (
        .clk      (clk),
        .addr    (alu_result),
       
        .wdata    (rdata2),
        .memwrite (memwrite),
        .memread  (memread),
        .rdata    (mem_rdata)
    );
    
   //==========================================================
    // Result / Writeback MUX
    //==========================================================

    resultmux result_mux (
        .Result     (alu_result),
        .RData1     (mem_rdata),
        .Regdata1   (rdata1),
        .pc_4       (pc_plus4_out),

        .resultsel  (resultsel),
        .resulten   (resulten),

        .out1       (write_data)
    );


    //==========================================================
    // Branch Unit
    //==========================================================

    branch_unit branch_u (
        .branch       (branch),
        .branchrs1    (branchrs1),
        .branchrs2    (branchrs2),

        .rdata1       (rdata1),
        .rdata2       (rdata2),

        .branchtype   (branchtype),

        .branch_taken (branch_taken)
    );


    //==========================================================
    // PC Control
    //==========================================================

    pc_control pc_ctrl (
        .pc           (pc),
        .imm          (imm_out),
        .rdata1       (rdata1),

        .branch       (branch),
        .branch_taken (branch_taken),

        .jump         (jump),
        .jalr         (jalr),
        .link         (link),

        .next_pc      (next_pc),
        .pc_plus4_out (pc_plus4_out)
    );


    
endmodule