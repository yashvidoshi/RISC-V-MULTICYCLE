

module writeback_cycle(clk, rst, resultsrcW, readdataW, aluresultW, pcplus4W, resultW);

input clk, rst;
input  resultsrcW;
input [31:0] readdataW, aluresultW, pcplus4W;

output [31:0] resultW;

mux mux_1W (.a(aluresultW), .b(readdataW), .s(resultsrcW), .c(resultW));

endmodule