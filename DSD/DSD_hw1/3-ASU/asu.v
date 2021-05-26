module asu (x, y, mode, carry, out);
input [7:0] x, y;
input mode;
output carry;
output [7:0] out;

/*Write your code here*/

wire [7:0] out_add, out_shift;
wire tmp_carry;
barrel_shifter sh1 ( .out(out_shift), .in(x), .shift(y[2:0]) );
adder a1 ( .out(out_add), .carry(tmp_carry), .x(x), .y(y) );

assign out = mode? out_add : out_shift;
assign carry = mode? tmp_carry : 1'b0;

/*End of code*/

endmodule
