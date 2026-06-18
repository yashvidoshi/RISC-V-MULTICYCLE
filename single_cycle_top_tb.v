module single_cycle_top_tb;
reg clk=1'b1,rst;

single_cycle_top dut (.rst(rst), .clk(clk));

initial begin
    $dumpfile("single_cycle.vcd");
    $dumpvars;
end

initial begin
    clk = 0;
end

always #50 clk = ~clk;

initial begin
    rst=1'b0;
    #100;

    rst=1'b1;
    #300;
    $finish;
end

// initial begin
//     #250;
//     $display("x6 = %h", dut.reg_file.register[6]);
// end

// always @(posedge clk)
// begin
//     $display("--------------------------------");
//     $display("PC       = %h", dut.pc_top);
//     $display("Instr    = %h", dut.rd_instruction);
//     $display("Branch   = %b", dut.branch);
//     $display("Zero     = %b", dut.zero);
//     $display("PCSrc    = %b", dut.pcsrc);
//     $display("ImmExt   = %h", dut.immext_top);
//     $display("PCTarget = %h", dut.pctarget);
// end

endmodule