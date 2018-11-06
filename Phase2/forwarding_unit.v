module ForwardingUnit(id_ex_dstReg,ex_mem_dstReg,id_ex_srcReg1,id_ex_srcReg2,id_ex_memWrite,fwd_ex_to_ex_srcReg1,fwd_ex_to_ex_srcReg2);
input [3:0] id_ex_dstReg,ex_mem_dstReg,id_ex_srcReg1,id_ex_srcReg2;
input id_ex_memWrite;

output fwd_ex_to_ex_srcReg1,fwd_ex_to_ex_srcReg2;

endmodule
