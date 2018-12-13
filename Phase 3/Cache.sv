/** TODO 
We use a lot of shifts ... are shifts ok or should we use our module?
**/
module Cache(clk, rst, address, dataIn, writeEn, readEn, memory_data_valid, memory_busy, stall, dataOut, missedAddressToGet, cache_hit, write_tag_array);

input clk,rst;
input [15:0] address;
input [15:0] dataIn;
input writeEn;
input readEn;
input memory_data_valid;
input memory_busy;

output stall;
output [15:0] dataOut;
output [15:0] missedAddressToGet;
output cache_hit;
output write_tag_array;

wire [5:0] tagBits;
wire [5:0] setBits;
wire [2:0] offsetBits;

wire cacheEn;
wire LRU_invalid;

// Metadata Array signals
wire [63:0] SetEnable;
wire block0_hit,block1_hit;
wire writeMetaData;
wire [7:0] metaData_entry0, metaData_entry1;
wire [7:0] flopped_metaData_entry0, flopped_metaData_entry1;

//Metadata stored entries
wire [7:0] storedBlock0,storedBlock1;
wire valid0, valid1;
wire isLRU0,isLRU1;
wire [5:0] tagBlock0,tagBlock1;

//Metadata entries to be written 
wire metaData_entry0_valid, metaData_entry1_valid;
wire metaData_entry0_LRU, metaData_entry1_LRU;
wire [5:0] metaData_entry0_tag, metaData_entry1_tag;

// Cache Fill FSM/ miss signals
wire write_data_array;
wire [15:0] cache_miss_dataOut;
wire miss_detected;
wire [7:0] oneHot_offset;
wire [7:0] missedAddressToGet_offset_bits;

assign missedAddressToGet_offset_bits = 1 << (missedAddressToGet[3:1]);

OneHotCounter counter(.clk(clk),.rst(rst),.startCount(miss_detected),.offset_in(missedAddressToGet_offset_bits),.offset_out(oneHot_offset));

// Data Array signals
wire dataWrite;
wire [127:0] dataBlockEnable;
wire [7:0] dataWordEnable;
wire [127:0] dataBlock0Enable, dataBlock1Enable;
wire [15:0] dataArrayOut;
wire writeDataLine0,writeDataLine1;
//LRU logic
//wire block0_isLRU, block1_isLRU;
wire LRU_writeEn,LRU_block_selected,block1_isLRU_saved;
//dff saved_block1_isLRU(.q(block1_isLRU_saved), .d(block1_isLRU), .wen(miss_detected), .clk(clk), .rst(rst));

//fixes metastability issue on last cycle of miss 
assign LRU_block_selected = cache_hit ? block1_hit : (write_tag_array & isLRU0);

assign cacheEn = (writeEn | readEn);

assign tagBits = address[15:10];
assign setBits = address[9:4];
assign offsetBits = address[3:1]; // if miss detected, must use address coming out of fill_fsm, which has the incremented offset

assign valid0 = storedBlock0[7];
assign tagBlock0 = storedBlock0[5:0];

assign valid1 = storedBlock1[7];
assign tagBlock1 = storedBlock1[5:0];

assign dataOut = cache_hit ? dataArrayOut : cache_miss_dataOut;

assign LRU_invalid = ~(isLRU0 | isLRU1) | (isLRU0 & isLRU1);

assign metaData_entry0_valid = valid0 | (isLRU0 & miss_detected);
assign metaData_entry1_valid = valid1 | (isLRU1 & miss_detected);

assign metaData_entry0_LRU = (miss_detected & ((~isLRU0 & ~LRU_invalid) | ~LRU_invalid)) | 	//if a miss occured, toggle LRU of this block, except for cold misses
				(cache_hit & block1_hit);			//if a cache hit occurred, update LRU based on if the hit was in this block

assign metaData_entry1_LRU = (miss_detected & ((~isLRU1 & ~LRU_invalid) | LRU_invalid)) |  	//if a miss occured, toggle LRU of this block, except for cold misses
				(cache_hit & block0_hit);			//if a cache hit occurred, update LRU based on if the hit was in this block

assign metaData_entry0_tag = cache_hit ? tagBlock0 :  //if a cache hit occurs, do not change update stored tag bits
				metaData_entry0_LRU ?
					tagBlock0 : tagBits;//if not writing to this block, keep tags bits, otherwise update tag bits to requested address

