module CPU(clk, rst_n, hlt, pc);

input clk, rst_n;
output hlt;
output wire [15:0] pc;

/////////////////////
// Local Variables //
/////////////////////

// The current instruction
wire [15:0] instr; // bits [15:12] are the opcode

// Register Vars
reg [3:0] srcReg1, srcReg2, dstReg;
reg writeReg; // 1=write, 0=don't write
reg [15:0] srcData1, srcData2, dstData;

// ALU Vars
reg [15:0] aluIn1, aluIn2, aluOut;
reg [2:0] aluFlagsIn, aluFlagsOut;
reg [3:0] aluOp;

// Memory Vars
reg [15:0] offset;
reg [15:0] address, memDataIn, memDataOut;
reg dataWr, dataEnable;


/////////////////////
//     Modules	   //
/////////////////////

// Memory Modules
memory1c inst_mem(.clk(clk), .rst(rst_n), .data_out(), .data_in(), .addr(), .enable(), .wr());
memory1c data_mem(.clk(clk), .rst(rst_n), .data_out(memDataOut), .data_in(memDataIn), .addr(address), .enable(dataEnable), .wr(dataWr));

// Registers
RegisterFile(.clk(clk), .rst(rst_n), .SrcReg1(srcReg1), .SrcReg2(srcReg2), .DstReg(dstReg), .WriteReg(writeReg), .DstData(dstData), .SrcData1(srcData1), .SrcData2(srcData2));

// ALU Module
ALU alu(.Opcode(aluOp), .Input1(aluIn1), .Input2(aluIn2), .Output(aluOut), .flagsIn(aluFlagsIn), .flagsOut(aluFlagsOut));


// Update or reset PC if necessary
assign pc = (~rst_n) ? 16'h0000 : pc; // TODO: bad latch here?

always @(*) 
case(instr[15:12])
/*ADD*/	4'b0000 : 
	begin 
		// Parse the instruction, set RegisterFile to read correctly
		dstReg = instr[11:8]; 
		srcReg1 = instr[7:4]; 
		srcReg2 = instr[3:0];
		// Set inputs for ALU based on RegisterFile outputs 
		aluOp = instr[15:12];
		aluIn1 = srcData1;
		aluIn2 = srcData2;
		dstData = aluOut;
		writeReg=1; 
	end
/*SUB*/	4'b0001 : begin  end  
/*XOR*/	4'b0010 : begin  end  
	4'b0011 : begin  end // RED
	4'b0100 : begin  end // SLL
	4'b0101 : begin  end // SRA
	4'b0110 : begin  end // ROR
	4'b0111 : begin  end // PADDSB
/*LW*/	4'b1000 : 
	begin
		// Parse instruction
		dstReg = instr[11:8];
		srcReg1 = instr[7:4];
		offset[15:0] = { {11{instr[3]}}, instr[3:0], 1'b0}; // TODO: (feel like there'll be a bug here) Phase 1 instructions specify "oooo is the offset in two's complement but right-shifted by 1 bit." So we should shift it left again?
		
		// Send base and offset to ALU
		aluOp = 4'b0000; // tell ALU to do an ADD -- TODO: does it matter if this is before the ALU inputs are set?
		aluIn1 = srcData1;
		aluIn2 = offset;
		address = aluOut;
		dataEnable = 1; // Enable=1 and Wr=1 --> data_out=M[addr] 
		dataWr = 0;	// Enable=1 and Wr=1 --> data_out=M[addr]
		dstData = memDataOut; // The output of memData module is the M[addr] value we want to store to a register
		writeReg = 1; // Write the data to the destination register
	end 
/*SW*/	4'b1001 : 
	begin 
		srcReg1 = instr[11:8];
		srcReg2 = instr[7:4]; // add data in this register to immediate offset
		offset[15:0] = { {11{instr[3]}}, instr[3:0], 1'b0};
		
		aluOp = 4'b0000;
		aluIn1 = srcData2; // add data in this register output to the immediate offset
		aluIn2 = offset;
		address = aluOut;
		memDataIn = srcData1;
		dataEnable = 1;
		dataWr = 1;
	end
	4'b1010 : begin  end // LLB
	4'b1011 : begin  end // LHB
	4'b1100 : begin  end // B
	4'b1101 : begin  end // BR
	4'b1110 : begin  end // PCS
	4'b1111 : begin  end // HLT
	default : begin writeReg = 0; dataEnable = 0; dataWr = 0; end // DEFAULT
endcase 

endmodule

