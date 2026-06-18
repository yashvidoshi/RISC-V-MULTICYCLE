module decode_cycle_tb;

reg clk, rst;
reg regwriteW;

reg [4:0] rdW;
reg [31:0] instrD;
reg [31:0] pcD;
reg [31:0] pcplus4D;
reg [31:0] resultW;

wire regwriteE;
wire resultsrcE;
wire memwriteE;
wire branchE;
wire [2:0] alu_controlE;
wire alusrcE;

wire [31:0] RD1E;
wire [31:0] RD2E;
wire [31:0] pcE;
wire [4:0] rdE;
wire [31:0] immextE;
wire [31:0] pcplus4E;

decode_cycle uut(
    .clk(clk),
    .rst(rst),
    .instrD(instrD),
    .pcD(pcD),
    .pcplus4D(pcplus4D),
    .regwriteW(regwriteW),
    .rdW(rdW),
    .resultW(resultW),

    .regwriteE(regwriteE),
    .resultsrcE(resultsrcE),
    .memwriteE(memwriteE),
    .branchE(branchE),
    .alu_controlE(alu_controlE),
    .alusrcE(alusrcE),

    .RD1E(RD1E),
    .RD2E(RD2E),
    .pcE(pcE),
    .rdE(rdE),
    .immextE(immextE),
    .pcplus4E(pcplus4E)
);

initial begin
    clk = 1'b1;
end

always #50 clk = ~clk;

initial begin
    $dumpfile("decode_cycle.vcd");
    $dumpvars(0, decode_cycle_tb);
end

initial begin

    // Reset
    rst = 1'b0;
    regwriteW = 1'b0;
    rdW = 5'd0;
    resultW = 32'd0;

    instrD = 32'h00000013;   // addi x0,x0,0 (NOP)
    pcD = 32'h00000000;
    pcplus4D = 32'h00000004;

    #200;

    // Release reset
    rst = 1'b1;

    // Simulate writeback
    regwriteW = 1'b1;
    rdW = 5'd1;
    resultW = 32'h00000020;

    // addi x5,x0,10
    instrD = 32'h00A00293;
    pcD = 32'h00000004;
    pcplus4D = 32'h00000008;

    #100;

    // add x6,x1,x5
    instrD = 32'h00508333;
    pcD = 32'h00000008;
    pcplus4D = 32'h0000000C;

    #100;

    // lw x7,0(x1)
    instrD = 32'h0000A383;
    pcD = 32'h0000000C;
    pcplus4D = 32'h00000010;

    #100;

    // sw x7,4(x1)
    instrD = 32'h0070A223;
    pcD = 32'h00000010;
    pcplus4D = 32'h00000014;

    #300;

    $finish;
end

endmodule