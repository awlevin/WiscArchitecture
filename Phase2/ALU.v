// ALU
//	Receives an opcode and two 16 bit inputs,
//	Outputs a 16 bit result
//	Keeps track of flags
module ALU(clk, rst, Opcode, Input1, Input2, Output, flags_out);

input clk, rst;
input [3:0] Opcode;
input [15:0] Input1, Input2;

output reg [15:0] Output;
output [2:0] flags_out;
reg [2:0] flags;
wire [2:0] flags_dff_out;

wire shifterZFlag, xorZFlag, adderZFlag, adderVFlag, adderNFlag;
wire [15:0] shifterResult, xorResult, adderResult, paddsbResult, redResult, llb_result, lhb_result;

shift_rotate shiftOp(.Shift_Out(shifterResult), .Shift_In(Input1), .Shift_Val(Input2[3:0]), .Mode(Opcode[1:0]), .Zero(shifterZFlag));

xor_16bit xorOp(.A(Input1), .B(Input2), .Result(xorResult), .Zero(xorZFlag));

adder_16bit addsubOp(.A(Input1), .B(Input2), .Sub(Opcode[0] & ~Opcode[3]), .Sum(adderResult), .Zero(adderZFlag), .Ovfl(adderVFlag), .Sign(adderNFlag));

paddsb_16bit paddsbOp(.Sum(paddsbResult), .A(Input1), .B(Input2));

red_16bit redOp(.Sum(redResult), .A(Input1), .B(Input2));

assign llb_result = (Input1 & 16'hFF00) | Input2;
assign lhb_result = (Input1 & 16'h00FF) | Input2; 

FlagsRegister flags_dff(.clk(clk), .rst(rst), .set(set_flags), .flags_in(flags), .flags_out(flags_dff_out));

//assign flags_out = (set_flags) ? flags : flags_dff_out;
assign flags_out = flags_dff_out;

assign set_flags = ((Opcode != 4'b0111) && (Opcode != 4'b0011) && (Opcode[3] != 1'b1)); // don't update flags on RED, PADDSB, LW/SW/LHB/LLB/B/BR/PCS

always @(*)
case(Opcode)
	4'b0000 : begin Output = adderResult; flags = {adderZFlag, adderVFlag, adderNFlag}; end
	4'b0001 : begin Output = adderResult; flags = {adderZFlag, adderVFlag, adderNFlag}; end
	4'b0010 : begin Output = xorResult; flags = {xorZFlag, 2'b00}; end
	4'b0011 : begin Output = redResult; flags = 3'bxxx; end
	4'b0100 : begin Output = shifterResult; flags = {shifterZFlag, 2'b00}; end
	4'b0101 : begin Output = shifterResult; flags = {shifterZFlag, 2'b00}; end
	4'b0110 : begin Output = shifterResult; flags = {shifterZFlag, 2'b00}; end
	4'b0111 : begin Output = paddsbResult; flags = 3'bxxx; end
	4'b1000 : begin Output = adderResult; flags = 3'bxxx; end
	4'b1001 : begin Output = adderResult; flags = 3'bxxx; end	
	4'b1010 : begin Output = llb_result; flags = 3'b111; end
	4'b1011 : begin Output = lhb_result; flags = 3'b111; end
	//with pipeline, a signal must be outputted, even if it won't be used
	//All 1's is a random choice as none of these results should be used
	4'b1100 : begin Output = 16'hFFFF; flags = 3'b111; end
	4'b1101 : begin Output = 16'hFFFF; flags = 3'b111; end
	4'b1110 : begin Output = Input1; flags = 3'b111; end 	// PCS
	4'b1111 : begin Output = 16'hFFFF; flags = 3'b111; end
	default : begin Output = 16'hFFFF; flags = 3'b111; end
endcase

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	SLL, SRA, ROR
module shift_rotate(Shift_Out, Shift_In, Shift_Val, Mode, Zero);

