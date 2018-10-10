
module PC_control_tb();

logic [2:0] C; // ccc - condition encodings
logic [8:0] I; // immediate offset
logic [2:0] F; // flags (N, Z, V)
logic [15:0] PC_in; 
logic [15:0] PC_out;

PC_control iDUT(.C(C), .I(I), .F(F), .PC_in(PC_in), .PC_out(PC_out));

initial begin

C = 3'b0;
I = 9'b0;
F = 3'b0;
PC_in = 16'b0;

$stop;

end

endmodule
