module cache_fill_FSM(clk, rst, miss_detected, miss_address, memory_busy, fsm_busy, write_data_array, write_tag_array,memory_address, memory_data, memory_data_valid,dataOut); 

input clk, rst; 
input miss_detected; // active high when tag match logic detects a miss 
input [15:0] miss_address; // address that missed the cache 
input memory_busy;

input [15:0] memory_data; // data returned by memory (after  delay) 
input memory_data_valid; // active high indicates valid data returning on memory bus 

output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal) 
output write_data_array; // write enable to cache data array to signal when filling with memory_data 
output write_tag_array; // write enable to cache tag array to signal when all words are filled in to data array 
output [15:0] memory_address; // address to read from memory 
output [15:0] dataOut; 	 //value in memory of requested address

logic [3:0] offset_value; //i dont like this

/**
Cache is 2^11=2048 bytes & 2 way set associative with 16 byte cache blocks
-2^6 = 64 sets with 8 entries in a block = 16 byte blocks/offset, so tag = 16 - 6 - 3 = 7 bits
t = 7, s = 6, o = 3
**/




typedef enum {IDLE,WAIT} state_t; //Tracks if FSM has entered miss or not
typedef enum {enter_miss_cycle,BYTES_0_1,BYTES_2_3,BYTES_4_5,BYTES_6_7,BYTES_8_9,
		BYTES_10_11,BYTES_12_13,BYTES_14_15,sequential_delay1,
		sequential_delay2,sequential_delay3,sequential_delay4, done} offset_byte_t;//used inside wait state
typedef enum {HOLD,WAIT0,WAIT1,WAIT2,WAIT3,SAVE_VALUE} delay_t; //used to capture value request in a Mem Read
state_t state,next_state; // 
offset_byte_t offset_byte,next_offset_byte;
delay_t current_delay,next_delay;

wire [15:0] savedDataOut;
wire save_data_value,address_match;
assign address_match = memory_address == miss_address;
assign save_data_value = current_delay == SAVE_VALUE;

dff Saved_data[15:0](.q(savedDataOut), .d(memory_data), .wen(save_data_value), .clk(clk), .rst(rst));
assign  dataOut = (save_data_value && (offset_byte == sequential_delay4)) ? memory_data: savedDataOut;

wire [15:0] offset_value_zero_extended;

assign offset_value_zero_extended = {12'h000,offset_value};

adder_16bit memory_address_adder(.A({miss_address[15:4],4'h0}), .B(offset_value_zero_extended), .Sub(1'b0), .Sum(memory_address), .Zero(), .Ovfl(), .Sign());

assign fsm_busy = miss_detected;//(state == WAIT & offset_byte != done) | (next_state == WAIT & next_offset_byte == enter_miss_cycle); //fsm_busy should 1 when fsm is gathering data. The second case occurs when the fill fsm is about to enter the cache miss loop
assign write_data_array = memory_data_valid; 

assign write_tag_array = fsm_busy & (offset_byte == sequential_delay4); //only high when all 4 mem reads are done

always @(posedge clk) begin
	if(rst) begin
		state <= IDLE;
		offset_byte <= done;
		current_delay <= HOLD;
	end
	else begin
		state <= next_state;
		current_delay <= next_delay;
		offset_byte <= next_offset_byte;
	end
end

always_comb begin
	next_state = IDLE;
	next_offset_byte = enter_miss_cycle;
	offset_value = 4'h0;
	next_delay = HOLD;


	case(state) 
		IDLE: begin
			if(miss_detected & ~memory_busy) begin
				next_state = WAIT;
				next_offset_byte = enter_miss_cycle;
			end
			else
				next_state = IDLE;
				//next_offset_byte = done;
			end

		WAIT: begin
		
			case(offset_byte)
			enter_miss_cycle: begin
				offset_value = 4'h0;
				next_offset_byte = BYTES_0_1;
				next_state = WAIT;
			end
			BYTES_0_1: begin
				offset_value = 4'h0;
				next_offset_byte = BYTES_2_3;
				next_state = WAIT;
			end
				BYTES_2_3: begin
				offset_value = 4'h2;
				next_offset_byte = BYTES_4_5;
				next_state = WAIT;
			end
				BYTES_4_5: begin
				offset_value = 4'h4;
				next_offset_byte = BYTES_6_7;
				next_state = WAIT;
			end
				BYTES_6_7: begin
				offset_value = 4'h6;
				next_offset_byte = BYTES_8_9;
				next_state = WAIT;
			end
				BYTES_8_9: begin
				offset_value = 4'h8;
				next_offset_byte = BYTES_10_11;
				next_state = WAIT;
			end
				BYTES_10_11: begin
				offset_value = 4'hA;
				next_offset_byte = BYTES_12_13;
				next_state = WAIT;
			end
				BYTES_12_13: begin
				offset_value = 4'hC;
				next_offset_byte = BYTES_14_15;
				next_state = WAIT;
			end
				BYTES_14_15: begin
				offset_value = 4'hE;
				next_offset_byte = sequential_delay1;
				next_state = WAIT;
			end
			sequential_delay1: begin
				offset_value = 4'hE;
				next_offset_byte = sequential_delay2;
				next_state = WAIT;
			end
			sequential_delay2: begin
				offset_value = 4'hE;
				next_offset_byte = sequential_delay3;
				next_state = WAIT;
			end
			sequential_delay3: begin
				offset_value = 4'hE;
				next_offset_byte = sequential_delay4;
				next_state = WAIT;
			end
			sequential_delay4: begin
				offset_value = 4'hE;
				next_offset_byte = done;
				next_state = WAIT;
			end
		
			done: begin
					offset_value = 4'hF; //default high
					next_state = IDLE;
			end
			default: begin // should not be reached
				offset_value = 4'hF; //default high
			end
			
		endcase
			
		end

		default: begin //should not be entered
		end

	endcase

	case(current_delay)
		HOLD: begin
			if(address_match) begin
				next_delay = WAIT0;
			end
			else begin
				next_delay = HOLD;
			end
		end
		WAIT0: begin 
			next_delay = WAIT1;
		end
		WAIT1: begin
			next_delay = WAIT2;
		end
		WAIT2: begin		
			next_delay = WAIT3;
		end
		WAIT3: begin		
			next_delay = SAVE_VALUE;
		end
		SAVE_VALUE: begin 
			next_delay = HOLD;
		end
	endcase

	
end
endmodule
