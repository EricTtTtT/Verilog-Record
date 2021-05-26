module barrel_shifter_gate(in, shift, out);
input  [7:0] in;
input [2:0] shift;
output [7:0] out;

/*Write your code here*/

wire [7:0] out_1, out_2;

	level1 l1 ( .out(out_1), .in(in), .shift(shift[0]) );
	level2 l2 ( .out(out_2), .in(out_1), .shift(shift[1] ) );
	level4 l4 ( .out(out), .in(out_2), .shift(shift[2]) );

/*End of code*/
endmodule

module mux (x,a,b,sel);
input 	a,b,sel;
output 	x;
wire sel_i,w1,w2;

not #1 n0(sel_i,sel);
and #1 a1(w1,a,sel_i);
and #1 a2(w2,b,sel);
or #1  o1(x,w1,w2);
	
endmodule

module level1 (
	input [7:0] in,
	input shift,
	input [7:0] out
);

mux g1( .x(out[0]), .a(in[0]), .b(1'b0), .sel(shift) );
genvar gi;
generate
	for (gi=1; gi<8; gi=gi+1)
	begin
		mux inst_mux( .x(out[gi]), .a(in[gi]), .b(in[gi-1]), .sel(shift) );
	end
endgenerate

endmodule



module level2 (
	input [7:0] in,
	input shift,
	input [7:0] out
);

mux g0( .x(out[0]), .a(in[0]), .b(1'b0), .sel(shift) );
mux g1( .x(out[1]), .a(in[1]), .b(1'b0), .sel(shift) );

genvar gi;
generate
	for (gi=2; gi<8; gi=gi+1)
	begin
		mux inst_mux( .x(out[gi]), .a(in[gi]), .b(in[gi-2]), .sel(shift) );
	end
endgenerate

endmodule


module level4 (
	input [7:0] in,
	input shift,
	input [7:0] out
);

mux g0( .x(out[0]), .a(in[0]), .b(1'b0), .sel(shift) );
mux g1( .x(out[1]), .a(in[1]), .b(1'b0), .sel(shift) );
mux g2( .x(out[2]), .a(in[2]), .b(1'b0), .sel(shift) );
mux g3( .x(out[3]), .a(in[3]), .b(1'b0), .sel(shift) );

genvar gi;
generate
	for (gi=4; gi<8; gi=gi+1)
	begin
		mux inst_mux( .x(out[gi]), .a(in[gi]), .b(in[gi-4]), .sel(shift) );
	end
endgenerate

endmodule
