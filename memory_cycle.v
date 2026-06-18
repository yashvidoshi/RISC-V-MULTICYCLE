
module memory_cycle(clk, rst, regwriteM, memwriteM, resultsrcM, rdM, pcplus4M, writedataM, aluresultM,
regwriteW, resultsrcW, rdW, pcplus4W, aluresultW, readdataW);

    input clk, rst, regwriteM,memwriteM;
    input  resultsrcM;
    input [4:0] rdM;
    input [31:0] pcplus4M, aluresultM, writedataM;

    wire [31:0] readdataM;

    reg regwriteM_reg;
    reg  resultsrcM_reg;
    reg [4:0] rdM_reg;
    reg [31:0] pcplus4M_reg, aluresultM_reg, readdataM_reg;

    output regwriteW;
    output resultsrcW;
    output [4:0] rdW;
    output [31:0] aluresultW, readdataW, pcplus4W;


    data_memory data_memory_M(.A(aluresultM), .WD(writedataM), .clk(clk), .rst(rst), .WE(memwriteM), .RD(readdataM));

    always @(posedge clk or negedge rst) begin
        if(rst==1'b0) begin
            regwriteM_reg<=1'b0;
            resultsrcM_reg<=1'b0;
            rdM_reg<=5'b00000;
            pcplus4M_reg<=32'h00000000;
            aluresultM_reg<=32'h00000000;
            readdataM_reg<=32'h00000000;
        end

        else begin
            regwriteM_reg<=regwriteM;
            resultsrcM_reg<=resultsrcM;
            rdM_reg<=rdM;
            pcplus4M_reg<=pcplus4M;
            aluresultM_reg<=aluresultM;
            readdataM_reg<=readdataM;
        end
    end

    assign regwriteW=regwriteM_reg;
    assign resultsrcW= resultsrcM_reg;
    assign rdW=rdM_reg;
    assign pcplus4W=pcplus4M_reg;
    assign aluresultW=aluresultM_reg;
    assign readdataW=readdataM_reg;

endmodule