

// module execute_cycle(clk,rst,regwriteE, resultsrcE, memwriteE, branchE,
//  alu_controlE, alusrcE, RD1E, RD2E, pcE,rdE, immextE,
//    pctargetE, pcsrcE, regwriteM,memwriteM,resultsrcM,rdM,
//   pcplus4M,writedataM,aluresultM,pcplus4E, resultW, forwardAE, forwardBE);
    
//     input clk,rst,regwriteE, memwriteE, branchE, alusrcE;
//     input resultsrcE;
//     input [2:0] alu_controlE;
//     input [31:0] resultW;
//     input [1:0] forwardAE, forwardBE;

//     input [31:0] RD1E, RD2E, pcE, immextE, pcplus4E;
//     input [4:0] rdE;

//     wire [31:0] srcBE, resultE, srcAE, srcBE_interim;
//     wire zeroE;

//     output pcsrcE;
//     output [31:0] pctargetE;
//     output reg regwriteM,memwriteM,resultsrcM;
//     output [4:0] rdM;
//     output [31:0] pcplus4M, aluresultM,writedataM;

//     reg regwriteE_reg, memwriteE_reg, resultsrcE_reg;
//     reg [4:0] rdE_reg;
//     reg [31:0] pcplus4E_reg, RD2E_reg, resultE_reg;

//     mux_3by1 srcae_mux(.a(RD1E), .b(resultW), .c(aluresultM), .s(forwardAE), .d(srcAE));

//     mux_3by1 srcbe_mux(.a(RD2E), .b(resultW), .c(aluresultM), .s(forwardBE), .d(srcBE_interim));

//     alu alu_E(.A(srcAE), .B(srcBE), .control(alu_controlE), .result(resultE), .zero(zeroE), .negative(), .carry(), .overflow());

//     mux mux_E(.a(srcBE_interim), .b(immextE), .s(alusrcE), .c(srcBE));

//     pcadder pcadder_E(.a(pcE), .b(immextE), .c(pctargetE));


//     always@(posedge clk or negedge rst) begin
//         if(rst==1'b0) begin
//             regwriteE_reg<=1'b0;
//             memwriteE_reg<=1'b0;
//             resultsrcE_reg<=1'b0;
//             rdE_reg<=5'b00000;
//             pcplus4E_reg<=32'h00000000;
//             RD2E_reg<=32'h00000000;
//             resultE_reg<=32'h00000000;
//         end

//         else begin
//             regwriteE_reg <= regwriteE;
//             memwriteE_reg <= memwriteE;
//             resultsrcE_reg <= resultsrcE;
//             rdE_reg <= rdE;
//             pcplus4E_reg <= pcplus4E;
//             RD2E_reg <= srcBE_interim;
//             resultE_reg <= resultE;
//         end
//     end

//     assign pcsrcE = zeroE & branchE;
//     assign regwriteM=regwriteE_reg;
//     assign memwriteM=memwriteE_reg;
//     assign resultsrcM=resultsrcE_reg;
//     assign rdM=rdE_reg;
//     assign pcplus4M=pcplus4E_reg;
//     assign writedataM=RD2E_reg;
//     assign aluresultM=resultE_reg;
// endmodule

module execute_cycle(
    clk, rst,
    regwriteE, resultsrcE, memwriteE, branchE,
    alu_controlE, alusrcE,
    RD1E, RD2E, pcE, rdE, immextE,
    pctargetE, pcsrcE,
    regwriteM, memwriteM, resultsrcM, rdM,
    pcplus4M, writedataM, aluresultM,
    pcplus4E,
    resultW,
    forwardAE, forwardBE
);

input clk, rst;
input regwriteE, memwriteE, branchE, alusrcE;
input resultsrcE;
input [2:0] alu_controlE;
input [1:0] forwardAE, forwardBE;

input [31:0] RD1E, RD2E, pcE, immextE, pcplus4E;
input [31:0] resultW;
input [4:0] rdE;

output pcsrcE;
output [31:0] pctargetE;

output reg regwriteM;
output reg memwriteM;
output reg resultsrcM;
output reg [4:0] rdM;
output reg [31:0] pcplus4M;
output reg [31:0] writedataM;
output reg [31:0] aluresultM;

wire [31:0] srcAE;
wire [31:0] srcBE_interim;
wire [31:0] srcBE;
wire [31:0] resultE;
wire zeroE;

/************ Forwarding MUXes ************/
mux_3by1 srcae_mux(
    .a(RD1E),
    .b(resultW),
    .c(aluresultM),
    .s(forwardAE),
    .d(srcAE)
);

mux_3by1 srcbe_mux(
    .a(RD2E),
    .b(resultW),
    .c(aluresultM),
    .s(forwardBE),
    .d(srcBE_interim)
);

/************ ALU Source-B MUX ************/
mux mux_E(
    .a(srcBE_interim),
    .b(immextE),
    .s(alusrcE),
    .c(srcBE)
);

/************ ALU ************/
alu alu_E(
    .A(srcAE),
    .B(srcBE),
    .control(alu_controlE),
    .result(resultE),
    .zero(zeroE),
    .negative(),
    .carry(),
    .overflow()
);

/************ Branch Target ************/
pcadder pcadder_E(
    .a(pcE),
    .b(immextE),
    .c(pctargetE)
);

/************ EX/MEM Pipeline Register ************/
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        regwriteM <= 1'b0;
        memwriteM <= 1'b0;
        resultsrcM <= 1'b0;
        rdM <= 5'b00000;
        pcplus4M <= 32'h00000000;
        writedataM <= 32'h00000000;
        aluresultM <= 32'h00000000;
    end
    else begin
        regwriteM <= regwriteE;
        memwriteM <= memwriteE;
        resultsrcM <= resultsrcE;
        rdM <= rdE;
        pcplus4M <= pcplus4E;

        // store instructions need forwarded rs2 value
        writedataM <= srcBE_interim;

        // ALU result
        aluresultM <= resultE;
    end
end

assign pcsrcE = branchE & zeroE;

endmodule