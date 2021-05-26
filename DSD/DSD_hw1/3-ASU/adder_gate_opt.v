module adder_gate(x, y, carry, out);
input [7:0] x, y;
output carry;
output [7:0] out;

/*Write your code here*/
wire c1;
CLA4 cla0 ( .sum(out[3:0]), .cout(c1),
	.a(x[3:0]), .b(y[3:0]), .cin(1'b0) );

CLA4 cla1 ( .sum(out[7:4]), .cout(carry),
	.a(x[7:4]), .b(y[7:4]), .cin(c1) );

/*End of code*/

endmodule

module CLA4 (
output [3:0] sum,
output cout,
input [3:0] a, b,
input cin );

wire [3:0] wg, wp, wc;
wire tmp1, tmp21, tmp22, tmp31, tmp32, tmp33, tmp41, tmp42, tmp43, tmp44;

assign wc[0] = cin;
	
genvar gi;
generate
for (gi=0; gi<4; gi=gi+1) begin
	and #1 inst_and ( wg[gi], a[gi], b[gi] );
	or #1 inst_or ( wp[gi], a[gi], b[gi] );
	xor #1 inst_xor ( sum[gi], a[gi], b[gi], wc[gi] );
end
endgenerate

and #1 a0 ( tmp1, wp[0], cin );
and #1 a1 ( tmp21, wp[1], wg[0] );
and #1 a2 ( tmp22, wp[1], wp[0], cin );
and #1 a3 ( tmp31, wp[2], wg[1] );
and #1 a4 ( tmp32, wp[2], wp[1], wg[0] );
and #1 a5 ( tmp33, wp[2], wp[1], wp[0], cin );
and #1 a6 ( tmp41, wp[3], wg[2] );
and #1 a7 ( tmp42, wp[3], wp[2], wg[1] );
and #1 a8 ( tmp43, wp[3], wp[2], wp[1], wg[0] );
and #1 a9 ( tmp44, wp[3], wp[2], wp[1], wp[0], cin );

or #1 o0 ( wc[1], wg[0], tmp1 );
or #1 o1 ( wc[2], wg[1], tmp21, tmp22 );
or #1 o2 ( wc[3], wg[2], tmp31, tmp32, tmp33 );
or #1 o3 ( cout, wg[3], tmp41, tmp42, tmp43, tmp44 ); 

endmodule
