
module ReadDecoder_4_16(RegId, Wordline);

input [3:0] RegId;
output [15:0] Wordline;

Shifter shifter(.Shift_Out(Wordline), .Shift_In(16'h0001), .Shift_Val(RegId), .Mode(1'b0)); // Mode=0 is SLL

endmodule
