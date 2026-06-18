`include "pc.v"
`include "pcadder.v"
`include "mux.v"
`include "instruction_memory.v"
`include "alu_decoder.v"
`include "main_decoder.v"
`include "control_unit_top.v"
`include "register_file.v"
`include "sign_extend.v"
`include "alu.v"
`include "data_memory.v"
`include "branch_adder.v"

`include "fetch_cycle.v"
`include "decode_cycle.v"
`include "execute_cycle.v"
`include "memory_cycle.v"
`include "writeback_cycle.v"
`include "hazard_unit.v"
`include "mux_3by1.v"


module pipeline_top(clk,rst);

input clk, rst;

wire pcsrcE, regwriteW, regwriteE, alusrcE, memwriteE, resultsrcE, branchE,regwriteM, memwriteM, resultsrcM,resultsrcW;
wire [31:0] pctargetE, instrD, pcD, pcplus4D, resultW, RD1E, RD2E, immextE, pcplus4E, pcE,pcplus4M,writedataM,pcplus4W,aluresultW,readdataW,aluresultM;
wire [4:0] rdW, rdE, rdM, rs1E, rs2E;
wire [2:0] alu_controlE;
wire [1:0] forwardAE, forwardBE;
wire [31:0] instrE;


fetch_cycle fetchcycle(.clk(clk), .rst(rst), .pcsrcE(pcsrcE), .pctargetE(pctargetE), .instrD(instrD), .pcD(pcD), .pcplus4D(pcplus4D));

decode_cycle decodecycle(.clk(clk), .rst(rst), .instrD(instrD), .pcD(pcD), .pcplus4D(pcplus4D), .regwriteW(regwriteW), .rdW(rdW),
 .resultW(resultW), .regwriteE(regwriteE), .resultsrcE(resultsrcE), .memwriteE(memwriteE), .branchE(branchE), 
 .alu_controlE(alu_controlE), .alusrcE(alusrcE), .RD1E(RD1E), .RD2E(RD2E), .pcE(pcE), .rdE(rdE), .immextE(immextE), .pcplus4E(pcplus4E), .rs1E(rs1E), .rs2E(rs2E), .instrE(instrE));

execute_cycle executecycle(.clk(clk), .rst(rst), .regwriteE(regwriteE), .resultsrcE(resultsrcE), .memwriteE(memwriteE), 
.branchE(branchE), .alu_controlE(alu_controlE), .alusrcE(alusrcE), .RD1E(RD1E), .RD2E(RD2E), .pcE(pcE), .rdE(rdE), .immextE(immextE),
.pctargetE(pctargetE), .pcsrcE(pcsrcE), .regwriteM(regwriteM), .memwriteM(memwriteM), .resultsrcM(resultsrcM), .rdM(rdM),
.pcplus4M(pcplus4M), .writedataM(writedataM), .aluresultM(aluresultM), .pcplus4E(pcplus4E), .resultW(resultW), .forwardAE(forwardAE), .forwardBE(forwardBE));
    

memory_cycle memorycycle(.clk(clk), .rst(rst), .regwriteM(regwriteM), .memwriteM(memwriteM), .resultsrcM(resultsrcM), .rdM(rdM ), .pcplus4M(pcplus4M), .writedataM(writedataM),
 .aluresultM(aluresultM), .regwriteW(regwriteW), .resultsrcW(resultsrcW), .rdW(rdW), .pcplus4W(pcplus4W), .aluresultW(aluresultW), .readdataW(readdataW));

writeback_cycle writeback(.clk(clk), .rst(rst), .resultsrcW(resultsrcW), .readdataW(readdataW), .aluresultW(aluresultW), .pcplus4W(pcplus4W), .resultW(resultW));

hazard_unit hazardunit(.rst(rst), .regwriteM(regwriteM), .regwriteW(regwriteW), .rdM(rdM), .rdW(rdW), .rs1E(rs1E), .rs2E(rs2E), .forwardAE(forwardAE), .forwardBE(forwardBE));



endmodule