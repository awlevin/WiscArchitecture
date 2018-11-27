module Cache();

input clk,rst_n;
input [15:0] address;
input [15:0] dataIn;
input writeEn;
input readEn;

output stall;
output [15:0] dataOut;

wire [6:0] tagBits;
wire [5:0] setBits;
wire [2:0] offsetBits;

assign tagBits = address[15:9];
assign setBits = address[8:3];
assign offsetBits = address[2:0];

DataArray data(.clk(clk), .rst(~rst_n), .DataIn(), .Write(), .BlockEnable(), .WordEnable(), .DataOut());
MemDataArray tag(.clk(clk), .rst(~rst_n), .DataIn(), .Write(), .BlockEnable(), .DataOut());
cache_fill_FSM(.clk(clk), .rst_n(~rst_n), .miss_detected(), .miss_address(), .fsm_busy(), .write_data_array(), .write_tag_array(), .memory_address(), .memory_data(), .memory_data_valid())


assign block0 = 

assign miss_detected = 
   

endmodule
