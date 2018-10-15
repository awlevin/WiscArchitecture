module cpu(clk, rst_n, hlt, pc);

input clk, rst_n;
output reg hlt;
output reg [15:0] pc;

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
wire [2:0] aluFlags; // FLAGS ==>> (Z, V, N)
reg [3:0] aluOp;

//LHB/LLB
reg [15:0] immediate;

// Memory Vars
reg [15:0] offset;
reg [15:0] address, memDataIn;
wire [15:0] memDataOut;
reg dataWr, dataEnable;

// Control Instr's
reg takeBranch;
wire [15:0] instr; // bits [15:12] are the opcode
reg [8:0] pc_imm;
reg [15:0] pc_in;
reg [2:0] ccc;
reg [15:0] BR_value; //value use for BR instructor
reg PC_Control_BR_B_En;
wire [15:0] nextPC; //Output PC of Control module
wire [15:0] pc_to_save;
assign pc_to_save = pc;

/////////////////////
//     Modules	   //
/////////////////////

// Memory Modules
memory1c inst_mem(.clk(clk), .rst(~rst_n), .data_out(instr), .data_in(16'h0000), .addr(pc), .enable(rst_n), .wr(1'b0));
memory1c data_mem(.clk(clk), .rst(~rst_n), .data_out(memDataOut), .data_in(memDataIn), .addr(address), .enable(dataEnable), .wr(dataWr));

// Registers
RegisterFile regFile(.clk(clk), .rst(~rst_n), .SrcReg1(srcReg1), .SrcReg2(srcReg2), .DstReg(dstReg), .WriteReg(writeReg), .DstData(dstData), .SrcData1(srcData1), .SrcData2(srcData2));

// ALU Module
ALU alu(.Opcode(aluOp), .Input1(aluIn1), .Input2(aluIn2), .Output(aluOut), .flagsOut(aluFlags));

// PC Control Module
PC_control pc_control_module(.C(ccc), .I(pc_imm), .F(aluFlags), .PC_in(pc), .BR(BR_value), .En(PC_Control_BR_B_En) , .PC_out(nextPC));

always @(posedge clk, negedge rst_n)
	if(!rst_n) begin
		pc <= 16'h0000;
//		hlt = 1'b0;
//		PC_Control_BR_B_En = 1'b0;
//		writeReg = 1'b0;
//		dataEnable = 1'b0;
	end else
		pc <= nextPC;


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
		writeReg = 1'b1; 
		PC_Control_BR_B_En = 1'b0;
		dataEnable = 1'b0;
		//pc = nextPC;
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
		writeReg = 1'b1; 

		dataEnable = 1'b0;

		//PC Logic
		PC_Control_BR_B_En = 1'b0;
		//pc = nextPC;
	end

	/* LW */	
	4'b1000 : 
	begin
		// Parse instruction
		dstReg = instr[11:8];
		srcReg2 = instr[7:4]; // add data in this register to immediate offset
		offset = { {11{instr[3]}}, instr[3:0], 1'b0}; // TODO: (feel like there'll be a bug here) Phase 1 instructions specify "oooo is the offset in two's complement but right-shifted by 1 bit." So we should shift it left again?
		
		// Send base and offset to ALU
		aluOp = 4'b0000; // tell ALU to do an ADD -- TODO: does it matter if this is before the ALU inputs are set?
		aluIn1 = srcData2;
		aluIn2 = offset;
		address = aluOut;

		dstData = memDataOut; // The output of memData module is the M[addr] value we want to store to a register

		dataEnable = 1'b1;    // Enable=1 and Wr=1 --> data_out=M[addr] 
		dataWr = instr[12]; //LW = 4'b1000 SW = 4'b1001, so last bit of the instruction corresponds to the write data

		writeReg = ~instr[12]; // Write the data to the destination register, with opposite logic to dataWr
	
		//PC Logic
		PC_Control_BR_B_En = 1'b0;
		//pc = nextPC;
	end 
	/* SW */	
	4'b1001 : 
	begin
		// Parse instruction
		srcReg1 = instr[11:8];
		srcReg2 = instr[7:4]; // add data in this register to immediate offset
		offset = { {11{instr[3]}}, instr[3:0], 1'b0}; // TODO: (feel like there'll be a bug here) Phase 1 instructions specify "oooo is the offset in two's complement but right-shifted by 1 bit." So we should shift it left again?
		
		// Send base and offset to ALU
		aluOp = 4'b0000; // tell ALU to do an ADD -- TODO: does it matter if this is before the ALU inputs are set?
		aluIn1 = srcData2;
		aluIn2 = offset;
		address = aluOut;

		memDataIn = srcData1; //only used for mem writes

		dataEnable = 1'b1;    // Enable=1 and Wr=1 --> data_out=M[addr] 
		dataWr = instr[12]; //LW = 4'b1000 SW = 4'b1001, so last bit of the instruction corresponds to the write data

		writeReg = ~instr[12]; // Write the data to the destination register, with opposite logic to dataWr
	
		//PC Logic
		PC_Control_BR_B_En = 1'b0;
		//pc = nextPC;
	end 
	/* LLB LHB */
	4'b101x : 
	begin  
		// Parse instruction
		dstReg = instr[11:8];
		srcReg1 = instr[11:8]; // add data in this register to immediate offset
		writeReg = 1'b1;
		immediate = instr[12] ? //if 13th bit = 0, then instr is LLB, otherwise it's LHB
			{ instr[7:0], {8{1'b0}}} : //LHB
			{ {8{1'b0}},  instr[7:0]}; //LLB
		dstData = instr[12] ? //if 13th bit = 0, then instr is LLB, otherwise it's LHB
			(srcData1 & 16'h00FF) | immediate : //LHB
			(srcData1 & 16'hFF00) | immediate;  //LLB

		dataEnable = 1'b0;

		//PC Logic
		PC_Control_BR_B_En = 1'b0;
		//pc = nextPC;
	end 

	/* B(1100) BR(1101) */
	4'b110x : 
	begin  
		//pc = nextPC;
		PC_Control_BR_B_En = 1'b1;
		ccc = instr[11:9];

		//Only used for B Instr's
		pc_imm = instr[8:0];
		
		//Only used for BR instr's
		srcReg1 = instr[7:4];
		
		//Set based on B vs BR
		BR_value =  instr[12] ? srcData1 : 16'hFFFF;// 0: instr is B so set FFFF , 1: instr is BR so set value in srcReg1

		writeReg = 1'b0;
		dataEnable = 1'b0;
	end

	4'b1110 : 
	begin  
		dstReg = instr[11:8];
		writeReg = 1'b1;
		dstData = pc;
		//pc = nextPC;
		PC_Control_BR_B_En = 1'b0;
		dataEnable = 1'b0;
	end // PCS
	4'b1111 :
	begin 
		pc = pc;
		writeReg = 1'b0; 
		PC_Control_BR_B_En = 1'b0;
		dataEnable = 1'b0;    // Enable=1 and Wr=1 --> data_out=M[addr] 
		dataWr = 1'b0;
		hlt = 1;
		//nextPC = pc;
		//PC_Control_BR_B_En = 1'b0;
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

