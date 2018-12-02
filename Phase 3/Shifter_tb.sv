module Shifter_tb();

logic signed [15:0] Shift_In, Shift_Out, Expected_Out;
logic [3:0] Shift_Val;
logic Mode; // SLL=0, SRA=1

Shifter iDUT(.Shift_Out(Shift_Out), .Shift_In(Shift_In), .Shift_Val(Shift_Val), .Mode(Mode));

initial begin
/*
Mode = 0;
Exhaustive_Test_Shifts();

Mode = 1;
Exhaustive_Test_Shifts();
*/

repeat(1000) Random_Test_Shift;

$stop;

end


/*
task Exhaustive_Test_Shifts();

for (Shift_In = 16'h0; Shift_In < 16'hFFFF; Shift_In++) begin
	for (Shift_Val = 4'b0; Shift_Val < 4'hF; Shift_Val++) begin
		#2 Shifter_Check_Output;
		$stop;
	end

end
endtask
*/

task Random_Test_Shift();

Shift_In = $random;
Shift_Val = $random;
Mode = $random;

#2 Shifter_Check_Output;

endtask


task Shifter_Check_Output();

Expected_Out = (Mode == 0) ? Shift_In << Shift_Val : Shift_In >>> Shift_Val;

if (Shift_Out == Expected_Out) begin
	$write("CORRECT - ");
end else begin
	$write("INCORRECT - ");
end

$display("Shift_In=%x, Shift_Val=%d, Mode=%d, Shift_Out=%x, Expected_Out=%x", Shift_In, Shift_Val, Mode, Shift_Out, Expected_Out);

endtask

endmodule
