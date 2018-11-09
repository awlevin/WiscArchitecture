module Branch_Decision_Unit(take_branch, flags, C);

input [2:0] flags,
	    C;		// ccc - condition encodings
output take_branch;

assign Z_flag = flags[2];
assign V_flag = flags[1];
assign N_flag = flags[0];

assign b_ne = (C == 3'b000) && (Z_flag == 1'b0); 							// Not Equal (Z = 0)
assign b_eq = (C == 3'b001) && (Z_flag == 1'b1);							// Equal (Z = 1)
assign b_gt = (C == 3'b010) && ((Z_flag == 1'b0) & (N_flag == 1'b0)); 					// Greater Than (Z = N = 0)
assign b_lt = (C == 3'b011) && (N_flag == 1'b1); 							// Less Than (N = 1) 
assign b_gt_or_eq = (C == 3'b100) && ((Z_flag == 1'b1) | ((Z_flag == 1'b0) & (N_flag == 1'b0))); 	// Greater Than or Equal (Z = 1 or Z = N = 0)
assign b_lt_or_eq = (C == 3'b101) && ((N_flag == 1'b1) | (Z_flag == 1'b1)); 				// Less Than or Equal (N = 1 or Z = 1)
assign b_ovfl = (C == 3'b110) && (V_flag == 1'b1); 							// Overflow (V = 1)
assign b_uncond = (C == 3'b111); 									// Unconditional

assign take_branch = b_ne | b_eq | b_gt | b_lt | b_gt_or_eq | b_lt_or_eq | b_ovfl | b_uncond;

endmodule