assign metaData_entry1_tag = cache_hit ? tagBlock1 : //if a cache hit occurs, do not change update stored tag bits
				metaData_entry1_LRU ?
					tagBlock1 : tagBits;//if not writing to this block, keep tags bits, otherwise update tag bits to requested address

dff floppedEntry0[7:0]( .clk(clk), .rst(rst), .d(metaData_entry0), .q(flopped_metaData_entry0),.wen(miss_detected & ~write_tag_array));
dff floppedEntry1[7:0]( .clk(clk), .rst(rst), .d(metaData_entry1), .q(flopped_metaData_entry1),.wen(miss_detected & ~write_tag_array));

assign metaData_entry0 = {metaData_entry0_valid, 1'b0, metaData_entry0_tag};
assign metaData_entry1 = {metaData_entry1_valid, 1'b0, metaData_entry1_tag};

assign LRU_writeEn = write_tag_array | cache_hit;
assign writeMetaData = (write_tag_array);

DataArray data(.clk(clk), .rst(rst), .DataIn(dataIn), .Write(dataWrite), .BlockEnable(dataBlockEnable), .WordEnable(dataWordEnable), .DataOut(dataArrayOut));

MetaDataArray tags(.clk(clk), .rst(rst), .entry0(flopped_metaData_entry0), .entry1(flopped_metaData_entry1), .SetEnable(SetEnable), .Write0(writeMetaData), .Write1(writeMetaData), .DataOut0(storedBlock0), .DataOut1(storedBlock1));

cache_fill_FSM fill_fsm(.clk(clk), .rst(rst), .miss_detected(miss_detected), .miss_address(address), .memory_busy(memory_busy), .fsm_busy(stall), .write_data_array(write_data_array), .write_tag_array(write_tag_array), .memory_address(missedAddressToGet), .memory_data(dataIn), .memory_data_valid(memory_data_valid), .dataOut(cache_miss_dataOut));

LRUArray LRU(.clk(clk), .rst(rst), .writeEn(LRU_writeEn), .SetEnable(SetEnable), .Block(LRU_block_selected), .block0_isLRU(isLRU0), .block1_isLRU(isLRU1));

assign block0_hit = write_tag_array ? 1'b0 : valid0 & (tagBits == tagBlock0);
assign block1_hit = write_tag_array ? 1'b0 : valid1 & (tagBits == tagBlock1);

assign dataWrite = (write_data_array & miss_detected) | (((tagBits == tagBlock0) | (tagBits == tagBlock1)) & writeEn); // Enables a write if cache is being filled or we have a hit and are writing (SW instruction)

assign SetEnable = (1 << setBits); // Enables two blocks in the tag array tied to a set (0 through 63)

assign miss_detected =  cacheEn & ~rst ? write_tag_array ? 1'b1 : ~(block0_hit | block1_hit) : 1'b0 ;	// Asserted if data is not in either block

assign cache_hit = cacheEn & ~rst ? ~miss_detected : 1'b0;

//if miss,use output of oneHotCounter
assign dataWordEnable = miss_detected ? oneHot_offset :(1 << offsetBits); // Enables one word (0 through 7) to be enabled in a block


assign dataBlock0Enable = (1 << (setBits << 1));
assign dataBlock1Enable = (2 << (setBits << 1)); //WE MIGHT BE DUPLICATING SHIFTERS CHECK IF SetEnable CAN BE USED


assign dataBlockEnable = (block0_hit | (miss_detected & ~isLRU1)) ? dataBlock0Enable :		// Enables one block in an even bit position or
			 (block1_hit | (miss_detected & ~isLRU0)) ? dataBlock1Enable : 128'b0;	// enables one block in an odd bit position



endmodule

module OneHotCounter(clk,rst,startCount,offset_in,offset_out);
input clk,rst,startCount;
input [7:0] offset_in;
output reg [7:0] offset_out; // I think this needs to change to be a dff

reg [7:0] offset_1,offset_2,offset_3,offset_4;

assign	offset_4 = startCount ? offset_in : 8'h00;

always @(posedge clk) begin
        if (rst) begin
                offset_3 <= 0;
                offset_2 <= 0;
                offset_1 <= 0;
                offset_out <= 0;
        end
        else begin
                offset_3 <= offset_4;
                offset_2 <= offset_3;
                offset_1 <= offset_2;
                offset_out <= offset_1;

        end
  end

endmodule
