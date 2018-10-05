module ALU_tb();

//reg [3:0] opcode;
enum bit [3:0] {ADD='h0, SUB='h1, XOR='h2, RED='h3, SLL='h4, SRA='h5, ROR='h6, PADDSB='h7,
		LW='h8, SW='h9, LLB='ha, LHB='hb, B='hc, BR='hd, PCS='he, HLT='hf} opcode;
reg [15:0] In1, In2;

logic [15:0] Out, ExpectedOut;
logic [2:0] flags;

ALU iDUT(.Opcode(opcode), .Input1(In1), .Input2(In2), .Output(Out), .flagsIn(flags), .flagsOut(flags));

integer a, b, c;
initial begin
	// Testing boundary conditions for all operations
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

	// Exhaustive test
	for(a = 0; a < 17'h10000; a = a + 1) begin
		In2 = a;
		for(b = 0; b < 17'h10000; b = b + 1) begin
			In1 = b;
			for(c = 0; c < 5'h10; c = c + 1) begin
				$cast(opcode, c);
				#5;
				if (opcode == RED) Check_RED_Result;
			end
		end
	end
	$stop();
end

task Check_RED_Result;

logic [8:0] temp1, temp2, temp3;
temp1 = In1[7:0] + In2[7:0];
temp2 = In1[15:8] + In2[15:8];
temp3 = temp1 + temp2;
ExpectedOut = { {7{temp3[8]}}, temp3};

if (ExpectedOut != Out) begin
	$display("INCORRECT - Op=%h, In1=%h, In2=%h, Out=%h, ExpectedOut=%h", opcode, In1, In2, Out, ExpectedOut);
end

endtask

endmodule
