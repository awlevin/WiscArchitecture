module cpu_tb();

reg clk, rst_n, hlt;
reg [15:0] pc;

cpu iDUT(.clk(clk), .rst_n(rst_n), .hlt(hlt), .pc(pc));

logic [15:0] instruction;
logic [15:0] Output;

//initial begin
//clk = 0;
//rst_n = 0;
//
//force iDUT.instr = 16'h0000;
//#20 rst_n = 1;
//
//SetRegister(4, 16'd16);
//SetRegister(5, 16'd3);
//CheckRegisters(4, 5, 16'd16, 16'd3);
///*
//repeat (100) begin
//
//	Do_ALU_Instruction();
//	
//	#10;
//	release iDUT.instr;
//end
//*/
//
//$stop;
//end
//

initial begin

clk = 0;
rst_n = 0;

repeat(2) @(posedge clk);

@(posedge clk) rst_n = 1;

repeat(20) @(posedge clk);

$stop;

end

always #5 clk = ~clk;


task Create_Instruction;
	instruction = $random;
endtask

task Do_ALU_Intstruction(logic [3:0] op, logic [3:0] rd, logic [3:0] rs, logic [3:0] rt_imm, logic [15:0] expectedOutput);

@(posedge clk)
force iDUT.instr = {op, rd, rs, rt_imm};

@(negedge clk)
begin
	$display("Op=%h, Rd=%h, Rs=%h, Rt/Imm=%h",op,rd,rs,rt_imm);
	$display("Our output=%h, Expected=%h", iDUT.aluOut, expectedOutput);
end

endtask

task SetRegister(logic [3:0] Register, logic [15:0] Value);

force iDUT.dstReg = Register;
force iDUT.dstData = Value;

@(posedge clk) force iDUT.writeReg = 1;

@(negedge clk) force iDUT.writeReg = 0;

endtask

task CheckRegisters(logic [3:0] Reg1, logic [3:0] Reg2, logic [15:0] ExpectedData1, logic [15:0] ExpectedData2);

logic [15:0] RegData1, RegData2;

repeat(1) @(posedge clk);

force iDUT.srcReg1 = Reg1;
force iDUT.srcReg2 = Reg2;

@(posedge clk);

@(negedge clk) begin
	RegData1 = iDUT.srcData1;
	RegData2 = iDUT.srcData2;
end

if ((RegData1 !== ExpectedData1) || (RegData2 !== ExpectedData2)) $write("INCORRECT - ");
else $write("CORRECT - ");

$display("Reg1=%d, Reg2=%d, ActualData1=%h, ActualData2=%h, ExpectedData1=%d, ExpectedData2=%d", Reg1, Reg2, RegData1, RegData2, ExpectedData1, ExpectedData2);

endtask

endmodule
