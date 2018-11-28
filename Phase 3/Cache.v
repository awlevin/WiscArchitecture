module Cache(clk, rst_n, address, dataIn, writeEn, readEn, memory_data_valid, stall, dataOut, missedAddressToGet);

input clk,rst_n;
input [15:0] address;
input [15:0] dataIn;
input writeEn;
input readEn;
input memory_data_valid;

output stall;
output [15:0] dataOut;
output [15:0] missedAddressToGet;

wire [6:0] tagBits;
wire [5:0] setBits;
wire [2:0] offsetBits;

// Metadata Array signals
wire [63:0] tagBlockEnable;
wire valid0, valid1;
wire [6:0] tagBlock0, tagBlock1;

// Cache Fill FSM signals
wire write_tag_array, write_data_array;

// Data Array signals
wire dataWrite;
wire [127:0] dataBlockEnable;
wire [7:0] dataWordEnable;

// TODO - LRU logic
wire block0_isLRU, block1_isLRU;

assign tagBits = address[15:9];
assign setBits = address[8:3];
assign offsetBits = address[2:0];

DataArray data(.clk(clk), .rst(~rst_n), .DataIn(dataIn), .Write(dataWrite), .BlockEnable(dataBlockEnable), .WordEnable(dataWordEnable), .DataOut(dataOut));

MetaDataArray tags(.clk(clk), .rst(~rst_n), .DataIn({1'b1, tagBits}), .BlockEnable(tagBlockEnable), .Write0(block0_isLRU & write_tag_array), .Write1(block1_isLRU & write_tag_array), .DataOut0({valid0, tagBlock0}), .DataOut1({valid1, tagBlock1}));

cache_fill_FSM fill_fsm(.clk(clk), .rst_n(~rst_n), .miss_detected(miss_detected), .miss_address(address), .fsm_busy(stall), .write_data_array(write_data_array), .write_tag_array(write_tag_array), .memory_address(missedAddressToGet), .memory_data(), .memory_data_valid(memory_data_valid));


assign dataWrite = write_data_array | (((tagBits == tagBlock0) | (tagBits == tagBlock1)) & writeEn); // Enables a write if cache is being filled or we have a hit and are writing (SW instruction)

assign tagBlockEnable = (1 << setBits); // Enables two blocks in the tag array tied to a set (0 through 63)

assign miss_detected = 	(~valid0 & ~valid1) |					// Cache miss if both blocks are invalid or
			((tagBits != tagBlock0) & (tagBits != tagBlock1)) |	// if neither tag is a hit or
			(~valid0 & (tagBits == tagBlock0)) |			// if the block is present but invalid
			(~valid1 & (tagBits == tagBlock1));			// 

assign dataWordEnable = (1 << offsetBits); // Enables one word (0 through 7) to be enabled in a block

assign dataBlockEnable = ((valid0 & (tagBits == tagBlock0)) | (miss_detected & block0_isLRU)) ? (1 << (setBits << 1)) :		// Enables one block in an even bit position or
			 ((valid1 & (tagBits == tagBlock1)) | (miss_detected & block1_isLRU)) ? (2 << (setBits << 1)) : 128'b0;	// enables one block in an odd bit position
   

endmodule
