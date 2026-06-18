module register_file(A1, A2, A3, WD3, WE3, clk, rst, RD1, RD2);
    input clk, rst;
    input [4:0] A1, A2, A3;
    input [31:0] WD3;
    input WE3;

    output [31:0] RD1, RD2;
    
    //creation of memory
    reg [31:0] register [0:31];

    //read functionality
    assign RD1 = (A1 == 5'd0) ? 32'b0 : register[A1];
    assign RD2 = (A2 == 5'd0) ? 32'b0 : register[A2];

    //write functionality
    always @(posedge clk) begin
        if(WE3 && (A3!=5'd0)) begin
            register[A3]<=WD3;
        end
    end

    // initial begin
    //     // register[9]=32'h00000020;
    //     // register[6]=32'h00000040;
    //     // register[5]=32'h00000005;
    //     // register[6]=32'h00000004;
    //     // register[4]=32'd14;
    //     // register[0]

    //     register[1] = 32'h00000020;   // x1
    //     register[5] = 32'h00000005;   // x5
    //     register[6] = 32'h00000004;   // x6
    //     register[7] = 32'h00000010;   // x7
        
        
    // end

    integer i;

    initial begin
        for(i=0;i<32;i=i+1)
            register[i] = 32'b0;

        register[1] = 32'h20;
        register[5] = 32'h5;
        register[6] = 32'h4;
        register[7] = 32'h10;
    end
    
endmodule