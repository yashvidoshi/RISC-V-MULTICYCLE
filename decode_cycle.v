

module decode_cycle(clk, rst, instrD, pcD, pcplus4D, regwriteW, rdW, resultW, regwriteE, resultsrcE, memwriteE, branchE, alu_controlE, alusrcE, RD1E, RD2E, pcE,rdE, immextE, pcplus4E, rs1E, rs2E, instrE);
    input clk, rst, regwriteW;
    input [4:0] rdW;
    input [31:0] instrD, pcplus4D, pcD, resultW;

    wire regwriteD, alusrcD, memwriteD, branchD, resultsrcD;
    wire [1:0] immsrcD;
    wire [2:0] alucontrolD;
    wire [31:0] RD1D, RD2D, immextD;

    reg regwriteD_reg, memwriteD_reg, branchD_reg, alusrcD_reg;
    reg  resultsrcD_reg;
    reg [2:0] alucontrolD_reg;

    reg [4:0] rs1D_reg, rs2D_reg;

    reg [31:0] RD1D_reg, RD2D_reg, immextD_reg;
    reg [4:0] rdD_reg;

    reg [31:0] pcD_reg;
    reg [31:0] pcplus4D_reg;

    reg [31:0] instrD_reg;

    output regwriteE, memwriteE, branchE, alusrcE;
    output resultsrcE;
    output [2:0] alu_controlE;
    output [4:0] rs1E, rs2E;
    output [31:0] instrE;

    output [31:0] RD1E, RD2E, pcE, immextE, pcplus4E;
    output [4:0] rdE;

    control_unit_top controlunittop_D (.op(instrD[6:0]), .funct3(instrD[14:12]), .funct7(instrD[31:25]), .zero(), .regwrite(regwriteD), .immsrc(immsrcD), .alusrc(alusrcD), .memwrite(memwriteD), .resultsrc(resultsrcD), .branch(branchD), .alu_control(alucontrolD));
    register_file registerfile_D(.A1(instrD[19:15]), .A2(instrD[24:20]), .A3(rdW), .WD3(resultW), .WE3(regwriteW), .clk(clk), .rst(rst), .RD1(RD1D), .RD2(RD2D));
    sign_extend signextend_D(.rd_instruction(instrD), .immext(immextD), .immsrc(immsrcD));

    always @(posedge clk or negedge rst) begin
        if(rst==1'b0) begin
            regwriteD_reg<=1'b0;
            resultsrcD_reg<=1'b0;
            memwriteD_reg<=1'b0;
            branchD_reg<=1'b0;
            alucontrolD_reg<=3'b000;
            alusrcD_reg<=1'b0;
            RD1D_reg<=32'h00000000;
            RD2D_reg<=32'h00000000;
            pcD_reg<=32'h00000000;
            pcplus4D_reg<=32'h00000000;
            immextD_reg<=32'h00000000;
            rdD_reg<=5'b00000;
            rs1D_reg<=5'b00000;
            rs2D_reg<=5'b00000;
            instrD_reg <= 32'h0;
        end

        else begin
            regwriteD_reg<=regwriteD;
            resultsrcD_reg<=resultsrcD;
            memwriteD_reg<=memwriteD;
            branchD_reg<=branchD;
            alucontrolD_reg<=alucontrolD;
            alusrcD_reg<=alusrcD;
            RD1D_reg<=RD1D;
            RD2D_reg<=RD2D;
            pcD_reg<=pcD;
            pcplus4D_reg<=pcplus4D;
            immextD_reg<=immextD;
            rdD_reg<=instrD[11:7];
            rs1D_reg<=instrD[19:15];
            rs2D_reg<=instrD[24:20];
            instrD_reg <= instrD;
            
            
        end
    end

    assign regwriteE = regwriteD_reg;
    assign resultsrcE = resultsrcD_reg;
    assign memwriteE = memwriteD_reg; 
    assign branchE = branchD_reg;
    assign alu_controlE = alucontrolD_reg;
    assign alusrcE = alusrcD_reg;
    assign RD1E=RD1D_reg;
    assign RD2E=RD2D_reg;
    assign pcE=pcD_reg;
    assign rdE=rdD_reg;
    assign immextE=immextD_reg;
    assign pcplus4E=pcplus4D_reg;
    assign rs1E=rs1D_reg;
    assign rs2E=rs2D_reg;
    assign instrE = instrD_reg;
    

endmodule
