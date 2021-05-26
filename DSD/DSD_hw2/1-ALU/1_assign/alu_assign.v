/*======================
Author: Eric Tien
Module: ALU
Description: 
    Use continuous assignment to implement the 8-bit ALU.
======================*/

//RTL (use continuous assignment)
module alu_assign(
    ctrl,
    x,
    y,
    carry,
    out  
);
    
    input  [3:0] ctrl;
    input  signed [7:0] x;
    input  signed [7:0] y;
    output       carry;
    output signed [7:0] out;

    wire signed [8:0] pre_out;
    assign out = pre_out[7:0];
    assign carry = pre_out[8];

    assign pre_out = ctrl[3]?
        ctrl[2]?
            ctrl[1]?
                0
            :
                ctrl[0]?  0 : x==y? 1:0
        :
            ctrl[1]?
                ctrl[0]?  {x[0], x[7:1]} : {x[6:0], x[7]}
            :
                ctrl[0]?  {x[7], x[7:1]} : y >> x[2:0]
        :
        ctrl[2]?
            ctrl[1]?
                ctrl[0]?  y << x[2:0] : ~(x | y)
            :
                ctrl[0]?  x ^ y : ~x
        : ctrl[1]?
                ctrl[0]?  x | y : x & y
            :
                ctrl[0]?  x - y : x + y;


endmodule
