        // Read output disabled
        // ----------------------------------
        ren = 0;

        repeat (100) begin
            @(negedge clk);
            raddr = raddr + 4;
        end

        // ----------------------------------
        // Mixed activity
        // ----------------------------------
        repeat (100) begin
            @(negedge clk);

            raddr = raddr + 8;
            ren   = ~ren;
        end

        #20;
        $finish;

    end

endmodule
