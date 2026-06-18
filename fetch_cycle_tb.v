module fetch_cycle_tb;

reg rst, clk, pcsrcE;
reg [31:0] pctargetE;
wire [31:0] instrD, pcD, pcplus4D;

fetch_cycle uut(.clk(clk), .rst(rst), .pcsrcE(pcsrcE), .pctargetE(pctargetE), .instrD(instrD), .pcD(pcD), .pcplus4D(pcplus4D));

initial begin
    clk = 1;
end

always #50 clk = ~clk;

initial begin
    $dumpfile("fetch_cycle.vcd");
    $dumpvars;
end

initial begin
    rst<=1'b0;
    #200;
    rst<=1'b1;
    pcsrcE<=1'b0;
    pctargetE<=32'h00000000;
    #500;
    $finish;
end
endmodule