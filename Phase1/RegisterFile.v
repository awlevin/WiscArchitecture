
module RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData, SrcData1, SrcData2);

input clk;
input rst;
input [3:0] SrcReg1, SrcReg2, DstReg;
input WriteReg;
input [15:0] DstData;
inout [15:0] SrcData1, SrcData2;

wire [15:0] read_sel_1, read_sel_2; // 1-hot selectors


ReadDecoder_4_16 read_decoder1(.RegId(SrcReg1), .Wordline(read_sel_1));
ReadDecoder_4_16 read_decoder2(.RegId(SrcReg2), .Wordline(read_sel_2));
WriteDecoder_4_16 write_decoder(.RegId(DstReg), .WriteReg(WriteReg), .Wordline(DstData));

Register r0(.clk(clk), .rst(rst), .D(DstData[0]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[0]), .Bitline2(SrcData2[0]));
Register r1(.clk(clk), .rst(rst), .D(DstData[1]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[1]), .Bitline2(SrcData2[1]));
Register r2(.clk(clk), .rst(rst), .D(DstData[2]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[2]), .Bitline2(SrcData2[2]));
Register r3(.clk(clk), .rst(rst), .D(DstData[3]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[3]), .Bitline2(SrcData2[3]));
Register r4(.clk(clk), .rst(rst), .D(DstData[4]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[4]), .Bitline2(SrcData2[4]));
Register r5(.clk(clk), .rst(rst), .D(DstData[5]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[5]), .Bitline2(SrcData2[5]));
Register r6(.clk(clk), .rst(rst), .D(DstData[6]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[6]), .Bitline2(SrcData2[6]));
Register r7(.clk(clk), .rst(rst), .D(DstData[7]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[7]), .Bitline2(SrcData2[7]));
Register r8(.clk(clk), .rst(rst), .D(DstData[8]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[8]), .Bitline2(SrcData2[8]));
Register r9(.clk(clk), .rst(rst), .D(DstData[9]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[9]), .Bitline2(SrcData2[9]));
Register r10(.clk(clk), .rst(rst), .D(DstData[10]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[10]), .Bitline2(SrcData2[10]));
Register r11(.clk(clk), .rst(rst), .D(DstData[11]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[11]), .Bitline2(SrcData2[11]));
Register r12(.clk(clk), .rst(rst), .D(DstData[12]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[12]), .Bitline2(SrcData2[12]));
Register r13(.clk(clk), .rst(rst), .D(DstData[13]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[13]), .Bitline2(SrcData2[13]));
Register r14(.clk(clk), .rst(rst), .D(DstData[14]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[14]), .Bitline2(SrcData2[14]));
Register r15(.clk(clk), .rst(rst), .D(DstData[15]), .WriteReg(WriteReg), .ReadEnable1(read_sel_1), .ReadEnable2(read_sel_2), .Bitline1(SrcData1[15]), .Bitline2(SrcData2[15]));

endmodule
