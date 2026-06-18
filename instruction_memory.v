module instruction_memory(A,rst,RD);
    input [31:0] A;
    input rst;

    output [31:0] RD; 

    //creation of memory
    reg [31:0] mem [1023:0];

    assign RD = (rst==1'b0) ? 32'h00000000: mem[A[31:2]];

    initial begin
        $readmemh("memfile.hex",mem);
    end

    //  initial begin
    //     // mem[0]=32'hFFC4A303;
    //     // mem[1]=32'h00832383;
    //     mem[0]=32'h0064A423;
    // //     //mem[1]=32'h00B62423;
    // //     mem[0]=32'h0062E233;
    //  end

    // initial begin
    //     memory[0]=32'hFE420AE3;
    // end

endmodule