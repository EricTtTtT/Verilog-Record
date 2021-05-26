/*======================
Author: Eric Tien
Module: Simple Calculator
Description: 
    Combine ALU and registers_file into a simple calculator unit.
======================*/

module simple_calculator(
    Clk,
    WEN,
    RW,
    RX,
    RY,
    DataIn,
    Sel,
    Ctrl,
    busY,
    Carry
);

    input        Clk;
    input        WEN;
    input  [2:0] RW, RX, RY;
    input  [7:0] DataIn;
    input        Sel;
    input  [3:0] Ctrl;
    output [7:0] busY;
    output      Carry;

// declaration of wire/reg
wire [7:0] wire_X, wire_ALU;
reg [7:0] reg_Mux;
// submodule instantiation
alu_always inst_alu ( .carry(carry), .out(wire_ALU),
    .x(reg_Mux), .y(busY), .ctrl(Ctrl) );

register_file inst_reg_files ( .busX(wire_X), .busY(busY),
    .busW(wire_ALU), .RW(RW), .RX(RX), .RY(RY), .Clk(Clk), .WEN(WEN) );

always @(*) begin
    reg_Mux = Sel? wire_X : DataIn;
end


endmodule