module cpu_tb();

reg clk, rst_n, hlt;
reg [15:0] pc;

CPU iDUT(.clk(clk), .rst_n(rst_n), .hlt(hlt), .pc(pc));

initial begin
clk = 0;
rst_n = 0;

iDUT.instr = 16'h0000;
#10 rst_n = 1;

end

always #5 clk = ~clk;

endmodule