input [15:0] Shift_In; // This is the input data to perform shift operation on
input [3:0] Shift_Val; // Shift amount (used to shift the input data)
input [1:0] Mode; // To indicate 00=SLL or 01=SRA or 10=ROR

output [15:0] Shift_Out; // Shifted output data
output Zero;

wire [15:0] stg1, stg2, stg3;

assign stg1 = Shift_Val[0] ?						// 1 bit
		(~Mode[1] & ~Mode[0]) ? {Shift_In[14:0], 1'b0} :		// SLL
		(~Mode[1] & Mode[0]) ? {Shift_In[15], Shift_In[15:1]} :	// SRA
		(Mode[1] & ~Mode[0]) ? {Shift_In[0], Shift_In[15:1]} :	// ROR
		Shift_In :						// bad mode
		Shift_In;						// Don't shift

assign stg2 = Shift_Val[1] ?						// 2 bits
		~Mode[1] & ~Mode[0] ? {stg1[13:0], 2'b0} :		// SLL
		~Mode[1] & Mode[0] ? {{2{stg1[15]}}, stg1[15:2]} :	// SRA
		Mode[1] & ~Mode[0] ? {stg1[1:0], stg1[15:2]} :		// ROR
		Shift_In :						// bad mode
		stg1;							// Don't shift

assign stg3 = Shift_Val[2] ?						// 4 bits
		~Mode[1] & ~Mode[0] ? {stg2[11:0], 4'b0} :		// SLL
		~Mode[1] & Mode[0] ? {{4{stg2[15]}}, stg2[15:4]} :	// SRA
		Mode[1] & ~Mode[0] ? {stg2[3:0], stg2[15:4]} :		// ROR
		Shift_In :						// bad mode
		stg2;							// Don't shift

assign Shift_Out = Shift_Val[3] ?					// 8 bits
		~Mode[1] & ~Mode[0] ? {stg3[7:0], 8'b0} :		// SLL
		~Mode[1] & Mode[0] ? {{8{stg3[15]}}, stg3[15:8]} :	// SRA 
		Mode[1] & ~Mode[0] ? {stg3[7:0], stg3[15:8]} :		// ROR
		Shift_In :						// bad mode
		stg3;							// Don't shift

assign Zero = ~|Shift_Out;

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	XOR
module xor_16bit(A, B, Result, Zero);

input [15:0] A, B;

output [15:0] Result;
output Zero;

assign Result = A ^ B;
assign Zero = ~|Result;

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	ADD, SUB
module adder_16bit(A, B, Sub, Sum, Zero, Ovfl, Sign);

input [15:0] A, B;
input Sub;

output [15:0] Sum;
output Zero, Ovfl, Sign;

wire [15:0] B_in, preSatSum; 
wire [3:0] carry, ov;
assign B_in = Sub ? ~B : B;

CLA_4bit CLA0(.S(preSatSum[3:0]), .Cout(carry[0]), .A(A[3:0]), .B(B_in[3:0]), .Cin(Sub), .Ov(ov[0])),
	 CLA1(.S(preSatSum[7:4]), .Cout(carry[1]), .A(A[7:4]), .B(B_in[7:4]), .Cin(carry[0]), .Ov(ov[1])),
	 CLA2(.S(preSatSum[11:8]), .Cout(carry[2]), .A(A[11:8]), .B(B_in[11:8]), .Cin(carry[1]), .Ov(ov[2])),
	 CLA3(.S(preSatSum[15:12]), .Cout(carry[3]), .A(A[15:12]), .B(B_in[15:12]), .Cin(carry[2]), .Ov(ov[3]));

assign Ovfl = ov[3];
assign Sum = Ovfl ? preSatSum[15] ? 16'h7fff : 16'h8000 : preSatSum;
assign Zero = ~|Sum;
assign Sign = Sum[15];

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	PADDSB
module paddsb_16bit(Sum, A, B);

input [15:0] A, B; // Input data values

output [15:0] Sum; // Sum output

wire [3:0] sum0, sum1, sum2, sum3, preSatSum0, preSatSum1, preSatSum2, preSatSum3, carry, ov;

CLA_4bit CLA0(.S(preSatSum0), .Cout(carry[0]), .A(A[3:0]), .B(B[3:0]), .Cin(1'b0), .Ov(ov[0])),
	 CLA1(.S(preSatSum1), .Cout(carry[1]), .A(A[7:4]), .B(B[7:4]), .Cin(1'b0), .Ov(ov[1])),
	 CLA2(.S(preSatSum2), .Cout(carry[2]), .A(A[11:8]), .B(B[11:8]), .Cin(1'b0), .Ov(ov[2])),
	 CLA3(.S(preSatSum3), .Cout(carry[3]), .A(A[15:12]), .B(B[15:12]), .Cin(1'b0), .Ov(ov[3]));

assign sum0 = ov[0] ? preSatSum0[3] ? 4'h7 : 4'h8 : preSatSum0;
assign sum1 = ov[1] ? preSatSum1[3] ? 4'h7 : 4'h8 : preSatSum1;
assign sum2 = ov[2] ? preSatSum2[3] ? 4'h7 : 4'h8 : preSatSum2;
assign sum3 = ov[3] ? preSatSum3[3] ? 4'h7 : 4'h8 : preSatSum3;

assign Sum = {sum3, sum2, sum1, sum0};

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	RED
module red_16bit(Sum, A, B);

input [15:0] A, B; // Input data values

output [15:0] Sum; // Sum output

wire [3:0] 	sumab1,	// A[3:0] + B[3:0]
		sumab2, // A[7:4] + B[7:4]
		sumcd1, // A[11:8] + B[11:8]
		sumcd2, // A[15:12] + B[15:12]
		sum1, sum2, sum3;
wire [6:0] carry, ov;
wire [8:0] sumab, sumcd;

CLA_4bit CLA0(.S(sumab1), .Cout(carry[0]), .A(A[3:0]), .B(B[3:0]), .Cin(1'b0), .Ov(ov[0])),
	 CLA1(.S(sumab2), .Cout(carry[1]), .A(A[7:4]), .B(B[7:4]), .Cin(carry[0]), .Ov(ov[1])),
	 CLA2(.S(sumcd1), .Cout(carry[2]), .A(A[11:8]), .B(B[11:8]), .Cin(1'b0), .Ov(ov[2])),
	 CLA3(.S(sumcd2), .Cout(carry[3]), .A(A[15:12]), .B(B[15:12]), .Cin(carry[2]), .Ov(ov[3]));

assign sumab = {carry[1], sumab2, sumab1};
assign sumcd = {carry[3], sumcd2, sumcd1};

CLA_4bit CLA4(.S(sum1), .Cout(carry[4]), .A(sumab[3:0]), .B(sumcd[3:0]), .Cin(1'b0), .Ov(ov[4])),
	 CLA5(.S(sum2), .Cout(carry[5]), .A(sumab[7:4]), .B(sumcd[7:4]), .Cin(carry[4]), .Ov(ov[5])),
	 CLA6(.S(sum3), .Cout(carry[6]), .A({3'b000, sumab[8]}), .B({3'b000, sumcd[8]}), .Cin(carry[5]), .Ov(ov[6]));

assign Sum = {{8{sum3[0]}}, sum2, sum1};

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Carry Look-Ahead Adder
module CLA_4bit(S, Cout, Ov, A, B, Cin);

input [3:0] A, B;
input Cin;

output [3:0] S;
output Cout, Ov;

wire [3:0] g, p, c;

assign g = A & B;
assign p = A ^ B;

assign c[0] = Cin;
assign c[1] = g[0] | (p[0] & c[0]);
assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]);

assign Cout = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) |(p[3] & p[2] & p[1] & p[0] & c[0]);

assign S = p ^ c;
assign Ov = Cout ^ c[3];

endmodule

