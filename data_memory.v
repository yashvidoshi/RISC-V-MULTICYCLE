module data_memory(A, WD, clk, rst, WE,RD);

    input [31:0] A,WD;
    input clk, rst, WE;

    output [31:0] RD;

    reg [31:0] data_mem [1023:0];

    //read
    assign RD=(WE==1'b0) ? data_mem[A] : 32'h00000000;

    //write
    always @(posedge clk) begin
        if(WE) begin
            data_mem[A]<=WD;
        end
    end

    // initial begin
    //     data_mem[28]=32'h00000020;
    //     data_mem[40]=32'h00000002;
    // end

    integer i;

    initial begin
        for(i=0;i<1024;i=i+1)
            data_mem[i] = 32'b0;

        data_mem[0] = 32'h00000020;
    end

endmodule