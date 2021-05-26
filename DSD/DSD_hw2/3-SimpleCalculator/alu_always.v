/*======================
Author: Eric Tien
Module: ALU
Description: 
    Use continuous assignment to implement the 8-bit ALU.
======================*/

//RT level (event-driven)
module alu_always(
    ctrl,
    x,
    y,
    carry,
    out 
);
    
    input  [3:0] ctrl;
    input signed [7:0] x;
    input signed [7:0] y;
    output reg carry;
    output [7:0] out;
    
    reg [8:0] pre_out;
    
    assign out = pre_out[7:0];

    always @(*) begin    
        case (ctrl)
            4'b0000: pre_out = (x + y);
            4'b0001: pre_out = (x - y);
            4'b0010: pre_out = x & y;
            4'b0011: pre_out = x | y;
            4'b0100: pre_out = ~x;
            4'b0101: pre_out = x ^ y;
            4'b0110: pre_out = ~(x | y);
            4'b0111: pre_out = y <<< x[2:0];
            4'b1000: pre_out = y >>> x[2:0];
            4'b1001: pre_out = {x[7], x[7:1]};
            4'b1010: pre_out = {x[6:0], x[7]};
            4'b1011: pre_out = {x[0], x[7:1]};
            4'b1100: pre_out = x==y? 1 : 0;
            4'b1101: pre_out = 0;
            4'b1110: pre_out = 0;
            4'b1111: pre_out = 0;
            default: pre_out=0;
        endcase
        
        casez (ctrl)
            4'b000z: carry = pre_out[8];
            default: carry = 0;
        endcase

    end

endmodule
