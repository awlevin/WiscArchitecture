// Black box memory unit - holds caches and main memory
module memory(clk, rst, instruction_out, data_out, I_Cache_miss, D_Cache_miss, mem_data_in, pc, mem_addr, enable, wr, decoded_instr_is_hlt);

input clk, rst, enable, wr;
input [15:0] pc;			// Input to I Cache
input [15:0] mem_data_in, mem_addr;	// Inputs to D Cache
input decoded_instr_is_hlt;		// In this case, the I-Cache shouldn't be enabled

output I_Cache_miss, D_Cache_miss;
output [15:0] instruction_out, data_out;

// Main memory module signals
wire [15:0] main_mem_data_in, main_mem_data_out, main_mem_addr;
wire main_mem_enable;
wire block_valid;
wire main_memory_busy;

// I Cache signals
wire [15:0] I_Cache_miss_address;
wire I_Cache_hit; // <-- bad
wire I_Cache_busy, handling_I_Cache_miss, enter_I_Cache_miss_handling, I_Cache_fill_done;

// D Cache signals
wire [15:0] D_Cache_data_in, D_Cache_miss_address;
wire D_Cache_hit; // <-- bad
wire SW_hit;
wire D_Cache_busy, handling_D_Cache_miss, enter_D_Cache_miss_handling, D_Cache_fill_done;


assign SW_hit = (D_Cache_hit & wr);
assign main_mem_addr = (I_Cache_miss) ? I_Cache_miss_address :
		       (D_Cache_miss) ? D_Cache_miss_address :
		       //(SW_hit) ? mem_addr : 
		       mem_addr;

dff handle_I_miss(.q(handling_I_Cache_miss), .d(~handling_I_Cache_miss), .wen(enter_I_Cache_miss_handling | I_Cache_fill_done), .clk(clk), .rst(rst));
dff handle_D_miss(.q(handling_D_Cache_miss), .d(~handling_D_Cache_miss), .wen(enter_D_Cache_miss_handling | D_Cache_fill_done), .clk(clk), .rst(rst));

assign main_memory_busy = (handling_I_Cache_miss | handling_D_Cache_miss);

assign enter_I_Cache_miss_handling = (~main_memory_busy & I_Cache_miss);
assign I_Cache_busy = (handling_I_Cache_miss) | (enter_I_Cache_miss_handling);

assign enter_D_Cache_miss_handling = (~main_memory_busy & ~I_Cache_miss & D_Cache_miss);
assign D_Cache_busy = (handling_D_Cache_miss) | (enter_D_Cache_miss_handling);

assign main_mem_enable = I_Cache_miss | D_Cache_miss | (D_Cache_hit & wr);

assign D_Cache_miss_address_matched = (D_Cache_miss & wr & (D_Cache_miss_address == mem_addr));
assign writeEnable = (SW_hit | D_Cache_miss_address_matched) & ~(handling_I_Cache_miss | enter_I_Cache_miss_handling);
//assign main_mem_wr = SW_hit | D_Cache_miss_address_matched;

assign main_mem_data_in = mem_data_in; // wrong for d_cache on miss

assign D_Cache_data_in = (D_Cache_miss & ~D_Cache_miss_address_matched) ? main_mem_data_out : mem_data_in;


memory4c main_mem(.data_out(main_mem_data_out), .data_in(mem_data_in), .addr(main_mem_addr), .enable(main_mem_enable), .wr(writeEnable), .clk(clk), .rst(rst), .data_valid(block_valid));

Cache I_Cache(.clk(clk), .rst(rst), .address(pc), .dataIn(main_mem_data_out), .memory_busy(D_Cache_busy), .writeEn(1'b0), .readEn(1'b1), .memory_data_valid(block_valid), .stall(I_Cache_miss), .dataOut(instruction_out), .missedAddressToGet(I_Cache_miss_address), .cache_hit(I_Cache_hit), .write_tag_array(I_Cache_fill_done));

Cache D_Cache(.clk(clk), .rst(rst), .address(mem_addr), .dataIn(D_Cache_data_in), .memory_busy(I_Cache_busy), .writeEn(writeEnable), .readEn(enable), .memory_data_valid(block_valid), .stall(D_Cache_miss), .dataOut(data_out), .missedAddressToGet(D_Cache_miss_address), .cache_hit(D_Cache_hit), .write_tag_array(D_Cache_fill_done));

endmodule
