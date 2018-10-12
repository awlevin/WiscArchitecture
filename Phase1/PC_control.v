
module PC_control(C, I, F, PC_in, BR, En, PC_out);

input  [2:0] C; 	// ccc - condition encodings
input  [8:0] I; 	// immediate offset
input  [2:0] F; 	// flags (N, Z, V)
input  [15:0] PC_in; 	// current PC Value
input  [15:0] BR;	// value to branch to, LSB is used to signify BR vs B: (0 - BR, 1 - B)
input  En;		// 0: Branching is NOT enabled (PC = PC + 2), 1: Branching is enabled
output [15:0] PC_out;	// Output of PC control

reg takeBranch; // 1 if we should branch, 0 if we should increment PC by 2
wire [15:0] PC_plus_2, PC_plus_2_imm,Imm_Shftd_Sign_Ext; // PC_plus_2 = PC + 2, PC_plus_2_imm = PC + 2 + imm
wire Z_flag, V_flag, N_flag;

adder_16bit add_2_module(.A(PC_in), .B(16'h0002), .Sub(1'b0), .Sum(PC_plus_2), .Zero(), .Ovfl(), .Sign());
adder_16bit add_imm_module(.A(PC_plus_2), .B(Imm_Shftd_Sign_Ext), .Sub(1'b0), .Sum(PC_plus_2_imm), .Zero(), .Ovfl(), .Sign());

assign PC_out = (takeBranch & En) ? 
			((BR[0]) ? PC_plus_2_imm : BR): //BR vs B if branch is taken
		 PC_plus_2; // Branch is not taken

assign Z_flag = F[2];
assign V_flag = F[1];
assign N_flag = F[0];

assign Imm_Shftd_Sign_Ext = {{6{I[8]}},I,1'b0};

always @(*) begin
case(C)

// Not Equal (Z = 0)
3'b000: begin takeBranch = (Z_flag == 0); end

// Equal (Z = 1)
3'b001: begin takeBranch = (Z_flag == 1); end

// Greater Than (Z = N = 0)
3'b010: begin takeBranch = ((Z_flag == 0) & (N_flag == 0)); end

// Less Than (N = 1) 
3'b011: begin takeBranch = (N_flag == 1); end

// Greater Than or Equal (Z = 1 or Z = N = 0)
3'b100: begin takeBranch = ((Z_flag == 1) | ((Z_flag == 0) & (N_flag == 0))); end

// Less Than or Equal (N = 1 or Z = 1)
3'b101: begin takeBranch = ((N_flag == 1) | (Z_flag == 1)); end

// Overflow (V = 1)
3'b110: begin takeBranch = (V_flag == 1); end

// Unconditional
3'b111: begin takeBranch = 1'b1; end

endcase

end // end always

endmodule
