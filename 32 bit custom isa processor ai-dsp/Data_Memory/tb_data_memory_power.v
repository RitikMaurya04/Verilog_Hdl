`timescale 1ns/1ps

module tb_data_memory_power;

    reg        clk;
    reg [31:0] addr;
    reg [31:0] wdata;
    reg        memwrite;
    reg        memread;
    wire [31:0] rdata;

    // DUT
    data_memory dut (
        .clk      (clk),
        .addr     (addr),
        .wdata    (wdata),
        .memwrite (memwrite),
        .memread  (memread),
        .rdata    (rdata)
    );

    // 10 ns clock
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // One store operation.
    task do_store;
        input [31:0] a;
        input [31:0] d;
        begin
            @(negedge clk);
            addr     = a;
            wdata    = d;
            memwrite = 1'b1;
            memread  = 1'b0;

            @(negedge clk);
            memwrite = 1'b0;
        end
    endtask

    // One load operation.
    task do_load;
        input [31:0] a;
        begin
            @(negedge clk);
            addr     = a;
            wdata    = 32'b0;
            memwrite = 1'b0;
            memread  = 1'b1;

            @(negedge clk);
            memread = 1'b0;
        end
    endtask

    // Idle cycle: no memory operation.
    task do_idle;
        begin
            @(negedge clk);
            addr     = 32'b0;
            wdata    = 32'b0;
            memwrite = 1'b0;
            memread  = 1'b0;
        end
    endtask

    integer i;

    initial begin
        // VCD for OpenSTA power analysis
        $dumpfile("data_memory_workload.vcd");
        $dumpvars(0, tb_data_memory_power);

        // Initial values
        addr     = 32'b0;
        wdata    = 32'b0;
        memwrite = 1'b0;
        memread  = 1'b0;

        // ------------------------------------------------------------
        // Phase 1: Initialize memory locations with stores
        // ------------------------------------------------------------
        do_store(32'd0,   32'd10);
        do_store(32'd4,   32'd20);
        do_store(32'd8,   32'd30);
        do_store(32'd12,  32'd40);
        do_store(32'd16,  32'd50);
        do_store(32'd20,  32'd60);
        do_store(32'd24,  32'd70);
        do_store(32'd28,  32'd80);
        do_store(32'd32,  32'd90);
        do_store(32'd36,  32'd100);
        do_store(32'd40,  32'd110);
        do_store(32'd44,  32'd120);
        do_store(32'd48,  32'd130);
        do_store(32'd52,  32'd140);
        do_store(32'd56,  32'd150);
        do_store(32'd60,  32'd160);

        // ------------------------------------------------------------
        // Phase 2: Sequential reads
        // Exercises changing read addresses.
        // ------------------------------------------------------------
        do_load(32'd0);
        do_load(32'd4);
        do_load(32'd8);
        do_load(32'd12);
        do_load(32'd16);
        do_load(32'd20);
        do_load(32'd24);
        do_load(32'd28);
        do_load(32'd32);
        do_load(32'd36);
        do_load(32'd40);
        do_load(32'd44);
        do_load(32'd48);
        do_load(32'd52);
        do_load(32'd56);
        do_load(32'd60);

        // ------------------------------------------------------------
        // Phase 3: Repeated reads
        // Models repeated load activity and gives the power tool
        // meaningful switching activity.
        // ------------------------------------------------------------
        for (i = 0; i < 10; i = i + 1) begin
            do_load(32'd0);
            do_load(32'd16);
            do_load(32'd32);
            do_load(32'd48);
        end

        // ------------------------------------------------------------
        // Phase 4: Mixed store/load activity
        // ------------------------------------------------------------
        do_store(32'd0,  32'd1000);
        do_load (32'd0);

        do_store(32'd16, 32'd2000);
        do_load (32'd16);

        do_store(32'd32, 32'd3000);
        do_load (32'd32);

        do_store(32'd48, 32'd4000);
        do_load (32'd48);

        do_store(32'd4,  32'd1111);
        do_load (32'd4);

        do_store(32'd20, 32'd2222);
        do_load (32'd20);

        do_store(32'd36, 32'd3333);
        do_load (32'd36);

        do_store(32'd52, 32'd4444);
        do_load (32'd52);

        // ------------------------------------------------------------
        // Phase 5: Idle cycles
        // Represents processor cycles in which memory is not accessed.
        // ------------------------------------------------------------
        for (i = 0; i < 20; i = i + 1)
            do_idle;

        // ------------------------------------------------------------
        // Phase 6: Randomized-style address activity
        // Uses deterministic addresses so the workload is reproducible.
        // ------------------------------------------------------------
        do_load(32'd60);
        do_load(32'd12);
        do_load(32'd44);
        do_load(32'd8);
        do_load(32'd52);
        do_load(32'd24);
        do_load(32'd40);
        do_load(32'd4);
        do_load(32'd56);
        do_load(32'd20);
        do_load(32'd36);
        do_load(32'd0);
        do_load(32'd48);
        do_load(32'd16);
        do_load(32'd32);
        do_load(32'd28);

        // ------------------------------------------------------------
        // Phase 7: Additional mixed activity
        // ------------------------------------------------------------
        for (i = 0; i < 8; i = i + 1) begin
            do_store(32'd8,  32'd5000 + i);
            do_load (32'd8);

            do_store(32'd24, 32'd6000 + i);
            do_load (32'd24);

            do_store(32'd40, 32'd7000 + i);
            do_load (32'd40);

            do_store(32'd56, 32'd8000 + i);
            do_load (32'd56);
        end

        // Final idle period
        for (i = 0; i < 10; i = i + 1)
            do_idle;

        $display("Data memory power-analysis workload completed.");
        $finish;
    end

endmodule
