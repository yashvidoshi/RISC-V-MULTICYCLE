

module control_unit_top(op, funct3, funct7, zero, regwrite, immsrc, alusrc, memwrite, resultsrc, branch, alu_control);

input [6:0] op, funct7;
input [2:0] funct3;
input zero;

output regwrite, alusrc, memwrite, resultsrc, branch;
output [1:0] immsrc;
output[2:0] alu_control;

wire [1:0] aluop; 

main_decoder decoder1(.op(op), .regwrite(regwrite), .memwrite(memwrite), .resultsrc(resultsrc), .alusrc(alusrc), .immsrc(immsrc), .aluop(aluop), .branch(branch));
alu_decoder decoder2(.aluop(aluop), .op(op), .funct3(funct3), .funct7(funct7), .alucontrol(alu_control));
endmodule