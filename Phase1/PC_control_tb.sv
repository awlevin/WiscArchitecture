
module PC_control_tb();

logic [2:0] C_tb; // ccc - condition encodings
logic [8:0] I_tb; // immediate offset
logic [2:0] F_tb; // flags (Z, V, N)
logic [15:0] PC_in_tb; 
logic [15:0] PC_out_tb;

logic clk;

enum logic [2:0] {Not_Equal=3'h0, Equal=3'h1, Greater_Than=3'h2, 
		Less_Than=3'h3, Greater_Than_Or_Equal=3'h4,
		Less_Than_Or_Equal=3'h5, Overflow=3'h6, 
		Unconditional=3'h7} ccc;

logic [8:0] imm_tb; 

// ccc	condition
// 000	Not_Equal (Z = 0)
// 001	Equal (Z = 1)
// 010	Greater_Than (Z = N = 1)
// 011	Less_Than (N = 1)
// 100	Greater_Than_Or_Equal (Z = 1 or Z = N = 0)
// 101	Less_Than_Or_Equal (N = 1 or Z = 1)
// 110	Overflow (V = 1)
// 111	Unconditional

PC_control iDUT(.C(C_tb), .I(I_tb), .F(F_tb), .PC_in(PC_in_tb), .PC_out(PC_out_tb));

initial begin
clk = 0;

imm_tb = 9'h004;

// CORRECT TESTS (when branch SHOULD be taken for each condition code)
PC_Test(Not_Equal, imm_tb, 3'b000, 16'd0); // Z = 0
PC_Test(Equal, imm_tb, 3'b010, 16'd0); // Z = 1 
PC_Test(Greater_Than, imm_tb, 3'b011, 16'd0); // Z = N = 1
PC_Test(Less_Than, imm_tb, 3'b001, 16'd0); // N = 1
PC_Test(Greater_Than_Or_Equal, imm_tb, 3'b010, 16'd0); // Z = 1
PC_Test(Greater_Than_Or_Equal, imm_tb, 3'b000, 16'd0); // Z = N = 0
PC_Test(Less_Than_Or_Equal, imm_tb, 3'b001, 16'd0); //  N = 1
PC_Test(Less_Than_Or_Equal, imm_tb, 3'b010, 16'd0); //  Z = 1
PC_Test(Overflow, imm_tb, 3'b100, 16'd0); // V = 1
PC_Test(Unconditional, imm_tb, 3'b000, 16'd0);

$stop;

end


logic Z_flag, V_flag, N_flag;
task PC_Test(logic [2:0] C, logic [8:0] I, logic [2:0] F, logic [15:0] PC_in);

logic [15:0] Expected_PC_out;
logic takeBranch;

@(posedge clk) begin

	C_tb = C;
	I_tb = I;
	F_tb = F;
	PC_in_tb = PC_in;

	Z_flag = F[2];
	V_flag = F[1];
	N_flag = F[0];
	
	takeBranch = ((C === 3'b000) && (~Z_flag)) ||
		     ((C === 3'b001) && (Z_flag)) ||
		     ((C === 3'b010) && (Z_flag) && (N_flag)) ||
		     ((C === 3'b011) && (N_flag)) ||
		     ((C === 3'b100) && (Z_flag || (~Z_flag && ~N_flag))) ||
		     ((C === 3'b101) && (N_flag || Z_flag)) ||
		     ((C === 3'b110) && (V_flag)) ||
		     (C === 3'b111);
	Expected_PC_out = (takeBranch) ? PC_in + {{7{I[8]}}, I} + 2: PC_in + 2;

end

@(negedge clk) begin
	if (PC_out_tb !== Expected_PC_out) $write("INCORRECT - ");
	else $write("CORRECT - ");

	$display("PC_out=%h, Expected_PC_out=%h, ccc=%b, N_flag=%b, Z_flag=%b, V_flag=%b", PC_out_tb, Expected_PC_out, C, N_flag, Z_flag, V_flag);
end

endtask

always #5 clk = ~clk;

endmodule
