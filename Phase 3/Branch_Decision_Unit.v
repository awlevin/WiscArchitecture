module Branch_Decision_Unit(take_branch, stall_en, hasStalled, br_hazard, opcode, flags, C);

input [2:0] flags, C;		// ccc - condition encodings
input [3:0] opcode;
input hasStalled, br_hazard;

output take_branch,stall_en;

wire b_opcode, br_opcode, condition_met;

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

assign b_opcode = (opcode == 4'hC);	//Branch statement								
assign br_opcode = (opcode == 4'hD);	//Branch Register
assign condition_met = b_ne | b_eq | b_gt | b_lt | b_gt_or_eq | b_lt_or_eq | b_ovfl;

assign take_branch = (b_opcode & ((condition_met & hasStalled) | b_uncond)) |
			(br_opcode & ~br_hazard & ((condition_met & hasStalled) | b_uncond)); //in order for take branch to be true, the unit must have stalled by one cycle (will check later for ccc = 111)
assign stall_en = ((~hasStalled & (b_opcode | br_opcode) & ~b_uncond) | br_hazard); //if the unit encounters a b or br, it must stall for a cycle unless it's unconditional
endmodule
