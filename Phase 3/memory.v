// Black box memory unit - holds caches and main memory
module memory(clk, rst, instruction_out, data_out, stall_en, mem_data_in, pc, mem_addr, enable, wr);

input clk, rst, enable, wr;
input [15:0] pc;			// Input to I Cache
input [15:0] mem_data_in, mem_addr;	// Inputs to D Cache

output stall_en;
output [15:0] instruction_out, data_out;

// Main memory module signals
wire [15:0] main_mem_data_in, main_mem_data_out, main_mem_addr;
wire main_mem_enable;
wire block_valid;

// I Cache signals
wire [15:0] I_Cache_miss_address;
wire I_Cache_miss, I_Cache_hit; // <-- bad

// D Cache signals
wire [15:0] D_Cache_data_in, D_Cache_miss_address;
wire D_Cache_writeEn, D_Cache_miss, D_Cache_hit; // <-- bad
wire SW_hit;


assign SW_hit = (D_Cache_hit & wr);
assign main_mem_addr = (I_Cache_miss) ? I_Cache_miss_address :
		       (D_Cache_miss) ? D_Cache_miss_address :
		       //(SW_hit) ? mem_addr : 
		       mem_addr;

assign main_mem_enable = ~I_Cache_hit;

assign D_Cache_miss_address_matched = (D_Cache_miss & wr & (D_Cache_miss_address == mem_addr));
assign writeEnable = SW_hit | D_Cache_miss_address_matched;
//assign main_mem_wr = SW_hit | D_Cache_miss_address_matched;

assign main_mem_data_in = mem_data_in; // wrong for d_cache on miss

assign stall_en = I_Cache_miss | (D_Cache_miss & enable);

assign D_Cache_data_in = (D_Cache_miss & ~D_Cache_miss_address_matched) ? main_mem_data_out : mem_data_in;


memory4c main_mem(.data_out(main_mem_data_out), .data_in(mem_data_in), .addr(main_mem_addr), .enable(main_mem_enable), .wr(writeEnable), .clk(clk), .rst(rst), .data_valid(block_valid));

Cache I_Cache(.clk(clk), .rst(rst), .address(pc), .dataIn(main_mem_data_out), .writeEn(1'b0), .readEn(1'b1), .memory_data_valid(block_valid), .stall(I_Cache_miss), .dataOut(instruction_out), .missedAddressToGet(I_Cache_miss_address), .cache_hit(I_Cache_hit));

Cache D_Cache(.clk(clk), .rst(rst), .address(mem_addr), .dataIn(D_Cache_data_in), .writeEn(writeEnable), .readEn(enable), .memory_data_valid(block_valid), .stall(D_Cache_miss), .dataOut(data_out), .missedAddressToGet(D_Cache_miss_address), .cache_hit(D_Cache_hit));



endmodule
