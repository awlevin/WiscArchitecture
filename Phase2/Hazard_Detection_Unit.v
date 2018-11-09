module Hazard_Detection_Unit(stall_en, dec_opcode, id_ex_dstReg_out, srcReg1, srcReg2, id_ex_memRead_in, id_ex_memRead_out);

output stall_en;
input [3:0] srcReg1, srcReg2, id_ex_dstReg_out, dec_opcode;
input id_ex_memRead_in, id_ex_memRead_out;

//wire en;
//assign en = ~id_ex_memRead_in && id_ex_memRead_out;
wire has_immediate;
assign has_immediate = 	(dec_opcode == 4'b0010)		// Ignore "srcReg2" if instruction is XOR
			|| (dec_opcode == 4'b0100)	// SLL
			|| (dec_opcode == 4'b0101)	// SRA
			|| (dec_opcode == 4'b0110)	// ROR
			|| (dec_opcode[3] == 1'b1);	// or opcode >= 0x1000

assign stall_en = id_ex_memRead_out && ((id_ex_dstReg_out == srcReg1) || ((id_ex_dstReg_out == srcReg2) && ~has_immediate));

//assign stall_en = ((id_ex_dstReg_out == srcReg1) && id_ex_memRead_out) || ((id_ex_dstReg_out == srcReg2) && en);

endmodule
