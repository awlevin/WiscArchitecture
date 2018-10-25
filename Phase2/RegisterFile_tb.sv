
module RegisterFile_tb();

logic clk, rst, writeReg;
logic [3:0] srcReg1, srcReg2, dstReg;
wire [15:0] srcData1, srcData2;
logic [15:0] dstData;

logic [15:0] dataOut;

RegisterFile iDUT(.clk(clk), .rst(rst), .SrcReg1(srcReg1), .SrcReg2(srcReg2), .DstReg(dstReg), .WriteReg(writeReg), .DstData(dstData), .SrcData1(srcData1), .SrcData2(srcData2));

initial begin

clk = 0;
rst = 1;

// wait 2 clock cycles before starting tests
repeat(2) @(posedge clk);

rst = 0; // turn off reset

SetRegister(0, 16'hABCD);
SetRegister(1, 16'hBFF0);
CheckRegisters(0, 1, 16'hABCD, 16'hBFF0);

SetRegister(0, 16'hBEAD);
SetRegister(3, 16'hACDC);
SetRegister(5, 16'hFEED);
CheckRegisters(0, 3, 16'hBEAD, 16'hACDC);
CheckRegisters(1, 5, 16'hBFF0, 16'hFEED);

$stop;
end

// CLOCK
always #5 clk = ~clk;



task SetRegister(logic [3:0] Register, logic [15:0] Value);

dstReg = Register;
dstData = Value;

@(posedge clk) writeReg = 1;

@(posedge clk) writeReg = 0;

endtask

task CheckRegisters(logic [3:0] Reg1, logic [3:0] Reg2, logic [15:0] ExpectedData1, logic [15:0] ExpectedData2);

logic [15:0] RegData1, RegData2;

repeat(1) @(posedge clk);

srcReg1 = Reg1;
srcReg2 = Reg2;

@(posedge clk);

@(negedge clk) begin
	RegData1 = srcData1;
	RegData2 = srcData2;
end

if ((RegData1 !== ExpectedData1) || (RegData2 !== ExpectedData2)) $write("INCORRECT - ");
else $write("CORRECT - ");

$display("Reg1=%h, Reg2=%h, ActualData1=%h, ActualData2=%h, ExpectedData1=%h, ExpectedData2=%h", Reg1, Reg2, RegData1, RegData2, ExpectedData1, ExpectedData2);

endtask

endmodule
