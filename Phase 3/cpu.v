module cpu(clk, rst_n, hlt, pc_out);

input clk, rst_n;
output hlt;
output [15:0] pc_out;

// PC Wires
wire [15:0] next_pc, pc_out, curr_pc, pc_plus_2, address_to_add_to_pc_for_b_or_br, dec_pc_imm_shftd_sign_ext, pc_with_branch;

// Instruction
wire [15:0] instr,saved_instr,instr_out;

wire [15:0] ex_instr, mem_instr, wb_instr;
wire saved_hlt;
// Decode Wires
wire [15:0] if_id_pc_add_2_out,pc_plus_2_or_zero, dec_instr, srcData1, srcData2;
wire [3:0] srcReg1, srcReg2, id_ex_dstReg_in, id_ex_dstReg_out,id_ex_aluOp_in, decoded_instr_type;
wire [15:0] dec_ex_sign_ext_alu_offset_in, dec_ex_sign_ext_alu_offset_out, id_ex_data1_in, id_ex_data2_in;
wire [2:0] ccc;
wire [2:0] flags; // FLAGS ==>> (Z, V, N)
wire is_LLB_or_LHB, is_b_instr, is_br_instr, b_or_br_opcode;
wire id_ex_regWrite_in,id_ex_memToReg_in,id_ex_memRead_in,id_ex_memWrite_in,id_ex_aluSrc_in,id_ex_is_LLB_or_LHB_out,is_PCS;
wire [3:0] id_ex_srcReg1_out, id_ex_srcReg2_out;
wire take_branch,takeBranchOrFlush;
wire regWriteUnlessR0;
wire hasStalled,shouldStall,flush_next_instr;
wire [3:0] if_id_opcode_out;
wire [15:0] pc_from_cycle_before_halt_decoded;
wire hlt_found,lastInstrWasHalt;
wire hazard_stall_en,branch_stall_en,stall_en, rst_id_ex_reg;

// Execute Wires
wire id_ex_aluSrc_out;
wire [3:0] id_ex_aluOp_out, ex_mem_dstReg_out;
wire id_ex_memRead_out, id_ex_memWrite_out, id_ex_regWrite_out, id_ex_memToReg_out,id_ex_is_PCS_out;
wire [15:0] id_ex_rd1_out, id_ex_rd2_out;
wire [15:0] aluSrc1, aluSrc2;
wire [3:0] ex_mem_srcReg1_out,ex_mem_srcReg2_out;
wire [15:0] aluSrc1_ex_to_ex_fwd,aluSrc1_mem_to_ex_fwd;
wire [15:0] aluSrc2_no_fwd,aluSrc2_ex_to_ex_fwd,aluSrc2_mem_to_ex_fwd;
wire [2:0] flags_alu_out;
wire set_flags;

// Memory Wires
wire ex_mem_memRead_out, ex_mem_memWrite_out, ex_mem_regWrite_out, ex_mem_memToReg_out;
wire [15:0] ex_mem_alu_result_in, ex_mem_alu_result_out, ex_mem_dataIn_out, mem_wb_read_memData_in,ex_mem_dataIn_in;
wire [15:0] writeback_write_data, mem_wb_read_data_out, mem_wb_alu_result_out;
wire [3:0] mem_wb_dstReg_out;
wire mem_wb_memToReg_out, memEnable;
wire [15:0] data_mem_data_in;

wire cache_miss, i_cache_miss, d_cache_miss;
assign cache_miss = i_cache_miss | d_cache_miss;

dff_16bit saved_instr_reg(.clk(clk),.rst(~rst_n),.d(instr),.q(saved_instr),.wen(~cache_miss & ~hlt_found));

assign instr = cache_miss | hlt_found ? saved_instr : instr_out;

memory mem(.clk(clk), .rst(~rst_n), .instruction_out(instr_out), .data_out(mem_wb_read_memData_in), .I_Cache_miss(i_cache_miss), .D_Cache_miss(d_cache_miss), .mem_data_in(data_mem_data_in), .pc(pc_out), .mem_addr(ex_mem_alu_result_out), .enable(memEnable), .wr(ex_mem_memWrite_out),.decoded_instr_is_hlt(hlt_found));

