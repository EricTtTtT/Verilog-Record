/*======================
Author: Eric Tien
Module: Registers File
Description: 
    Use continuous assignment to implement the 8-bit ALU.
======================*/

module register_file(
    Clk  ,
    WEN  ,
    RW   ,
    busW ,
    RX   ,
    RY   ,
    busX ,
    busY
);
input        Clk, WEN;
input  [2:0] RW, RX, RY;
input  [7:0] busW;
output reg [7:0] busX, busY;
    
// write your design here, you can delcare your own wires and regs. 
// The code below is just an eaxmple template
reg [7:0] r0_w, r1_w, r2_w, r3_w, r4_w, r5_w, r6_w, r7_w;
reg [7:0] r0_r, r1_r, r2_r, r3_r, r4_r, r5_r, r6_r, r7_r;


// Combinational
always@(*) begin
    r0_r = 0;
    r0_w = 0;
    case (RX)
        3'h0 : busX = r0_w;
        3'h1 : busX = r1_w;
        3'h2 : busX = r2_w;
        3'h3 : busX = r3_w;
        3'h4 : busX = r4_w;
        3'h5 : busX = r5_w;
        3'h6 : busX = r6_w;
        3'h7 : busX = r7_w;
        default: busX = 0;
    endcase

    case (RY)
        3'h0 : busY = r0_w;
        3'h1 : busY = r1_w;
        3'h2 : busY = r2_w;
        3'h3 : busY = r3_w;
        3'h4 : busY = r4_w;
        3'h5 : busY = r5_w;
        3'h6 : busY = r6_w;
        3'h7 : busY = r7_w;
        default: busY = 0;
    endcase
end

// Sequential
always@(posedge Clk) begin
    if (WEN==1) begin
        case (RW)
            3'h0 : r0_w <= busW;
            3'h1 : r1_w <= busW;
            3'h2 : r2_w <= busW;
            3'h3 : r3_w <= busW;
            3'h4 : r4_w <= busW;
            3'h5 : r5_w <= busW;
            3'h6 : r6_w <= busW;
            3'h7 : r7_w <= busW;
            default: r0_w <= 0;
        endcase    
    end
end	

endmodule
