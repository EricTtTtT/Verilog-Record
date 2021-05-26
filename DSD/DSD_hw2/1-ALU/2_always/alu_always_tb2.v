//always block tb
`timescale 1ns/10ps
`define CYCLE	10
`define HCYCLE	5
`define INFILE "in.pattern"
`define OUTFILE "out.pattern"

module alu_always_tb;
    parameter pattern_num = 64;
    reg  [3:0] ctrl;
    reg  [7:0] x;
    reg  [7:0] y;
    wire       carry;
    wire [7:0] out;
    
    reg clk, stop;
    integer pattern_count, num, error;
    reg [8:0] ans_out, alu_out;

    reg [7:0] data_base_in [0:pattern_num*3];
    reg [8:0] data_base_ans [0:pattern_num];
    
    alu_always alu_always(
        ctrl     ,
        x        ,
        y        ,
        carry    ,
        out  
    );

    initial begin
        $readmemh(`INFILE, data_base_in );
        $readmemh(`OUTFILE, data_base_ans);
        clk = 1'b1;
        error = 0;
        stop = 0;
        pattern_count = 0;
    end
    
    always begin #(`CYCLE * 0.5) clk = ~clk; end

    initial begin
        ctrl[3:0] = data_base_in[0];
        x[7:0] = data_base_in[1];
        y[7:0] = data_base_in[2];

        for (num = 3; num < (pattern_num*3); num = num+3) begin
            @(posedge clk) begin
                ctrl[3:0] = data_base_in[num];
                x[7:0] = data_base_in[num+1];
                y[7:0] = data_base_in[num+2];
            end
        end
    end

    always@(posedge clk) begin
        pattern_count <= pattern_count + 1;
        if (pattern_count >= pattern_num)
            stop <= 1;
    end

    always@(posedge clk ) begin
        alu_out <= {carry, out};
        ans_out <= data_base_ans[pattern_count];
        if(alu_out !== ans_out)begin
            error <= error + 1;
            $display("An ERROR occurs at no.%d pattern: {carry out, output} %h != answer %h.\n", pattern_count, alu_out, ans_out);
        end
    end

    initial begin
        $fsdbDumpfile("alu_always.fsdb");
        $fsdbDumpvars;
    end

    initial begin
        @(posedge stop) begin
            if(error == 0) begin
                $display("==========================================\n");
                $display("======  Congratulation! You Pass!  =======\n");
                $display("==========================================\n");
            end
            else begin
                $display("===============================\n");
                $display("There are %d errors.", error);
                $display("===============================\n");
            end
            $finish;
        end
    end

    // initial begin
    //     ctrl = 4'b1101;
    //     x    = 8'd0;
    //     y    = 8'd0;
        
    //     #(`CYCLE);
    //     // 0100 boolean not
    //     ctrl = 4'b0100;
        
    //     #(`HCYCLE);
    //     if( out == 8'b1111_1111 ) $display( "PASS --- 0100 boolean not" );
    //     else $display( "FAIL --- 0100 boolean not" );
        
    //     // finish tb
    //     #(`CYCLE) $finish;
    // end
endmodule
