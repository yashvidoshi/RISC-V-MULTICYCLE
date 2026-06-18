`include "pc.v"
`include "instruction_memory.v"
`include "register_file.v"
`include "sign_extend.v"
`include "alu.v"
`include "control_unit_top.v"
`include "data_memory.v"
`include "pcadder.v"
`include "mux.v"
`include "branch_adder.v"

module single_cycle_top(rst,clk);
    input clk, rst;

    wire [31:0] pc_top, rd_instruction, RD1_top, immext_top, alu_result, read_data, pcplus4, RD2_top,srcb, mux_out, pctarget, pcnext;
    wire [2:0] alu_control_top;
    wire reg_write, mem_write, alu_src, result_src, zero, branch, pcsrc; 
    wire [1:0] imm_src;

    pc pc(.pc_next(pcnext), .pc(pc_top), .rst(rst), .clk(clk));
    
    instruction_memory instruction_memory(.A(pc_top), .rst(rst), .RD(rd_instruction));
    
    register_file reg_file(.A1(rd_instruction[19:15]), .A2(rd_instruction[24:20]), .A3(rd_instruction[11:7]), .WD3(mux_out), .WE3(reg_write), .clk(clk), .rst(rst), .RD1(RD1_top), .RD2(RD2_top));
    
    sign_extend sign_extend(.rd_instruction(rd_instruction), .immext(immext_top), .immsrc(imm_src));
    
    alu alu(.A(RD1_top),.B(srcb),.control(alu_control_top), .result(alu_result),.zero(zero),.negative(),.carry(),.overflow());
    
    control_unit_top contol_unit_top(.op(rd_instruction[6:0]), .funct3(rd_instruction[14:12]), .funct7(rd_instruction[31:25]), .zero(zero), .regwrite(reg_write), .immsrc(imm_src), .alusrc(alu_src), .memwrite(mem_write), .resultsrc(result_src), .branch(branch), .alu_control(alu_control_top));

    data_memory data_memory(.A(alu_result), .WD(RD2_top), .clk(clk), .rst(rst), .WE(mem_write),.RD(read_data));

    pcadder pcadder(.a(pc_top),.b(32'd4),.c(pcplus4));

    mux mux_register_to_alu(.a(RD2_top), .b(immext_top), .s(alu_src), .c(srcb));

    mux datamemory_to_registerfile (.a(alu_result), .b(read_data), .s(result_src), .c(mux_out));

    assign pcsrc= branch & zero;

    branch_adder branchadder (.pc(pc_top), .immext(immext_top), .pctarget(pctarget));

    mux branchadder_to_pc (.a(pcplus4), .b(pctarget), .s(pcsrc), .c(pcnext));
endmodule