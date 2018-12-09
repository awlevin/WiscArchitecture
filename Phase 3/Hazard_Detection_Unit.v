module Hazard_Detection_Unit(stall_en, dec_opcode, id_ex_dstReg_out, ex_mem_dstReg_out, srcReg1, srcReg2, id_ex_memRead_in, id_ex_memRead_out);

output stall_en;
input [3:0] srcReg1, srcReg2, id_ex_dstReg_out, ex_mem_dstReg_out, dec_opcode;
input id_ex_memRead_in, id_ex_memRead_out;

wire has_immediate;
assign has_immediate = 	(dec_opcode == 4'b0100)		// Ignore the immediate for SLL
			| (dec_opcode == 4'b0101)	// SRA
			| (dec_opcode == 4'b0110)	// ROR
			| (dec_opcode[3] == 1'b1);	// or opcode >= 0x1000

//assert stall if instr was a LW & destination reg of previous instr matches request of following instr (Mem to Ex Fwd)
//also assert stall for when Fwd'ing to BR is required
assign stall_en = id_ex_memRead_out & ((id_ex_dstReg_out == srcReg1) | ((id_ex_dstReg_out == srcReg2) & ~has_immediate)) ||
			((dec_opcode == 4'hD) & (((id_ex_dstReg_out == srcReg1) & id_ex_memRead_out) | (ex_mem_dstReg_out == srcReg1)));

endmodule
