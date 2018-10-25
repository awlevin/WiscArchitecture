
module RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData, SrcData1, SrcData2);

input clk;
input rst;
input [3:0] SrcReg1, SrcReg2, DstReg;
input WriteReg;
input [15:0] DstData;
output [15:0] SrcData1, SrcData2;

wire [15:0] read_sel_1, read_sel_2, write_sel; // 1-hot selectors


ReadDecoder_4_16 read_decoder1(.RegId(SrcReg1), .Wordline(read_sel_1));
ReadDecoder_4_16 read_decoder2(.RegId(SrcReg2), .Wordline(read_sel_2));
WriteDecoder_4_16 write_decoder(.RegId(DstReg), .WriteReg(WriteReg), .Wordline(write_sel));

Register r0(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[0]), .ReadEnable1(read_sel_1[0]), .ReadEnable2(read_sel_2[0]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r1(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[1]), .ReadEnable1(read_sel_1[1]), .ReadEnable2(read_sel_2[1]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r2(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[2]), .ReadEnable1(read_sel_1[2]), .ReadEnable2(read_sel_2[2]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r3(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[3]), .ReadEnable1(read_sel_1[3]), .ReadEnable2(read_sel_2[3]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r4(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[4]), .ReadEnable1(read_sel_1[4]), .ReadEnable2(read_sel_2[4]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r5(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[5]), .ReadEnable1(read_sel_1[5]), .ReadEnable2(read_sel_2[5]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r6(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[6]), .ReadEnable1(read_sel_1[6]), .ReadEnable2(read_sel_2[6]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r7(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[7]), .ReadEnable1(read_sel_1[7]), .ReadEnable2(read_sel_2[7]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r8(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[8]), .ReadEnable1(read_sel_1[8]), .ReadEnable2(read_sel_2[8]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r9(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[9]), .ReadEnable1(read_sel_1[9]), .ReadEnable2(read_sel_2[9]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r10(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[10]), .ReadEnable1(read_sel_1[10]), .ReadEnable2(read_sel_2[10]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r11(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[11]), .ReadEnable1(read_sel_1[11]), .ReadEnable2(read_sel_2[11]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r12(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[12]), .ReadEnable1(read_sel_1[12]), .ReadEnable2(read_sel_2[12]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r13(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[13]), .ReadEnable1(read_sel_1[13]), .ReadEnable2(read_sel_2[13]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r14(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[14]), .ReadEnable1(read_sel_1[14]), .ReadEnable2(read_sel_2[14]), .Bitline1(SrcData1), .Bitline2(SrcData2)),
	 r15(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_sel[15]), .ReadEnable1(read_sel_1[15]), .ReadEnable2(read_sel_2[15]), .Bitline1(SrcData1), .Bitline2(SrcData2));

endmodule
