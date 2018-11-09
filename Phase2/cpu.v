module cpu(clk, rst_n, hlt, pc);

input clk, rst_n;
output hlt;
output [15:0] pc;

// PC Wires
wire [15:0] next_pc, pc_out, pc_plus_2, address_to_add_to_pc_for_b_or_br, pc_with_branch;
assign pc = pc_out;

// Instruction
wire [15:0] instr;

// Control Signals
wire PCSrc;

// Decode Wires
wire [15:0] if_id_pc_add_2_out, dec_instr, srcData1, srcData2;
wire [3:0] srcReg1, srcReg2, id_ex_dstReg_in, id_ex_dstReg_out,id_ex_aluOp_in;
wire [8:0] pc_control_immediate;
wire [15:0] dec_ex_sign_ext_alu_offset_in, dec_ex_sign_ext_alu_offset_out, id_ex_data1_in, id_ex_data2_in;
wire [2:0] ccc;
wire [2:0] flags; // FLAGS ==>> (Z, V, N)
wire is_LLB_or_LHB;
wire id_ex_regWrite_in,id_ex_memToReg_in,id_ex_memRead_in,id_ex_memWrite_in,id_ex_aluSrc_in,id_ex_is_LLB_or_LHB_out;
wire [3:0] id_ex_srcReg1_out, id_ex_srcReg2_out;

// Execute Wires
wire id_ex_aluSrc_out;
wire [3:0] id_ex_aluOp_out, ex_mem_dstReg_out;
wire id_ex_memRead_out, id_ex_memWrite_out, id_ex_regWrite_out, id_ex_memToReg_out;
wire [15:0] id_ex_rd1_out, id_ex_rd2_out;
wire [15:0] aluSrc1, aluSrc2;
wire [3:0] ex_mem_srcReg1_out,ex_mem_srcReg2_out;
wire [15:0] aluSrc1_ex_to_ex_fwd,aluSrc1_mem_to_ex_fwd;
wire [15:0] aluSrc2_no_fwd,aluSrc2_ex_to_ex_fwd,aluSrc2_mem_to_ex_fwd;

// Memory Wires
wire ex_mem_memRead_out, ex_mem_memWrite_out, ex_mem_regWrite_out, ex_mem_memToReg_out;
wire [15:0] ex_mem_alu_result_in, ex_mem_alu_result_out, ex_mem_dataIn_out, mem_wb_read_memData_in,ex_mem_dataIn_in;
wire [15:0] writeback_write_data, mem_wb_read_data_out, mem_wb_alu_result_out;
wire [3:0] mem_wb_dstReg_out;
wire mem_wb_memToReg_out, memEnable;
wire [15:0] data_mem_data_in;

//If an instruction is a halt, we must stop writing to registers, stop incrementing the pc, stop reading and writing to memory
//Halt wires
wire [15:0] next_pc_or_halt;
wire regWrite_or_halt;


////////////////////////
//  FORWARDING LOGIC  //
////////////////////////
wire fwd_ex_to_ex_srcReg1, fwd_ex_to_ex_srcReg2, fwd_mem_to_ex_srcReg1, fwd_mem_to_ex_srcReg2, fwd_mem_to_mem;
ForwardingUnit fwd_unit(.ex_mem_dstReg(ex_mem_dstReg_out), .id_ex_srcReg1(id_ex_srcReg1_out), .id_ex_srcReg2(id_ex_srcReg2_out), .ex_mem_srcReg2(ex_mem_srcReg2_out), .ex_mem_regWrite(ex_mem_regWrite_out), .mem_wb_dstReg(mem_wb_dstReg_out), .mem_wb_regWrite(mem_wb_regWrite_out), .ex_mem_memWrite(ex_mem_memWrite_out), .fwd_ex_to_ex_srcReg1(fwd_ex_to_ex_srcReg1), .fwd_ex_to_ex_srcReg2(fwd_ex_to_ex_srcReg2), .fwd_mem_to_ex_srcReg1(fwd_mem_to_ex_srcReg1), .fwd_mem_to_ex_srcReg2(fwd_mem_to_ex_srcReg2), .fwd_mem_to_mem(fwd_mem_to_mem));

