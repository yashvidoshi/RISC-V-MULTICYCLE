
module fetch_cycle(clk, rst, pcsrcE, pctargetE, instrD, pcD, pcplus4D);
    input clk, rst, pcsrcE;
    input [31:0] pctargetE;
    output [31:0] instrD, pcD, pcplus4D;
    wire [31:0] pcbarF;
    wire [31:0] pcF, pcplus4F, instrF;

    reg [31:0] instrF_reg, pcF_reg, pcplus4F_reg;

    mux pc_mux_F (.a(pcplus4F), .b(pctargetE), .s(pcsrcE), .c(pcbarF));

    pc pc_F (.pc_next(pcbarF), .pc(pcF), .rst(rst), .clk(clk));

    instruction_memory instructionmemory_F (.A(pcF), .rst(rst), .RD(instrF));

    pcadder pcadder_F (.a(pcF), .b(32'd4), .c(pcplus4F));
 
    //fetch cycle register logic
    always@(posedge clk or negedge rst) begin
        if(rst==1'b0) begin
            instrF_reg<=32'h00000000;
            pcF_reg<=32'h00000000;
            pcplus4F_reg<=32'h00000000;
        end

        else begin
            instrF_reg<=instrF;
            pcF_reg<=pcF;
            pcplus4F_reg<=pcplus4F;
        end 
    end

    //assigning registers value to the output port
    assign instrD = (rst==1'b0) ? 32'h00000000 : instrF_reg;
    assign pcD= (rst==1'b0) ? 32'h00000000 : pcF_reg;
    assign pcplus4D = (rst==1'b0) ? 32'h00000000 : pcplus4F_reg;
endmodule