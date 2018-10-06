module ALU_tb();

//reg [3:0] opcode;
enum bit [3:0] {ADD='h0, SUB='h1, XOR='h2, RED='h3, SLL='h4, SRA='h5, ROR='h6, PADDSB='h7,
		LW='h8, SW='h9, LLB='ha, LHB='hb, B='hc, BR='hd, PCS='he, HLT='hf} opcode;
logic signed [15:0] In1, In2;

logic signed [15:0] Out, ExpectedOut;
logic [2:0] flags;

ALU iDUT(.Opcode(opcode), .Input1(In1), .Input2(In2), .Output(Out), .flagsIn(flags), .flagsOut(flags));

integer a, b, c;
initial begin

	Check_Boundary_Conditions_For_All_Ops();

	TestShifters();
	Test_PADDSB();

/*
	// Exhaustive test
	for(c = 0; c < 5'h10; c = c + 1) begin // opcode
		for(a = 0; a < 17'h10000; a = a + 1) begin // input1
			In2 = a;
			for(b = 0; b < 17'h10000; b = b + 1) begin // input2
				In1 = b;	
				$cast(opcode, c);
				#5;
				if (opcode == RED) Check_RED_Result;
				if (opcode == SLL || opcode == SRA || opcode == ROR) Check_Shifter_Result;
			end
		end
	end
*/
	$stop();
end

// Checks boundary conditions for all operations
task Check_Boundary_Conditions_For_All_Ops;

	for(c = 0; c < 5'h10; c = c + 1) begin
		$cast(opcode, c);
		In1 = 16'h8000;
		In2 = 16'h0001;
		#5;
		In1 = 16'h7fff;
		In2 = 16'h0001;
		#5;
		In1 = 16'h8000;
		In2 = 16'hffff;
		#5;
		In1 = 16'h7fff;
		In2 = 16'hffff;
		#5;
		In1 = 16'h0001;
		In2 = 16'h8000;
		#5;
		In1 = 16'h0001;
		In2 = 16'h7fff;
		#5;
		In1 = 16'hffff;
		In2 = 16'h8000;
		#5;
		In1 = 16'hffff;
		In2 = 16'h7fff;
		#5;
	end
endtask

integer random;
task Set_Random_Inputs_For_Shifter;
	random = ($random % 3);
	opcode = (random == 0) ? SLL : (random == 1) ? SRA : (random == 2) ? ROR : ROR;
	In1 = $random;
	In2 = $random;
endtask

task Check_RED_Result;

	logic [8:0] temp1, temp2, temp3;
	temp1 = In1[7:0] + In2[7:0];
	temp2 = In1[15:8] + In2[15:8];
	temp3 = temp1 + temp2;
	ExpectedOut = { {7{temp3[8]}}, temp3};
	
	Verify_Output();
endtask


/////////////////////////////////////////////////
//	SHIFTERS
/////////////////////////////////////////////////
task TestShifters;
	repeat(150) begin
		Set_Random_Inputs_For_Shifter();
		#5;
		Check_Shifter_Result();
	end
endtask

task Check_Shifter_Result;

	logic signed [15:0] ExpectedOut_SLL, ExpectedOut_SRA, ExpectedOut_ROR;
	logic [3:0] rotate_amount, shift_amount;
	
	// Compute value for rotate right if necessary
	if (opcode == ROR) begin
		rotate_amount = In2[3:0];
		ExpectedOut_ROR = In1; // original value before rotating
	
		// 1-bit rotate however many times are necessary
		repeat(rotate_amount) ExpectedOut_ROR = {ExpectedOut_ROR[0], ExpectedOut_ROR[15:1]};
	end
	
	if (opcode === SRA) begin
		shift_amount = In2[3:0];
		ExpectedOut_SRA = In1; // original value before rotating
	
		// 1-bit rotate however many times are necessary
		repeat(shift_amount) ExpectedOut_SRA = {ExpectedOut_SRA[15], ExpectedOut_SRA[15:1]};
	end
	
	ExpectedOut_SLL = In1 << In2[3:0];
	//ExpectedOut_SRA = In2 >>> In2[3:0]; // apparently MUXing 'ExpectedOut' will force the SRA to be unsigned
	
	ExpectedOut = (opcode === SLL) ? ExpectedOut_SLL :
			(opcode === SRA) ? ExpectedOut_SRA :
			(opcode === ROR) ? ExpectedOut_ROR  :
			16'hzzzz;
	
	if (ExpectedOut !== Out) begin
		$display("INCORRECT - Op=%h, In1=%h, Imm=%h, Out=%h, ExpectedOut=%h", opcode, In1, In2[3:0], Out, ExpectedOut);
	end

endtask

/////////////////////////////////////////////////
//	PADDSB
/////////////////////////////////////////////////

task Test_PADDSB;
	repeat (150) begin
		Set_Random_Inputs_For_PADDSB();
		#5;
		Check_PADDSB_Results();
	end
endtask;

task Set_Random_Inputs_For_PADDSB;
	opcode = PADDSB;
	In1 = $random;
	In2 = $random;
endtask

task Check_PADDSB_Results;
	// Suppose: In1=aaaa_bbbb_cccc_dddd, In2=eeee_ffff_gggg_hhhh
	// Then ExpectedResult = {sat(aaaa+eeee), sat(bbbb+ffff), sat(cccc+gggg), sat(dddd+hhhh)}

	// Saturate the numbers and store the results in proper positions within ExpectedOut
	Add_And_Saturate(.x(In1[3:0]), .y(In2[3:0]), .out(ExpectedOut[3:0]));
	Add_And_Saturate(.x(In1[7:4]), .y(In2[7:4]), .out(ExpectedOut[7:4]));
	Add_And_Saturate(.x(In1[11:8]), .y(In2[11:8]), .out(ExpectedOut[11:8]));
	Add_And_Saturate(.x(In1[15:12]), .y(In2[15:12]), .out(ExpectedOut[15:12]));

	Verify_Output();
endtask



// 4-bit Add & Saturate
// If result exceeds most positive 4-bit number (2^3)-1, saturate to (2^3)-1
// If result is smaller than most negative 4-bit number (-2^3) then saturate to -2^3
task Add_And_Saturate; // suppose numBits = 4 --> then "in" should be 5-bit
	input logic signed [3:0] x, y; 
	output logic signed [3:0] out;

	out = (x+y > 7) ? 4'h7 : (x+y < -8) ? 4'h8 : x+y;

endtask;

task Verify_Output;
	if (ExpectedOut !== Out) begin
		$display("INCORRECT - Op=%h, In1=%h, In2=%h, Out=%h, ExpectedOut=%h", opcode, In1, In2, Out, ExpectedOut);
	end
endtask

endmodule
