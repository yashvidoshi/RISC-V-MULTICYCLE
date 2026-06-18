module pipeline_tb;

    reg clk=0, rst;

    pipeline_top dut(clk,rst);
    always begin
        clk=~clk;
        #50;
    end

    initial begin
        rst<=1'b0;
        #200;
        rst<=1'b1;
        #1500;
        $finish;
    end

    initial begin
    $dumpfile("pipeline.vcd");
    $dumpvars;
end

endmodule