module asu_gate (x, y, mode, carry, out);
input [7:0] x, y;
input mode;
output carry;
output [7:0] out;
	
/*Write your code here*/

wire carry_tmp;
wire [7:0] out_add, out_shift;

adder_gate add1 ( .out(out_add), .carry(carry_tmp),
	.x(x), .y(y) );
barrel_shifter_gate sh1 ( .out(out_shift), .in(x), .shift(y[2:0]) );

assign #2.5 out = mode? out_add : out_shift;
assign #2.5 carry = mode? carry_tmp : 1'b0;

// mux8_gate m1 ( .x(out), .a(out_shift), .b(out_add), .sel(mode) );
// and #1 a1 ( carry, carry_tmp, mode );

/*End of code*/

endmodule


/*
module mux8_gate (
input [7:0] a, b,
input sel,
output [7:0] x );

wire sel_i;
wire [7:0] wa, wb;
not #1 n0 (sel_i, sel);

genvar gi;
generate
for (gi=0; gi<8; gi=gi+1) begin
	and #1 inst_and1 (wa[gi], a[gi], sel_i);
	and #1 inst_and2 (wb[gi], b[gi], sel);
	or #1 inst_or (x[gi], wa[gi], wb[gi]);
end
endgenerate

endmodule
*/
