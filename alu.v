module alu(A,B,control,result,zero,negative,carry,overflow);

input [31:0] A,B;
input [2:0] control;

output [31:0] result;
output zero;
output negative;
output carry;
output overflow;

wire [31:0] a_and_b;
wire [31:0] a_or_b;
wire [31:0] not_b;
wire [31:0] mux_1;
wire [31:0] sum;
wire [31:0] mux_2;
wire cout;
wire [31:0] slt;

    assign a_and_b=A&B;
    assign a_or_b=A|B;
    assign not_b=~B;
    assign mux_1=(control[0]==1'b0) ? B : not_b;
    assign {cout,sum}=A+mux_1+control[0]; //carry
    assign mux_2=(control[2:0]==3'b000) ? sum: 
                 (control[2:0]==3'b001) ? sum:
                 (control[2:0]==3'b010) ? a_and_b:
                 (control[2:0]==3'b011) ? a_or_b:
                 (control[2:0]==3'b100) ? slt: 32'h00000000;
    assign result=mux_2;
    assign slt = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;

    //flags
    assign zero=&(~result); 
    assign negative=result[31];
    assign carry=cout&(~(control[1]));
    assign overflow=(~(control[1])) & (sum[31]^A[31]) & (~(A[31]^ B[31] ^ control[0]));

endmodule