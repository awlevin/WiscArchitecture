module ForwardingUnit(ex_mem_dstReg, id_ex_srcReg1, id_ex_srcReg2, ex_mem_srcReg2, ex_mem_regWrite, mem_wb_dstReg, mem_wb_regWrite, ex_mem_memWrite, fwd_ex_to_ex_srcReg1, fwd_ex_to_ex_srcReg2, fwd_mem_to_ex_srcReg1, fwd_mem_to_ex_srcReg2, fwd_mem_to_mem);

input [3:0] ex_mem_dstReg, id_ex_srcReg1, id_ex_srcReg2, mem_wb_dstReg, ex_mem_srcReg2;
input ex_mem_regWrite, mem_wb_regWrite, ex_mem_memWrite;

output fwd_ex_to_ex_srcReg1, fwd_ex_to_ex_srcReg2, fwd_mem_to_ex_srcReg1, fwd_mem_to_ex_srcReg2, fwd_mem_to_mem;

// Ex-to-Ex Forwarding
assign fwd_ex_to_ex_srcReg1 = (ex_mem_dstReg == id_ex_srcReg1) && (ex_mem_regWrite);
assign fwd_ex_to_ex_srcReg2 = (ex_mem_dstReg == id_ex_srcReg2) && (ex_mem_regWrite);

// Mem-to-Ex Forwarding
assign fwd_mem_to_ex_srcReg1 = (mem_wb_dstReg == id_ex_srcReg1) && (ex_mem_dstReg != id_ex_srcReg1) && (mem_wb_regWrite == 1'b1);
assign fwd_mem_to_ex_srcReg2 = (mem_wb_dstReg == id_ex_srcReg2) && (ex_mem_dstReg != id_ex_srcReg2) && (mem_wb_regWrite == 1'b1);
// Mem-to-Mem Forwarding
assign fwd_mem_to_mem = (ex_mem_memWrite == 1'b1) && (ex_mem_srcReg2 == mem_wb_dstReg) && (mem_wb_regWrite == 1'b1);

endmodule
