
module PC_control(C, I, F, PC_in, PC_out);

input [2:0] C; // ccc - condition encodings
input [8:0] I; // immediate offset
input [2:0] F; // flags (N, Z, V)
input [15:0] PC_in; 
output [15:0] PC_out;

reg takeBranch; // 1 if we should branch, 0 if we should increment PC by 2
wire [15:0] PC_plus_2, PC_plus_2_imm; // PC_plus_2 = PC + 2, PC_plus_2_imm = PC + 2 + imm
wire Z_flag, F_flag, N_flag;

adder_16bit add_2_module(.A(PC_in), .B(16'd2), .Sub(), .Sum(PC_plus_2), .Zero(), .Ovfl(), .Sign());
adder_16bit add_imm_module(.A(PC_plus_2), .B({{7{I[8]}}, I}), .Sub(), .Sum(PC_plus_2_imm), .Zero(), .Ovfl(), .Sign());

assign PC_out = (takeBranch) ? PC_plus_2_imm : PC_plus_2;

assign Z_flag = F[2];
assign V_flag = F[1];
assign N_flag = F[0];

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
