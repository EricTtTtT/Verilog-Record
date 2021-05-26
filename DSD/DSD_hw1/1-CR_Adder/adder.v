module adder(x, y, carry, out);
input [7:0] x, y;
output carry;
output reg [7:0] out;

/*Write your code here*/

reg [7:0] cout;	


integer i;
always @(*) begin
	out[0] = x[0] ^ y[0];
	cout[0] = x[0] & y[0];
	for (i=1; i<8; i=i+1) begin
		cout[i] = (x[i]&y[i]) | (x[i]&cout[i-1]) | (y[i]&cout[i-1]);
		out[i] = x[i] ^ y[i] ^ cout[i-1];
	end
end
assign carry = cout[7];

/*End of code*/

endmodule