////////////////////////
//     HALT LOGIC     //
////////////////////////
//If an instruction is a halt, we must stop writing to registers, stop incrementing the pc, stop reading and writing to memory
//Halt wires
hlt_register hlt_reg(.clk(clk), .rst_n(rst_n), .hlt_found(hlt_found), .hlt(saved_hlt), .lastInstrWasHalt(lastInstrWasHalt));
assign hlt = saved_hlt & ~stall_en;
////////////////////////
//  FORWARDING LOGIC  //
////////////////////////
wire fwd_ex_to_ex_srcReg1, fwd_ex_to_ex_srcReg2, fwd_mem_to_ex_srcReg1, fwd_mem_to_ex_srcReg2, fwd_mem_to_mem;
ForwardingUnit fwd_unit(.ex_mem_dstReg(ex_mem_dstReg_out), .id_ex_srcReg1(id_ex_srcReg1_out), .id_ex_srcReg2(id_ex_srcReg2_out), .ex_mem_srcReg2(ex_mem_srcReg2_out), .ex_mem_regWrite(ex_mem_regWrite_out), .mem_wb_dstReg(mem_wb_dstReg_out), .mem_wb_regWrite(mem_wb_regWrite_out), .ex_mem_memWrite(ex_mem_memWrite_out), .fwd_ex_to_ex_srcReg1(fwd_ex_to_ex_srcReg1), .fwd_ex_to_ex_srcReg2(fwd_ex_to_ex_srcReg2), .fwd_mem_to_ex_srcReg1(fwd_mem_to_ex_srcReg1), .fwd_mem_to_ex_srcReg2(fwd_mem_to_ex_srcReg2), .fwd_mem_to_mem(fwd_mem_to_mem));

////////////////////////
//  HAZARD DETECTION  //
////////////////////////

assign stall_en = hazard_stall_en | branch_stall_en | cache_miss;
assign rst_id_ex_reg = (~rst_n | (stall_en & ~d_cache_miss));
assign if_id_opcode_out = dec_instr[15:12];
Hazard_Detection_Unit hazard_unit(.stall_en(hazard_stall_en), .dec_opcode(if_id_opcode_out), .id_ex_dstReg_out(id_ex_dstReg_out), .ex_mem_dstReg_out(ex_mem_dstReg_out), .srcReg1(srcReg1), .srcReg2(srcReg2), .id_ex_memRead_in(id_ex_memRead_in), .id_ex_memRead_out(id_ex_memRead_out));

////////////////////////
// PIPELINE REGISTERS //
////////////////////////
Fetch_Decode_Reg IF_ID_Reg(.clk(clk), .rst_n(rst_n), .flush_en(take_branch), .stall_en(stall_en), .pc_add_in(pc_plus_2), .pc_add_out(if_id_pc_add_2_out), .instr_in(instr), .instr_out(dec_instr), .flush_next_instr(flush_next_instr));
Decode_Execute_Reg ID_EX_Reg(.instr_in(dec_instr), .instr_out(ex_instr), .clk(clk), .rst_n(~rst_id_ex_reg), .stall_en(stall_en), .d_cache_miss(d_cache_miss), .rd1_in(id_ex_data1_in), .rd2_in(id_ex_data2_in), .rd1_out(id_ex_rd1_out), .rd2_out(id_ex_rd2_out), .sign_ext_in(dec_ex_sign_ext_alu_offset_in), .sign_ext_out(dec_ex_sign_ext_alu_offset_out), .dstReg_in(id_ex_dstReg_in), .dstReg_out(id_ex_dstReg_out), .srcReg1_in(srcReg1), .srcReg1_out(id_ex_srcReg1_out),.srcReg2_in(srcReg2), .srcReg2_out(id_ex_srcReg2_out),.is_LLB_or_LHB_in(is_LLB_or_LHB),.is_LLB_or_LHB_out(id_ex_is_LLB_or_LHB_out),.is_PCS_in(is_PCS),.is_PCS_out(id_ex_is_PCS_out) );
Execute_Memory_Reg EX_MEM_Reg(.instr_in(ex_instr), .instr_out(mem_instr), .clk(clk), .rst_n(rst_n), .stall_en(d_cache_miss), .zero_in(), .zero_out(), .alu_result_in(ex_mem_alu_result_in), .alu_result_out(ex_mem_alu_result_out), .dataIn_in(ex_mem_dataIn_in), .dataIn_out(ex_mem_dataIn_out), .dstReg_in(id_ex_dstReg_out), .dstReg_out(ex_mem_dstReg_out),.srcReg1_in(id_ex_srcReg1_out),.srcReg1_out(ex_mem_srcReg1_out),.srcReg2_in(id_ex_srcReg2_out),.srcReg2_out(ex_mem_srcReg2_out));
Memory_WriteBack_Reg MEM_WB_Reg(.instr_in(mem_instr), .instr_out(wb_instr), .clk(clk), .rst_n(rst_n), .stall_en(d_cache_miss), .read_data_in(mem_wb_read_memData_in), .read_data_out(mem_wb_read_data_out), .alu_result_in(ex_mem_alu_result_out), .alu_result_out(mem_wb_alu_result_out), .dstReg_in(ex_mem_dstReg_out), .dstReg_out(mem_wb_dstReg_out));

