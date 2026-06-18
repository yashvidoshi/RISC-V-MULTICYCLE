`timescale 1ns/1ps

module tb_main_decoder;

    reg zero;
    reg [6:0] op;

    wire regwrite;
    wire memwrite;
    wire resultsrc;
    wire alusrc;
    wire pcsrc;
    wire [1:0] immsrc;
    wire [1:0] aluop;

    main_decoder dut(
        .op(op),
        .zero(zero),
        .regwrite(regwrite),
        .memwrite(memwrite),
        .resultsrc(resultsrc),
        .alusrc(alusrc),
        .immsrc(immsrc),
        .aluop(aluop),
        .pcsrc(pcsrc)
    );

    initial begin

        //----------------------------------
        // LW
        //----------------------------------
        op = 7'b0000011;
        zero = 0;
        #10;

        if(regwrite==1 &&
           memwrite==0 &&
           resultsrc==1 &&
           alusrc==1 &&
           immsrc==2'b00 &&
           aluop==2'b00 &&
           pcsrc==0)
            $display("LW PASS");
        else
            $display("LW FAIL");


        //----------------------------------
        // SW
        //----------------------------------
        op = 7'b0100011;
        zero = 0;
        #10;

        if(regwrite==0 &&
           memwrite==1 &&
           alusrc==1 &&
           immsrc==2'b01 &&
           aluop==2'b00 &&
           pcsrc==0)
            $display("SW PASS");
        else
            $display("SW FAIL");


        //----------------------------------
        // R-TYPE
        //----------------------------------
        op = 7'b0110011;
        zero = 0;
        #10;

        if(regwrite==1 &&
           memwrite==0 &&
           resultsrc==0 &&
           alusrc==0 &&
           aluop==2'b10 &&
           pcsrc==0)
            $display("R-TYPE PASS");
        else
            $display("R-TYPE FAIL");


        //----------------------------------
        // BEQ NOT TAKEN
        //----------------------------------
        op = 7'b1100011;
        zero = 0;
        #10;

        if(regwrite==0 &&
           memwrite==0 &&
           alusrc==0 &&
           immsrc==2'b10 &&
           aluop==2'b01 &&
           pcsrc==0)
            $display("BEQ NOT TAKEN PASS");
        else
            $display("BEQ NOT TAKEN FAIL");


        //----------------------------------
        // BEQ TAKEN
        //----------------------------------
        op = 7'b1100011;
        zero = 1;
        #10;

        if(pcsrc==1)
            $display("BEQ TAKEN PASS");
        else
            $display("BEQ TAKEN FAIL");

        $finish;

    end

endmodule