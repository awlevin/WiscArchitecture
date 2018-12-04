/** TODO 
We use a lot of shifts ... are shifts ok or should we use our module?
**/
module Cache(clk, rst, address, dataIn, writeEn, readEn, memory_data_valid, stall, dataOut, missedAddressToGet, cache_hit);

input clk,rst;
input [15:0] address;
input [15:0] dataIn;
input writeEn;
input readEn;
input memory_data_valid;

output stall;
output [15:0] dataOut;
output [15:0] missedAddressToGet;
output cache_hit;

wire [6:0] tagBits;
wire [5:0] setBits;
wire [2:0] offsetBits;

// Metadata Array signals
wire [63:0] SetEnable;
wire valid0, valid1;
wire [6:0] tagBlock0, tagBlock1;
wire block0_hit,block1_hit;

// Cache Fill FSM/ miss signals
wire write_tag_array, write_data_array;
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

//LRU logic
wire block0_isLRU, block1_isLRU;
wire LRU_writeEn,LRU_block_selected,block1_isLRU_saved;
dff saved_block1_isLRU(.q(block1_isLRU_saved), .d(block1_isLRU), .wen(miss_detected), .clk(clk), .rst(rst));

//fixes metastability issue on last cycle of miss 
assign LRU_block_selected = cache_hit ? block1_hit : (write_tag_array & block1_isLRU_saved);

assign LRU_writeEn = cache_hit | write_tag_array;

wire [15:0] address_shifted_right1;
assign address_shifted_right1 = address >> 1; // because address is byte aligned by 1, it must be divided by 2

assign tagBits = address_shifted_right1[15:9];
assign setBits = address_shifted_right1[8:3];
assign offsetBits = address_shifted_right1[2:0]; // if miss detected, must use address coming out of fill_fsm, which has the incremented offset

assign dataOut = cache_hit ? dataArrayOut : cache_miss_dataOut;

DataArray data(.clk(clk), .rst(rst), .DataIn(dataIn), .Write(dataWrite), .BlockEnable(dataBlockEnable), .WordEnable(dataWordEnable), .DataOut(dataArrayOut));

MetaDataArray tags(.clk(clk), .rst(rst), .DataIn({1'b1, tagBits}), .SetEnable(SetEnable), .Write0(block0_isLRU & write_tag_array), .Write1(block1_isLRU & write_tag_array), .DataOut0({valid0, tagBlock0}), .DataOut1({valid1, tagBlock1}));

cache_fill_FSM fill_fsm(.clk(clk), .rst(rst), .miss_detected(miss_detected), .miss_address(address), .fsm_busy(stall), .write_data_array(write_data_array), .write_tag_array(write_tag_array), .memory_address(missedAddressToGet), .memory_data(dataIn), .memory_data_valid(memory_data_valid), .dataOut(cache_miss_dataOut));

LRUArray LRU(.clk(clk), .rst(rst), .writeEn(LRU_writeEn), .SetEnable(SetEnable), .Block(LRU_block_selected), .block0_isLRU(block0_isLRU), .block1_isLRU(block1_isLRU));

assign block0_hit = write_tag_array ? 1'b0 : valid0 & (tagBits == tagBlock0);
assign block1_hit = write_tag_array ? 1'b0 : valid1 & (tagBits == tagBlock1);

assign dataWrite = (write_data_array & miss_detected) | (((tagBits == tagBlock0) | (tagBits == tagBlock1)) & writeEn); // Enables a write if cache is being filled or we have a hit and are writing (SW instruction)

assign SetEnable = (1 << setBits); // Enables two blocks in the tag array tied to a set (0 through 63)

//mux fixes a metastability issue on the last cycle of the miss
assign miss_detected = write_tag_array ? 1'b1 : ~(block0_hit | block1_hit);	// Asserted if data is not in either block
assign cache_hit = ~miss_detected;

//if miss,use output of oneHotCounter
assign dataWordEnable = miss_detected ? oneHot_offset :(1 << offsetBits); // Enables one word (0 through 7) to be enabled in a block


assign dataBlock0Enable = (1 << (setBits << 1));
assign dataBlock1Enable = (2 << (setBits << 1)); //WE MIGHT BE DUPLICATING SHIFTERS CHECK IF SetEnable CAN BE USED
/**
assign dataBlock0Enable = ((1 << setBits) << setBits);
assign dataBlock1Enable = ((2 << setBits) << setBits);
**/

assign dataBlockEnable = (block0_hit | (miss_detected & block0_isLRU)) ? dataBlock0Enable :		// Enables one block in an even bit position or
			 (block1_hit | (miss_detected & block1_isLRU)) ? dataBlock1Enable : 128'b0;	// enables one block in an odd bit position



endmodule

//module miss_reg(clk,rst,miss_detected,);

//endmodule

//counts to 8
//NEEDS rst logic
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

/**
always @(posedge clk) begin
	count_state = next_count_state;
	case(count_state)
		IDLE: begin
			if(startCount)begin
				next_count_state = COUNT;
				counter = 8'h01;
			end
			else begin
				next_count_state = IDLE;
				counter = 8'h00;
			end
		end
		COUNT: begin
			if(counter == 8'h00)begin
				next_count_state = COUNT;
				counter = 8'h00;
			end
			else begin
				next_count_state = IDLE;
				counter = counter << 1;
			end
		end
	endcase
end
**/
endmodule
