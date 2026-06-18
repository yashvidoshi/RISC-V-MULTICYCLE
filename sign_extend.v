module sign_extend(rd_instruction, immext, immsrc);
    input [31:0] rd_instruction;
    input [1:0] immsrc;
    output [31:0] immext;

    assign immext = (immsrc == 2'b00) ? {{20{rd_instruction[31]}}, rd_instruction[31:20]} :
                    (immsrc == 2'b01) ? {{20{rd_instruction[31]}}, rd_instruction[31:25], rd_instruction[11:7]} : 
                    (immsrc == 2'b10) ? {{20{rd_instruction[31]}}, rd_instruction[7], rd_instruction[30:25], rd_instruction[11:8], 1'b0} : 32'b0;

                // {{20{rd_instruction[31]}}, rd_instruction[31:25], rd_instruction[11:7]} :
                // {{20{rd_instruction[31]}}, rd_instruction[31:20]};

endmodule