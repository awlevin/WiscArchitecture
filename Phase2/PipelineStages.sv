module EX_Register(clk, rst, ALUSrc_in, ALUOp_in, ALUSrc_out, ALUOp_out);
input clk,rst;
input ALUSrc_in;
input [3:0] ALUOp_in;

output ALUSrc_out;
output [3:0] ALUOp_out; 

dff 		ALUSrc(.q(ALUSrc_out), .d(ALUSrc_in), .wen(1'b1), .clk(clk), .rst(rst));
dff_4bit	ALUOp(.q(ALUOp_out),  .d(ALUOp_in), .wen(1'b1), .clk(clk), .rst(rst));


endmodule

module M_Register(clk, rst, MemRead_in, MemWrite_in, MemRead_out, MemWrite_out);
input clk,rst;
input MemRead_in,MemWrite_in;

output MemRead_out, MemWrite_out;

dff 	MemRead(.q(MemRead_out), .d(MemRead_in), .wen(1'b1), .clk(clk), .rst(rst)),
	MemWrite(.q(MemWrite_out), .d(MemWrite_in), .wen(1'b1), .clk(clk), .rst(rst));

endmodule

module WB_Register(clk, rst, RegWrite_in, MemToReg_in, RegWrite_out, MemToReg_out);
input clk,rst;
input RegWrite_in,MemToReg_in;

output RegWrite_out,MemToReg_out;

dff 	RegWrite(.q(RegWrite_out), .d(RegWrite_in), .wen(1'b1), .clk(clk), .rst(rst)),
	MemToReg(.q(MemToReg_out), .d(MemToReg_in), .wen(1'b1), .clk(clk), .rst(rst));

endmodule