////////////////////////
//  HAZARD DETECTION  //
////////////////////////
wire stall_en, rst_id_ex_reg;
assign rst_id_ex_reg = (~rst_n | stall_en);
Hazard_Detection_Unit hazard_unit(.stall_en(stall_en), .dec_opcode(dec_instr[15:12]), .id_ex_dstReg_out(id_ex_dstReg_out), .srcReg1(srcReg1), .srcReg2(srcReg2), .id_ex_memRead_in(id_ex_memRead_in), .id_ex_memRead_out(id_ex_memRead_out));

////////////////////////
// PIPELINE REGISTERS //
////////////////////////
Fetch_Decode_Reg IF_ID_Reg(.clk(clk), .rst_n(rst_n), .stall_en(stall_en), .pc_add_in(pc_plus_2), .pc_add_out(if_id_pc_add_2_out), .instr_in(instr), .instr_out(dec_instr));
Decode_Execute_Reg ID_EX_Reg(.clk(clk), .rst_n(~rst_id_ex_reg), .stall_en(stall_en), .rd1_in(id_ex_data1_in), .rd2_in(id_ex_data2_in), .rd1_out(id_ex_rd1_out), .rd2_out(id_ex_rd2_out), .sign_ext_in(dec_ex_sign_ext_alu_offset_in), .sign_ext_out(dec_ex_sign_ext_alu_offset_out), .dstReg_in(id_ex_dstReg_in), .dstReg_out(id_ex_dstReg_out), .srcReg1_in(srcReg1), .srcReg1_out(id_ex_srcReg1_out),.srcReg2_in(srcReg2), .srcReg2_out(id_ex_srcReg2_out),.is_LLB_or_LHB_in(is_LLB_or_LHB),.is_LLB_or_LHB_out(id_ex_is_LLB_or_LHB_out));
Execute_Memory_Reg EX_MEM_Reg(.clk(clk), .rst_n(rst_n), .zero_in(), .zero_out(), .alu_result_in(ex_mem_alu_result_in), .alu_result_out(ex_mem_alu_result_out), .dataIn_in(ex_mem_dataIn_in), .dataIn_out(ex_mem_dataIn_out), .dstReg_in(id_ex_dstReg_out), .dstReg_out(ex_mem_dstReg_out),.srcReg1_in(id_ex_srcReg1_out),.srcReg1_out(ex_mem_srcReg1_out),.srcReg2_in(id_ex_srcReg2_out),.srcReg2_out(ex_mem_srcReg2_out));
Memory_WriteBack_Reg MEM_WB_Reg(.clk(clk), .rst_n(rst_n), .read_data_in(mem_wb_read_memData_in), .read_data_out(mem_wb_read_data_out), .alu_result_in(ex_mem_alu_result_out), .alu_result_out(mem_wb_alu_result_out), .dstReg_in(ex_mem_dstReg_out), .dstReg_out(mem_wb_dstReg_out));

/////////////////////
//     FETCH	   //
/////////////////////
PC_Register pc_register(.clk(clk), .rst(~rst_n), .stall_en(stall_en), .next_pc(next_pc_or_halt), .pc_out(pc_out));
memory1c instruction_mem(.clk(clk), .rst(~rst_n), .data_out(instr), .data_in(16'h0000), .addr(pc_out), .enable(rst_n), .wr(1'b0));
adder_16bit pc_add_2_module(.A(pc_out), .B(16'h0002), .Sub(1'b0), .Sum(pc_plus_2), .Zero(), .Ovfl(), .Sign());

assign PCSrc = (dec_instr[15:12] == 4'hC | dec_instr[15:12] == 4'hD); // true if instr is a B or BR
assign next_pc = (PCSrc) ? pc_with_branch : pc_plus_2;
assign next_pc_or_halt = hlt ? pc_out : next_pc;