/////////////////////
//     FETCH	   //
/////////////////////
PC_Register pc_register(.clk(clk), .rst(~rst_n), .stall_en(stall_en), .next_pc(next_pc), .pc_out(curr_pc));
adder_16bit pc_add_2_module(.A(pc_out), .B(16'h0002), .Sub(1'b0), .Sum(pc_plus_2), .Zero(), .Ovfl(), .Sign());
dff_16bit pc_before_halt(.clk(clk), .rst(~rst_n), .d(pc_out), .q(pc_from_cycle_before_halt_decoded), .wen(1'b1));

assign next_pc = (take_branch) ? pc_with_branch : 
		 (&(instr_out[15:12]) | hlt_found) ?  pc_out : pc_plus_2;
assign pc_out = hlt_found | lastInstrWasHalt ? pc_from_cycle_before_halt_decoded : curr_pc;

/////////////////////
//       ID	   //
/////////////////////
assign takeBranchOrFlush = take_branch | flush_next_instr;
EX_Register ID_EX_Ex(.clk(clk), .rst(rst_id_ex_reg), .stall_en(stall_en), .d_cache_miss(d_cache_miss), .flush_en(takeBranchOrFlush), .ALUSrc_in(id_ex_aluSrc_in), .ALUOp_in(id_ex_aluOp_in), .ALUSrc_out(id_ex_aluSrc_out), .ALUOp_out(id_ex_aluOp_out));
M_Register ID_EX_Mem(.clk(clk), .rst(rst_id_ex_reg), .stall_en(stall_en), .d_cache_miss(d_cache_miss), .flush_en(takeBranchOrFlush), .MemRead_in(id_ex_memRead_in), .MemWrite_in(id_ex_memWrite_in), .MemRead_out(id_ex_memRead_out), .MemWrite_out(id_ex_memWrite_out));
WB_Register ID_EX_WriteBack(.clk(clk), .rst(rst_id_ex_reg), .stall_en(stall_en), .d_cache_miss(d_cache_miss), .flush_en(takeBranchOrFlush), .RegWrite_in(id_ex_regWrite_in), .MemToReg_in(id_ex_memToReg_in), .RegWrite_out(id_ex_regWrite_out), .MemToReg_out(id_ex_memToReg_out));

assign decoded_instr_type = cache_miss ? saved_instr : dec_instr[15:12];
assign is_b_instr = (decoded_instr_type == 4'hC);
assign is_br_instr = (decoded_instr_type == 4'hD);
assign b_or_br_opcode = (is_b_instr | is_br_instr); // true if instr is a B or BR

assign shouldStall = (b_or_br_opcode & ~hasStalled) | (is_br_instr & hasStalled & hazard_stall_en); //if instr is a B or BR and the unit has not previously stalled
dff stallStatus(.clk(clk), .rst(~rst_n), .q(hasStalled), .d(shouldStall), .wen(~cache_miss));

Branch_Decision_Unit branch_unit(.take_branch(take_branch), .stall_en(branch_stall_en), .hasStalled(hasStalled), .br_hazard(hazard_stall_en), .opcode(decoded_instr_type), .flags(flags), .C(ccc));

//Halt logic
assign hlt_found = &decoded_instr_type & ~cache_miss;

assign is_LLB_or_LHB = (dec_instr[15:13]==3'b101);
assign is_PCS = decoded_instr_type == 4'hE;
assign id_ex_dstReg_in = dec_instr[11:8];	//Dst register location
assign srcReg1 = is_LLB_or_LHB ? dec_instr[11:8] : dec_instr[7:4]; //If instruction is an LLB or LHB, then the Dst reg = Src Reg1
assign srcReg2 = id_ex_memWrite_in ? dec_instr[11:8] : dec_instr[3:0]; // if instr is SW, as per diagram, srcReg2's value will be stored

// ALU
assign id_ex_aluSrc_in = dec_instr[15] & ~is_LLB_or_LHB & ~is_PCS; //  0: ALU instr's [0,7] 1: Memory & Control instr [8,15] except for LLB and LHB
assign id_ex_aluOp_in = decoded_instr_type; // If instr is SW or LW, tell ALU to do an Add, otherwise give the instr[15:12] aka the opcode

//Control logic
assign ccc = cache_miss ? saved_instr[11:9] : dec_instr[11:9]; //condition codes
assign dec_ex_sign_ext_alu_offset_in =  { {11{dec_instr[3]}}, dec_instr[3:0], 1'b0}; //sign extended offset used in LW's & SW's
assign dec_pc_imm_shftd_sign_ext = {{6{dec_instr[8]}}, dec_instr[8:0], 1'b0}; //immediate for branch instruction's, which is shifted left and SE

assign pc_plus_2_or_zero =  (decoded_instr_type == 4'b1101) ? 16'h0000 : if_id_pc_add_2_out; // if instr is a BR, then the 1st operand should be 0, else use pc+2
assign address_to_add_to_pc_for_b_or_br = 
			(decoded_instr_type == 4'b1100) ? dec_pc_imm_shftd_sign_ext :  //Branch instr
			((decoded_instr_type == 4'b1101) ? srcData1 : //Branch Reg instr
				16'hFFFF); // Default case

//Memory
assign id_ex_data1_in = (decoded_instr_type == 4'b1110) ? if_id_pc_add_2_out : srcData1;		// If PCS, pass the PC forward and the ALU will know how to handle it

assign id_ex_data2_in = (decoded_instr_type == 4'b1010) ? {8'b0, dec_instr[7:0]} :		// Use byte from instruction for LLB
			(decoded_instr_type == 4'b1011) ? {dec_instr[7:0], 8'b0} :		// Use byte from instruction for LHB
			(dec_instr[15:13]  == 3'b010) | (decoded_instr_type == 4'b0110) ? 
							{12'b0, dec_instr[3:0]} :		// Use 4-bit value for SLL, SRA, ROR
			is_PCS ? 16'h0000:							// If pcs, add two to address since pc + 2 is off by 2
			srcData2;								// Otherwise, use register file data unmodified

assign id_ex_memRead_in = decoded_instr_type == 4'h8; //LW
assign id_ex_memWrite_in = decoded_instr_type == 4'h9; //SW
											
//WriteBack
assign id_ex_regWrite_in =  ~dec_instr[15] | //ALU Op 
				id_ex_memRead_in|//LW
				is_LLB_or_LHB | //LLB or LHB
				is_PCS; //PCS

//Mux selector if value should come from memory or alu result		
assign id_ex_memToReg_in = id_ex_memRead_in; // 0:Alu op , 1:SW(only instr to write to reg from memory)

//Generate PC with branch address
adder_16bit pc_add_imm_module(.A(pc_plus_2_or_zero), .B(address_to_add_to_pc_for_b_or_br), .Sub(1'b0), .Sum(pc_with_branch), .Zero(), .Ovfl(), .Sign());

//Prevents writes to R0
assign regWriteUnlessR0 = |mem_wb_dstReg_out ? mem_wb_regWrite_out : 1'b0; //Do not write to R0
RegisterFile regFile(.clk(clk), .rst(~rst_n), .SrcReg1(srcReg1), .SrcReg2(srcReg2), .DstReg(mem_wb_dstReg_out), .WriteReg(mem_wb_regWrite_out), .DstData(writeback_write_data), .SrcData1(srcData1), .SrcData2(srcData2));


/////////////////////
//       EX	   //
/////////////////////
M_Register EX_MEM_Mem(.clk(clk), .rst(~rst_n), .stall_en(1'b0), .d_cache_miss(d_cache_miss), .flush_en(1'b0), .MemRead_in(id_ex_memRead_out), .MemWrite_in(id_ex_memWrite_out), .MemRead_out(ex_mem_memRead_out), .MemWrite_out(ex_mem_memWrite_out));
WB_Register EX_MEM_WriteBack(.clk(clk), .rst(~rst_n), .stall_en(1'b0), .d_cache_miss(d_cache_miss), .flush_en(1'b0), .RegWrite_in(id_ex_regWrite_out), .MemToReg_in(id_ex_memToReg_out), .RegWrite_out(ex_mem_regWrite_out), .MemToReg_out(ex_mem_memToReg_out));

assign aluSrc1_ex_to_ex_fwd = (fwd_ex_to_ex_srcReg1 & ~id_ex_is_PCS_out) ? ex_mem_alu_result_out : id_ex_rd1_out;
assign aluSrc1_mem_to_ex_fwd = (fwd_mem_to_ex_srcReg1 & ~id_ex_is_PCS_out) ? writeback_write_data : aluSrc1_ex_to_ex_fwd;

assign aluSrc2_no_fwd = (id_ex_aluSrc_out) ? dec_ex_sign_ext_alu_offset_out : id_ex_rd2_out;
assign aluSrc2_ex_to_ex_fwd = (fwd_ex_to_ex_srcReg2 & ~id_ex_is_LLB_or_LHB_out & ~id_ex_is_PCS_out & ~id_ex_memRead_out & ~id_ex_memWrite_out) ? ex_mem_alu_result_out : aluSrc2_no_fwd;
assign aluSrc2_mem_to_ex_fwd = (fwd_mem_to_ex_srcReg2 & ~id_ex_is_LLB_or_LHB_out & ~id_ex_is_PCS_out & ~id_ex_memRead_out & ~id_ex_memWrite_out) ? writeback_write_data : aluSrc2_ex_to_ex_fwd;

assign aluSrc1 = aluSrc1_mem_to_ex_fwd;
assign aluSrc2 = aluSrc2_mem_to_ex_fwd;

ALU alu_module(.clk(clk), .rst(~rst_n), .Opcode(id_ex_aluOp_out), .Input1(aluSrc1), .Input2(aluSrc2), .Output(ex_mem_alu_result_in), .flags_out(flags_alu_out));

FlagsRegister flags_dff(.clk(clk), .rst(~rst_n), .set(set_flags), .flags_in(flags_alu_out), .flags_out(flags));
assign set_flags = ((id_ex_aluOp_out != 4'b0111) && (id_ex_aluOp_out != 4'b0011) && (id_ex_aluOp_out[3] != 1'b1)) & (|ex_instr); // don't update flags on RED, PADDSB, LW/SW/LHB/LLB/B/BR/PCS -- also, |ex_instr represents a NOP

assign ex_mem_dataIn_in = (fwd_mem_to_ex_srcReg2 & id_ex_memWrite_out) ? writeback_write_data : id_ex_rd2_out; //as per zybooks diagram, value of reg2 from dec/ex pipeline should be used as the data in

/////////////////////
//       MEM	   //
/////////////////////

assign memEnable = (ex_mem_memRead_out | ex_mem_memWrite_out); // instr must be a read or write (& not a halt)
assign data_mem_data_in = (fwd_mem_to_mem) ? writeback_write_data : ex_mem_dataIn_out; //value to be stored in the Register File

WB_Register MEM_WB_WriteBack(.clk(clk), .rst(~rst_n), .stall_en(1'b0), .d_cache_miss(d_cache_miss), .flush_en(1'b0), .RegWrite_in(ex_mem_regWrite_out & |mem_instr), .MemToReg_in(ex_mem_memToReg_out), .RegWrite_out(mem_wb_regWrite_out), .MemToReg_out(mem_wb_memToReg_out));
assign writeback_write_data = (mem_wb_memToReg_out) ? mem_wb_read_data_out : mem_wb_alu_result_out;

endmodule

