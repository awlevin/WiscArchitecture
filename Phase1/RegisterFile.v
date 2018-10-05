module RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData, SrcData1, SrcData2);

input clk, rst;
input [3:0] SrcReg1, SrcReg2, DstReg;
input WriteReg;
input [15:0] DstData;

inout [15:0] SrcData1, SrcData2;

wire [15:0] decDstReg, decSrcReg1, decSrcReg2;

WriteDecoder_4_16 DstDec(.RegId(DstReg), .WriteReg(WriteReg), .Wordline(decDstReg));

ReadDecoder_4_16 Reg1Dec(.RegId(SrcReg1), .Wordline(decSrcReg1)),
		 Reg2Dec(.RegId(SrcReg2), .Wordline(decSrcReg2));

Register r0(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[0]), .ReadEnable1(decSrcReg1[0]), .Readenable2(decSrcReg2[0]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r1(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[1]), .ReadEnable1(decSrcReg1[1]), .Readenable2(decSrcReg2[1]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r2(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[2]), .ReadEnable1(decSrcReg1[2]), .Readenable2(decSrcReg2[2]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r3(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[3]), .ReadEnable1(decSrcReg1[3]), .Readenable2(decSrcReg2[3]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r4(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[4]), .ReadEnable1(decSrcReg1[4]), .Readenable2(decSrcReg2[4]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r5(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[5]), .ReadEnable1(decSrcReg1[5]), .Readenable2(decSrcReg2[5]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r6(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[6]), .ReadEnable1(decSrcReg1[6]), .Readenable2(decSrcReg2[6]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r7(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[7]), .ReadEnable1(decSrcReg1[7]), .Readenable2(decSrcReg2[7]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r8(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[8]), .ReadEnable1(decSrcReg1[8]), .Readenable2(decSrcReg2[8]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r9(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[9]), .ReadEnable1(decSrcReg1[9]), .Readenable2(decSrcReg2[9]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r10(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[10]), .ReadEnable1(decSrcReg1[10]), .Readenable2(decSrcReg2[10]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r11(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[11]), .ReadEnable1(decSrcReg1[11]), .Readenable2(decSrcReg2[11]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r12(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[12]), .ReadEnable1(decSrcReg1[12]), .Readenable2(decSrcReg2[12]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r13(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[13]), .ReadEnable1(decSrcReg1[13]), .Readenable2(decSrcReg2[13]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r14(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[14]), .ReadEnable1(decSrcReg1[14]), .Readenable2(decSrcReg2[14]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r15(.clk(clk), .rst(rst), .D(DstData), .WriteReg(decDstReg[15]), .ReadEnable1(decSrcReg1[15]), .Readenable2(decSrcReg2[15]), .Bitline1(SrcData1), .Bitline2(SrcData2));

endmodule


module Register(clk, rst, D, WriteReg, ReadEnable1, Readenable2, Bitline1, Bitline2);

input clk, rst;
input [15:0] D;
input WriteReg, ReadEnable1, Readenable2;

inout [15:0] Bitline1, Bitline2;

BitCell b0(.clk(clk), .rst(rst), .D(D[0]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[0]), .Bitline2(Bitline2[0])),
	b1(.clk(clk), .rst(rst), .D(D[1]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[1]), .Bitline2(Bitline2[1])),
	b2(.clk(clk), .rst(rst), .D(D[2]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[2]), .Bitline2(Bitline2[2])),
	b3(.clk(clk), .rst(rst), .D(D[3]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[3]), .Bitline2(Bitline2[3])),
	b4(.clk(clk), .rst(rst), .D(D[4]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[4]), .Bitline2(Bitline2[4])),
	b5(.clk(clk), .rst(rst), .D(D[5]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[5]), .Bitline2(Bitline2[5])),
	b6(.clk(clk), .rst(rst), .D(D[6]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[6]), .Bitline2(Bitline2[6])),
	b7(.clk(clk), .rst(rst), .D(D[7]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[7]), .Bitline2(Bitline2[7])),
	b8(.clk(clk), .rst(rst), .D(D[8]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[8]), .Bitline2(Bitline2[8])),
	b9(.clk(clk), .rst(rst), .D(D[9]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[9]), .Bitline2(Bitline2[9])),
	b10(.clk(clk), .rst(rst), .D(D[10]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[10]), .Bitline2(Bitline2[10])),
	b11(.clk(clk), .rst(rst), .D(D[11]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[11]), .Bitline2(Bitline2[11])),
	b12(.clk(clk), .rst(rst), .D(D[12]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[12]), .Bitline2(Bitline2[12])),
	b13(.clk(clk), .rst(rst), .D(D[13]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[13]), .Bitline2(Bitline2[13])),
	b14(.clk(clk), .rst(rst), .D(D[14]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[14]), .Bitline2(Bitline2[14])),
	b15(.clk(clk), .rst(rst), .D(D[15]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1),
		.ReadEnable2(ReadEnable2), .Bitline1(Bitline1[15]), .Bitline2(Bitline2[15]));

endmodule


module BitCell(clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2, Bitline1, Bitline2);

input clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2;

inout Bitline1, Bitline2;

wire Q;

dff flop(.q(Q), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));

assign Bitline1 = ReadEnable1 ? Q : 1'bz;
assign Bitline2 = ReadEnable2 ? Q : 1'bz;

endmodule


module WriteDecoder_4_16(RegId, WriteReg, Wordline);

input [3:0] RegId;
input WriteReg;

output [15:0] Wordline;

assign Wordline = WriteReg ?
			RegId[3] ?
				RegId[2] ?
					RegId[1] ?
						RegId[0] ? 16'h8000 : 16'h4000
					:	RegId[0] ? 16'h2000 : 16'h1000
				:	RegId[1] ?
						RegId[0] ? 16'h0800 : 16'h0400
					:	RegId[0] ? 16'h0200 : 16'h0100
			:	RegId[2] ?
					RegId[1] ?
						RegId[0] ? 16'h0080 : 16'h0040
					:	RegId[0] ? 16'h0020 : 16'h0010
				:	RegId[1] ?
						RegId[0] ? 16'h0008 : 16'h0004
					:	RegId[0] ? 16'h0002 : 16'h0001
		: 16'bzzzzzzzzzzzzzzzz;

endmodule


module ReadDecoder_4_16(RegId, Wordline);

input [3:0] RegId;

output [15:0] Wordline;

assign Wordline = 	RegId[3] ?
				RegId[2] ?
					RegId[1] ?
						RegId[0] ? 16'h8000 : 16'h4000
					:	RegId[0] ? 16'h2000 : 16'h1000
				:	RegId[1] ?
						RegId[0] ? 16'h0800 : 16'h0400
					:	RegId[0] ? 16'h0200 : 16'h0100
			:	RegId[2] ?
					RegId[1] ?
						RegId[0] ? 16'h0080 : 16'h0040
					:	RegId[0] ? 16'h0020 : 16'h0010
				:	RegId[1] ?
						RegId[0] ? 16'h0008 : 16'h0004
					:	RegId[0] ? 16'h0002 : 16'h0001;

endmodule