
module PC_control_tb();

logic [2:0] C_dut; // ccc - condition encodings
logic [8:0] I_dut; // immediate offset
logic [2:0] F_dut; // flags (Z, V, N)
logic [15:0] PC_in_dut; 
logic [15:0] BR_dut;
logic [15:0] PC_out_dut;

logic clk;

logic Z_flag, V_flag, N_flag;

enum logic [2:0] {Not_Equal=3'h0, Equal=3'h1, Greater_Than=3'h2, 
		Less_Than=3'h3, Greater_Than_Or_Equal=3'h4,
		Less_Than_Or_Equal=3'h5, Overflow=3'h6, 
		Unconditional=3'h7} ccc;

//Test Bench variables
logic [8:0] imm_tb; 
logic [15:0] PC_tb;
logic [15:0] BR_tb;

// ccc	condition
// 000	Not_Equal (Z = 0)
// 001	Equal (Z = 1)
// 010	Greater_Than (Z = N = 1)
// 011	Less_Than (N = 1)
// 100	Greater_Than_Or_Equal (Z = 1 or Z = N = 0)
// 101	Less_Than_Or_Equal (N = 1 or Z = 1)
// 110	Overflow (V = 1)
// 111	Unconditional

PC_control iDUT(.C(C_dut), .I(I_dut), .F(F_dut), .PC_in(PC_in_dut), .PC_out(PC_out_dut), .BR(BR_dut));

initial begin
clk = 0;

imm_tb = 9'h004;
PC_tb = 16'h0000;
BR_tb = 16'hFF00;

// CORRECT TESTS (when branch SHOULD be taken for each condition code)
PC_Test(Not_Equal,imm_tb, PC_tb, BR_tb); // Z = 0
PC_Test(Equal, imm_tb, PC_tb, BR_tb); // Z = 1 
PC_Test(Greater_Than, imm_tb, PC_tb, BR_tb); // Z = N = 1
PC_Test(Less_Than, imm_tb, PC_tb, BR_tb); // N = 1
PC_Test(Greater_Than_Or_Equal, imm_tb, PC_tb, BR_tb); // Z = 1
PC_Test(Greater_Than_Or_Equal, imm_tb, PC_tb, BR_tb); // Z = N = 0
PC_Test(Less_Than_Or_Equal, imm_tb, PC_tb, BR_tb); //  N = 1
PC_Test(Less_Than_Or_Equal, imm_tb, PC_tb, BR_tb); //  Z = 1
PC_Test(Overflow, imm_tb, PC_tb, BR_tb); // V = 1
PC_Test(Unconditional, imm_tb, PC_tb, BR_tb);

$stop;

end
/** Checks PC against expected value
input  [2:0] C; 	// ccc - condition encodings
input  [8:0] I; 	// immediate offset
input  [15:0] PC_in; 	// current PC Value
input  [15:0] BR;	// value to branch to, LSB is used to signify BR vs B: (0 - BR, 1 - B)
**/
task PC_Test (logic [2:0] C, logic [8:0] I, logic [15:0] PC_in, logic [15:0] BR_tb);

logic [15:0] Expected_PC_out;
logic takeBranch;

logic [2:0] Flags;
logic [15:0] signExtendedShiftedOffset;

logic correct;

signExtendedShiftedOffset = {{6{I[8]}}, I[8:0],1'b0};

correct=1;
Flags = 3'h0;

repeat(8) begin

@(posedge clk);
	C_dut = C;
	I_dut = I;
	F_dut = Flags;
	PC_in_dut = PC_in;
	BR_dut = 16'hFFFF;

	Z_flag = Flags[2];
	V_flag = Flags[1];
	N_flag = Flags[0];
	
	takeBranch = ((C === 3'b000) && (~Z_flag)) ||
		     ((C === 3'b001) && (Z_flag)) ||
		     ((C === 3'b010) && (~Z_flag) && (~N_flag)) ||
		     ((C === 3'b011) && (N_flag)) ||
		     ((C === 3'b100) && (Z_flag || (~Z_flag && ~N_flag))) ||
		     ((C === 3'b101) && (N_flag || Z_flag)) ||
		     ((C === 3'b110) && (V_flag)) ||
		     (C === 3'b111);
	Expected_PC_out = (takeBranch) ? PC_in + signExtendedShiftedOffset + 2: PC_in + 2;

//B insructions

@(negedge clk) begin
	if (PC_out_dut !== Expected_PC_out) begin
		$display("INCORECCT: \t PC_out=%h, Expected_PC_out=%h, ccc=%b, flags=%b, branch_value=%h, takeBranch:%b", PC_out_dut, Expected_PC_out, C, Flags,BR_dut,takeBranch);
		correct = 0;
	end	
	else 
		correct = 1;
end

//BR instructions

@(posedge clk) BR_dut = BR_tb;

	takeBranch = ((C === 3'b000) && (~Z_flag)) ||
		     ((C === 3'b001) && (Z_flag)) ||
		     ((C === 3'b010) && (~Z_flag) && (~N_flag)) ||
		     ((C === 3'b011) && (N_flag)) ||
		     ((C === 3'b100) && (Z_flag || (~Z_flag && ~N_flag))) ||
		     ((C === 3'b101) && (N_flag || Z_flag)) ||
		     ((C === 3'b110) && (V_flag)) ||
		     (C === 3'b111);

Expected_PC_out = (takeBranch) ? BR_tb : PC_in + 2;
@(negedge clk) begin
	if (PC_out_dut !== Expected_PC_out) begin
		$display("INCORECCT: \t PC_out=%h, Expected_PC_out=%h, ccc=%b, flags=%b, branch_value=%h, takeBranch:%b", PC_out_dut, Expected_PC_out, C, Flags,BR_dut,takeBranch);
		correct = 0;
	end	
	else 
		correct = 1;
end

Flags = Flags + 1;
end
endtask

always #5 clk = ~clk;

endmodule
