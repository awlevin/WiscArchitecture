module CPU(clk, rst_n, hlt, pc);

input clk, rst_n;
output hlt;
output wire [15:0] pc;

/////////////////////
// Local Variables //
/////////////////////

// Register Vars
reg [3:0] srcReg1, srcReg2, dstReg;
reg writeReg; // 1=write, 0=don't write
wire [15:0] srcData1, srcData2;
reg [15:0] dstData;

// ALU Vars
reg [15:0] aluIn1, aluIn2;
wire [15:0] aluOut;
wire [2:0] aluFlagsOut;
reg [3:0] aluOp;
reg [2:0] aluFlagsIn;
reg [2:0] aluFlags;

//LHB/LLB
reg [15:0] immediate;

// Memory Vars
reg [15:0] offset;
reg [15:0] address, memDataIn;
wire [15:0] memDataOut;
reg dataWr, dataEnable;

//Control Instr's
reg [15:0] nextPC;
reg takeBranch;
wire [15:0] instr,pc_plus_four_output,pc_plus_two_output,br_output; // bits [15:12] are the opcode
adder_16bit pc_plus_two    (.A(pc), .B(16'h0002), .Sub(1'b0), .Sum(pc_plus_two_output), .Zero(), .Ovfl(), .Sign()); // will always have the current PC + 2
adder_16bit branch_output  (.A(pc_plus_two_output), .B(immediate), .Sub(1'b0), .Sum(br_output), .Zero(), .Ovfl(), .Sign()); // will always have the current PC + 2

/////////////////////
//     Modules	   //
/////////////////////

// Memory Modules
memory1c inst_mem(.clk(clk), .rst(rst_n), .data_out(instr), .data_in(16'h0000), .addr(pc), .enable(1'b1), .wr(1'b0));
memory1c data_mem(.clk(clk), .rst(rst_n), .data_out(memDataOut), .data_in(memDataIn), .addr(address), .enable(dataEnable), .wr(dataWr));

// Registers
RegisterFile regFile(.clk(clk), .rst(rst_n), .SrcReg1(srcReg1), .SrcReg2(srcReg2), .DstReg(dstReg), .WriteReg(writeReg), .DstData(dstData), .SrcData1(srcData1), .SrcData2(srcData2));

// ALU Module
ALU alu(.Opcode(aluOp), .Input1(aluIn1), .Input2(aluIn2), .Output(aluOut), .flagsIn(aluFlagsIn), .flagsOut(aluFlagsOut));


// Update or reset PC if necessary
assign pc = (~rst_n) ? 16'h0000 : nextPC; // rst_n must be 0 for an entire clk cycle for reset to occur

always @(*) 
casex(instr[11:9])
//adderZFlag, adderVFlag, adderNFlag};
	//Not Equal(Z=0)
	3'b000:
	begin
		takeBranch =  ~aluFlagsOut[2];
	end
	//Equal(Z=1)
	3'b001:
	begin
		takeBranch =  aluFlagsOut[2];
	end
	//Greater Than(N=1)
	3'b010:
	begin
		takeBranch =  aluFlagsOut[0];
	end
	//Less Than(Z=N=0)
	3'b011:
	begin
		takeBranch =  aluFlagsOut[1] & aluFlagsOut[0];
	end
	//Greater Than or Equal (Z=1 or Z=N=0)
	3'b100:
	begin
		takeBranch =  aluFlagsOut[2] | (~aluFlagsOut[2] & ~aluFlagsOut[0]);
	end
	//Less Than or Equal (N=1 or Z=1)
	3'b101:
	begin
		takeBranch =  aluFlagsOut[2] | aluFlagsOut[0];
	end
	//Overflow(V=1)
	3'b110:
	begin
		takeBranch =  aluFlagsOut[1];
	end
	//Unconditional
	default
	begin 
		takeBranch = 1'b1;
	end

endcase

always @(*) 
casex(instr[15:12])

	/*ADD SUB XOR RED PADDSB */	
	4'b00xx,4'b0111 : 
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
		nextPC= pc_plus_two_output;
	end

	/*SLL SRA ROR */	
	4'b0100,4'b0101,4'b0110 : 
	begin 
		// Parse the instruction, set RegisterFile to read correctly
		dstReg = instr[11:8]; 
		srcReg1 = instr[7:4]; 
		// Set inputs for ALU based on RegisterFile outputs 
		aluOp = instr[15:12];
		aluIn1 = srcData1;
		aluIn2 = instr[3:0];
		dstData = aluOut;
		writeReg=1; 
		nextPC = pc_plus_two_output;
	end

	/* LW SW */	
	4'b100x : 
	begin
		// Parse instruction
		dstReg = instr[11:8];
		srcReg1 = instr[7:4]; // add data in this register to immediate offset
		offset = { {11{instr[3]}}, instr[3:0], 1'b0}; // TODO: (feel like there'll be a bug here) Phase 1 instructions specify "oooo is the offset in two's complement but right-shifted by 1 bit." So we should shift it left again?
		
		// Send base and offset to ALU
		aluOp = 4'b0000; // tell ALU to do an ADD -- TODO: does it matter if this is before the ALU inputs are set?
		aluIn1 = srcData1;
		aluIn2 = offset;
		address = aluOut;

		memDataIn = srcData1; //only used for mem writes
		dstData = memDataOut; // The output of memData module is the M[addr] value we want to store to a register

		dataEnable = 1'b1;    // Enable=1 and Wr=1 --> data_out=M[addr] 
		dataWr = instr[8]; //LW = 4'b1000 SW = 4'b10001, so last bit of the instruction corresponds to the write data

		writeReg = ~instr[8]; // Write the data to the destination register, with opposite logic to dataWr
		nextPC = pc_plus_two_output;
	end 
	/* LLB LHB */
	4'b101x : 
	begin  
		// Parse instruction
		dstReg = instr[11:8];
		srcReg1 = instr[11:8]; // add data in this register to immediate offset
		immediate = instr[8] ? //if 9th bit = 0, then instr is a LLB, otherwise an LHB
			{ instr[7:0], {8{1'b1}}} : //LHB
			{ {8{1'b1}},  instr[7:0]}; //LLB
		dstData = srcData1 & immediate;
		nextPC = pc_plus_two_output;

	end 
	/* B BR*/
	4'b110x : 
	begin  
		
		immediate = {{6{instr[8]}}, instr[8:0],{1{1'b0}}};
		srcReg1 = instr[7:4];
		nextPC = takeBranch ? 
			(instr[8]? srcData1 : br_output) : //For B use brOutput and for BR use the value in the given register
			pc_plus_two_output;
	end
	4'b1110 : 
	begin  
		dstReg = instr[11:8];
		dstData = pc_plus_two_output;
		nextPC = pc_plus_two_output;
	end // PCS
	4'b1111 :
	begin 
	nextPC = pc;
	end // HLT
	default
	begin 
/*
		//wire [15:0] instr; // bits [15:12] are the opcode

		// Register Vars
		srcReg1    = 1'b0; 
		srcReg2    = 1'b0;
		dstReg     = 1'b0;
		writeReg   = 1'b0;

		// ALU Vars
		aluIn1     = 16'h0000;
		aluIn2	   = 16'h0000;
		aluOp	   = 4'h0;

		//LHB/LLB
		immediate  = 16'h0000;

		// Memory Vars
		offset     = 16'h0000;
		address    = 16'h0000;
		memDataIn  = 16'h0000;
		dataWr     = 1'b0;
		dataEnable = 1'b0;
*/
	end 
endcase 

endmodule

