module PipelineStages(clk,rst_n); 

input clk, rst_n;

parameter PCSrc_bit = 5;


// PC Wires
wire [15:0] next_pc, pc_out, pc_plus_2, ex_mem_pc_out;

// Instruction
wire [15:0] instr;

// Control Signals
wire PCSrc, RegWrite, MemToReg;

// Decode Wires
wire [15:0] decode_pc_add_out, decode_instr, write_data;

// Writeback Wires
wire [3:0] writeback_write_reg;
wire [15:0] writeback_write_data;

Fetch_Decode_Reg fetch_decode_reg(.clk(clk), .rst_n(rst_n), .pc_add_in(pc_plus_2), .pc_add_out(decode_pc_add_out), .instr_in(instr), .instr_out(decode_instr));
Decode_Execute_Reg decode_execute_reg(.clk(clk), .rst_n(rst_n), .rd1_in(), .rd2_in(), .rd1_out(), .rd2_out(), .sign_ext_in(), .sign_ext_out(), .pc_add_in(decode_pc_add_in), .pc_add_out(decode_pc_add_out));
Execute_Memory_Reg execute_memory_reg(.clk(clk), .rst_n(rst_n), .add_result_in(), .add_result_out(ex_mem_pc_out), .zero_in(), .zero_out(), .alu_result_in(), .alu_result_out(), .rd2_in(), .rd2_out());
Memory_WriteBack_Reg memory_writeback_reg(.clk(clk), .rst_n(rst_n), .read_data_in(), .read_data_out(), .alu_result_in(), .alu_result_out(), .write_data_in(), .write_data_out());

/////////////////////
//     FETCH	   //
/////////////////////
PC_Register pc_register(.clk(clk), .rst(~rst_n), .next_pc(next_pc), .pc_out(pc_out));
memory1c instruction_mem(.clk(clk), .rst(~rst_n), .data_out(instr), .data_in(16'h0000), .addr(pc), .enable(rst_n), .wr(1'b0));
adder_16bit add_2_module(.A(pc_out), .B(16'h0002), .Sub(1'b0), .Sum(pc_plus_2), .Zero(), .Ovfl(), .Sign());

assign next_pc = (PCSrc) ? ex_mem_pc_out : pc_plus_2;

/////////////////////
//       ID	   //
/////////////////////
RegisterFile regFile(.clk(clk), .rst(~rst_n), .SrcReg1(decode_instr[7:4]), .SrcReg2(decode_instr[3:0]), .DstReg(decode_instr[11:8]), .WriteReg(writeback_write_reg), .DstData(writeback_write_data), .SrcData1(srcData1), .SrcData2(srcData2));
//assign RegWrite = 

/////////////////////
//       EX	   //
/////////////////////

/////////////////////
//       MEM	   //
/////////////////////

endmodule



