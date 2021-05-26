module adder_gate(x, y, carry, out);
input [7:0] x, y;
output carry;
output [7:0] out;

/*Write your code here*/

	wire [7:0] cout;
	fadd1 g1( .cout(cout[0]), .z(out[0]),
		  .a(x[0]), .b(y[0]), .cin(1'b0) );

	genvar gi;
	generate for (gi=1; gi<7; gi=gi+1)
	begin
		fadd1 inst_fadd(
			.cout(cout[gi]), .z(out[gi]),
			.a(x[gi]), .b(y[gi]), .cin(cout[gi-1]) );
	end
	endgenerate
	fadd1 g8( .cout(carry), .z(out[7]),
		  .a(x[7]), .b(y[7]), .cin(cout[6]) );
//	and #1 g7( carry, 1'b1, cout[7] );

/*End of code*/

endmodule


module fadd1(
	input a,
	input b,
	input cin,
	output z,
	output cout
);
	wire w1, w2, w3;

	and #1 fadd1_g1(w1, a, b);
	and #1 fadd1_g2(w2, a, cin);
	and #1 fadd1_g3(w3, b, cin);
	or #1  fadd1_g4(cout, w1, w2, w3);
	xor #1 fadd1_g5(z, a, b, cin);
//	cout = a&b | a&cin | b&cin;
//	z = a^b^cin
endmodule
