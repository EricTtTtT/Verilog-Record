`timescale 1ns/10ps
`define CYCLE  10
`define HCYCLE  5

module register_file_tb;
    // port declaration for design-under-test
    reg Clk, WEN;
    reg  [2:0] RW, RX, RY;
    reg  [7:0] busW;
    wire [7:0] busX, busY;
    
    // instantiate the design-under-test
    register_file rf(
        Clk  ,
        WEN  ,
        RW   ,
        busW ,
        RX   ,
        RY   ,
        busX ,
        busY
    );

    // write your test pattern here
    initial begin
        $fsdbDumpfile("rf.fsdb");
        $fsdbDumpvars;
    end

    always #(`HCYCLE) Clk = ~Clk;

    initial begin
        Clk = 1'b1;

        #(`CYCLE*0.2)       
        busW = 8'd123;  WEN = 1'b1;  RW = 3'd1;  RX = 3'd0; RY  = 3'd0;
        #(`CYCLE*0.8)
        #(`CYCLE*0.2)
        busW = 8'd45;  WEN = 1'b0;  RW = 3'd1;  RX = 3'd1;  RY = 3'd0;
        #(`CYCLE*0.3)
        if( busX == 123 && busY == 0) $display( "    .... passed." );
        else begin 
            $display( "    .... failed");
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)       
        busW = 8'd45;  WEN = 1'b1;  RW = 3'd2;  RX = 3'd0;  RY = 3'd0;
        #(`CYCLE*0.8)
        #(`CYCLE*0.2)
        busW = 8'd67;  WEN = 1'b0;  RW = 3'd3;  RX = 3'd2;  RY = 3'd1;
        #(`CYCLE*0.3)
        if( busY == 123 && busX == 45) $display( "    .... passed." );
        else begin 
            $display( "    .... failed");
        end
        #(`HCYCLE)

        #(`CYCLE) $finish;
    end

endmodule
