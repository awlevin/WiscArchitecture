
module WriteDecoder_4_16(RegId, WriteReg, Wordline);

input [3:0] RegId;
input WriteReg;
output [15:0] Wordline;

Shifter(.Shift_Out(Wordline), .Shift_In(16'h0001), .Shift_Val(RegId), .Mode(1'b0)); // Mode=0 is SLL

endmodule
