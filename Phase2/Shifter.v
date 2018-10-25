
module Shifter(Shift_Out, Shift_In, Shift_Val, Mode);

input [15:0] Shift_In; // This is the input data to perform shift operations on
input [3:0] Shift_Val; // Shift amount (used to shift the input data)
input Mode; // To indicate 0=SLL or 1=SRA
output [15:0] Shift_Out; // Shifted output data

wire signed [15:0] sll_out, sra_out;

Shifter_SLL sll_module(.Shift_Out(sll_out), .Shift_In(Shift_In), .Shift_Val(Shift_Val));
Shifter_SRA sra_module(.Shift_Out(sra_out), .Shift_In(Shift_In), .Shift_Val(Shift_Val));

assign Shift_Out = (Mode) ? sra_out : sll_out;

endmodule

module Shifter_SLL(Shift_Out, Shift_In, Shift_Val);

input [15:0] Shift_In;
input [3:0] Shift_Val;
output [15:0] Shift_Out;

wire [15:0] shift0, shift1, shift2, shift3;

assign shift0 = (Shift_Val[0] == 1'b1) ? {Shift_In[14:0], 1'h0} : Shift_In;
assign shift1 = (Shift_Val[1] == 1'b1) ? {shift0[13:0], 2'h0} : shift0;
assign shift2 = (Shift_Val[2] == 1'b1) ? {shift1[11:0], 4'h0} : shift1;
assign shift3 = (Shift_Val[3] == 1'b1) ? {shift2[7:0], 8'h00} : shift2;

assign Shift_Out = shift3;

endmodule

module Shifter_SRA(Shift_Out, Shift_In, Shift_Val);

input [15:0] Shift_In;
input [3:0] Shift_Val;
output [15:0] Shift_Out;

wire [15:0] shift0, shift1, shift2, shift3;

assign shift0 = (Shift_Val[0] == 1'b1) ? { {1{Shift_In[15]}}, Shift_In[15:1]} : Shift_In;
assign shift1 = (Shift_Val[1] == 1'b1) ? { {2{shift0[15]}}, shift0[15:2]} : shift0;
assign shift2 = (Shift_Val[2] == 1'b1) ? { {4{shift1[15]}}, shift1[15:4]} : shift1;
assign shift3 = (Shift_Val[3] == 1'b1) ? { {8{shift2[15]}}, shift2[15:8]} : shift2;

assign Shift_Out = shift3;

endmodule