/////////////////////
//       ID	   //
/////////////////////
EX_Register ID_EX_Ex(.clk(clk), .rst(rst_id_ex_reg), .stall_en(stall_en), .ALUSrc_in(id_ex_aluSrc_in), .ALUOp_in(id_ex_aluOp_in), .ALUSrc_out(id_ex_aluSrc_out), .ALUOp_out(id_ex_aluOp_out));
M_Register ID_EX_Mem(.clk(clk), .rst(rst_id_ex_reg), .stall_en(stall_en), .MemRead_in(id_ex_memRead_in), .MemWrite_in(id_ex_memWrite_in), .MemRead_out(id_ex_memRead_out), .MemWrite_out(id_ex_memWrite_out));
WB_Register ID_EX_WriteBack(.clk(clk), .rst(rst_id_ex_reg), .stall_en(stall_en), .RegWrite_in(id_ex_regWrite_in), .MemToReg_in(id_ex_memToReg_in), .RegWrite_out(id_ex_regWrite_out), .MemToReg_out(id_ex_memToReg_out));

//Halt logic
//dff halt_signal(.q(hlt), .d(1'b1), .wen(isHaltInstr), .clk(clk), .rst(~rst_n));
assign hlt = &dec_instr[15:12];

assign is_LLB_or_LHB = (dec_instr[15:13]==3'b101);
assign id_ex_dstReg_in = dec_instr[11:8];
assign srcReg1 = is_LLB_or_LHB ? dec_instr[11:8] : dec_instr[7:4];
assign srcReg2 = id_ex_memWrite_in ? dec_instr[11:8] : dec_instr[3:0]; // if instr is SW, as per diagram, srcReg2's value will be stored

// ALU
assign id_ex_aluSrc_in = dec_instr[15] & ~is_LLB_or_LHB; //  0: ALU instr's [0,7] 1: Memory & Control instr [8,15] except for LLB and LHB
assign id_ex_aluOp_in = (id_ex_memRead_in | id_ex_memWrite_in) ? 4'h0 : dec_instr[15:12]; // If instr is SW or LW, tell ALU to do an Add, otherwise give the instr[15:12] aka the opcode

//Control logic
assign pc_control_immediate = instr[8:0];
assign ccc = dec_instr[11:9];
assign dec_ex_sign_ext_alu_offset_in =  { {11{dec_instr[3]}}, dec_instr[3:0], 1'b0};
assign dec_pc_imm_shftd_sign_ext = {{6{dec_instr[8]}}, dec_instr[8:0], 1'b0};
assign address_to_add_to_pc_for_b_or_br = (dec_instr[15:12] == 4'b1100) ? dec_pc_imm_shftd_sign_ext : ((dec_instr[15:12] == 4'b1101) ? srcData1 : 16'hFFFF); // 1100=branch, 1101=branch_register

//  16'hFFFF is a default case and the value of the sum is not use

//Memory

assign id_ex_data1_in = srcData1;								// Otherwise, use register file data unmodified

assign id_ex_data2_in = (dec_instr[15:12] == 4'b1010) ? {8'b0, dec_instr[7:0]} :		// Use byte from instruction for LLB
			(dec_instr[15:12] == 4'b1011) ? {dec_instr[7:0], 8'b0} :		// Use byte from instruction for LHB
			(dec_instr[15:13] == 3'b010) | (dec_instr[15:12] == 4'b0110) ? 
							{12'b0, dec_instr[3:0]} :		// Use 4-bit value for SLL, SRA, ROR
			srcData2;								// Otherwise, use register file data unmodified

assign id_ex_memRead_in = dec_instr[15:12] == 4'h8; //LW
assign id_ex_memWrite_in = dec_instr[15:12] == 4'h9; //SW
											
//WriteBack

//TODO SHOULD LHB/LLB be here?
// If a reg value must be updated
assign id_ex_regWrite_in =  ~dec_instr[15] | //ALU Op 
				id_ex_memRead_in|//LW
				is_LLB_or_LHB; //LLB or LHB
//Mux selector if value should come from memory or alu result		
assign id_ex_memToReg_in = id_ex_memRead_in; // 0:Alu op , 1:SW(only instr to write to reg from memory)

assign regWrite_or_halt = hlt ? 1'b0 : ex_mem_memWrite_out; // if hlt, do not write to regs
					
adder_16bit pc_add_imm_module(.A(if_id_pc_add_2_out), .B(address_to_add_to_pc_for_b_or_br), .Sub(1'b0), .Sum(pc_with_branch), .Zero(), .Ovfl(), .Sign());
RegisterFile regFile(.clk(clk), .rst(~rst_n), .SrcReg1(srcReg1), .SrcReg2(srcReg2), .DstReg(mem_wb_dstReg_out), .WriteReg(mem_wb_regWrite_out), .DstData(writeback_write_data), .SrcData1(srcData1), .SrcData2(srcData2));


/////////////////////
//       EX	   //
/////////////////////
M_Register EX_MEM_Mem(.clk(clk), .rst(~rst_n), .stall_en(1'b0), .MemRead_in(id_ex_memRead_out), .MemWrite_in(id_ex_memWrite_out), .MemRead_out(ex_mem_memRead_out), .MemWrite_out(ex_mem_memWrite_out));
WB_Register EX_MEM_WriteBack(.clk(clk), .rst(~rst_n), .stall_en(1'b0), .RegWrite_in(id_ex_regWrite_out), .MemToReg_in(id_ex_memToReg_out), .RegWrite_out(ex_mem_regWrite_out), .MemToReg_out(ex_mem_memToReg_out));

assign aluSrc1_ex_to_ex_fwd = (fwd_ex_to_ex_srcReg1) ? ex_mem_alu_result_out : id_ex_rd1_out;
assign aluSrc1_mem_to_ex_fwd = (fwd_mem_to_ex_srcReg1) ? writeback_write_data : aluSrc1_ex_to_ex_fwd;

assign aluSrc2_no_fwd = (id_ex_aluSrc_out) ? dec_ex_sign_ext_alu_offset_out : id_ex_rd2_out;
assign aluSrc2_ex_to_ex_fwd = (fwd_ex_to_ex_srcReg2 & ~id_ex_is_LLB_or_LHB_out & ~id_ex_memRead_out & ~id_ex_memWrite_out) ? ex_mem_alu_result_out : aluSrc2_no_fwd;
assign aluSrc2_mem_to_ex_fwd = (fwd_mem_to_ex_srcReg2 & ~id_ex_is_LLB_or_LHB_out & ~id_ex_memRead_out & ~id_ex_memWrite_out) ? writeback_write_data : aluSrc2_ex_to_ex_fwd;

assign aluSrc1 = aluSrc1_mem_to_ex_fwd;
assign aluSrc2 = aluSrc2_mem_to_ex_fwd;

ALU alu_module(.Opcode(id_ex_aluOp_out), .Input1(aluSrc1), .Input2(aluSrc2), .Output(ex_mem_alu_result_in), .flagsOut(flags));

assign ex_mem_dataIn_in = id_ex_rd2_out; //as per zybooks diagram, value of reg2 from dec/ex pipeline should be used as the data in

/////////////////////
//       MEM	   //
/////////////////////

//TODO is memRead ever used? Also, since enable is a thing, if we used original signal(ex_mem_memWrite_out), will mem unit still work correctly?

assign memEnable = ~hlt & (ex_mem_memRead_out | ex_mem_memWrite_out); // instr must be a read or write (& not a halt)
assign data_mem_data_in = (fwd_mem_to_mem) ? writeback_write_data : ex_mem_dataIn_out;

memory1c data_mem(.clk(clk), .rst(~rst_n), .data_out(mem_wb_read_memData_in), .data_in(data_mem_data_in), .addr(ex_mem_alu_result_out), .enable(memEnable), .wr(ex_mem_memWrite_out));

WB_Register MEM_WB_WriteBack(.clk(clk), .rst(~rst_n), .stall_en(1'b0), .RegWrite_in(ex_mem_regWrite_out), .MemToReg_in(ex_mem_memToReg_out), .RegWrite_out(mem_wb_regWrite_out), .MemToReg_out(mem_wb_memToReg_out));
assign writeback_write_data = (mem_wb_memToReg_out) ? mem_wb_read_data_out : mem_wb_alu_result_out;

endmodule

