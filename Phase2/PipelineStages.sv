module PipelineStages(clk,rst_n,
	srcReg1_in,srcReg2_in,dstReg_in,ccc_in,writeReg_in //Fetch
	srcReg1,srcReg2,dstReg,writeReg,dstData,srcData1,srcData2,ccc //Decode
	dstData_out,srcData1_out,srcData2_out //Execute
	); 

input clk;
input rst_n;

//memDataOut,memDataIn,address,dataEnable,dataWr

//Fetch Input/Output
input [15:0] srcReg1_in,srcReg2_in,dstReg_in;
input [2:0] ccc_in;
input writeReg_in;

//Decode Input/Output

input dstData,srcData1,srcData2
output [15:0] srcReg1,srcReg2,dstReg;
output [2:0] ccc;

//Execute Input/Output
output dstData_out,srcData1_out,srcData2_out

//Memory Input/Output
input [15:0]  memDataOut;
output [15:0] memDataIn,address;
output dataEnable,dataWr;

/////////////////////
//     Modules	   //
/////////////////////
Fetch fetchModule(.clk(clk),.rst_n(rst_n),.srcReg1_in(srcReg1_in),.srcReg2_in(srcReg2_in),.dstReg_in(dstReg_in),.writeReg_in(writeReg_in));
Decode fetchModule();
Execute fetchModule();
Memory fetchModule();
Execute fetchModule();

endmodule

module Fetch(clk,rst_n,srcReg1_in,srcReg2_in,dstReg_in,writeReg_in);
input clk;
input rst_n;

//Fetch Input
input [15:0] srcReg1_in,srcReg2_in,dstReg_in;
input writeReg_in;

//Decode Input
input dstData,srcData1,srcData2

//Execute Input


//Memory Input
input [15:0]  memDataOut;

endmodule

module Decode(clk,rst_n);
input clk;
input rst_n;

endmodule

module Execute(clk,rst_n);
input clk;
input rst_n;
output 

endmodule

module Memory(clk,rst_n);
input clk;
input rst_n;

endmodule

module WriteBack(clk,rst_n);
input clk;
input rst_n;

endmodule



