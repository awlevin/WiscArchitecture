
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Carry Look-Ahead Adder
module CLA_4bit(S, Cout, Ov, A, B, Cin);

input [3:0] A, B;
input Cin;

output [3:0] S;
output Cout, Ov;

wire [3:0] g, p, c;

assign g = A & B;
assign p = A ^ B;

assign c[0] = Cin;
assign c[1] = g[0] | (p[0] & c[0]);
assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]);

assign Cout = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) |(p[3] & p[2] & p[1] & p[0] & c[0]);

assign S = p ^ c;
assign Ov = Cout ^ c[3];

endmodule
