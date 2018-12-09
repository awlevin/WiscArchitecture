module hlt_register(clk, rst_n, hlt_found, hlt);

input clk, rst_n, hlt_found;

output hlt;

wire hlt_ex_in, hlt_mem_in;

//Dff's to store halt signals for each pipeline stage
dff	id_ex_hlt(.q(hlt_ex_in), .d(hlt_found), .wen(1'b1), .clk(clk), .rst(~rst_n)),
	ex_mem_hlt(.q(hlt_mem_in), .d(hlt_ex_in), .wen(1'b1), .clk(clk), .rst(~rst_n)),
	mem_wb_hlt(.q(hlt), .d(hlt_mem_in), .wen(1'b1), .clk(clk), .rst(~rst_n));

endmodule
