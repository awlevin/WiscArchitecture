module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy, write_data_array, write_tag_array,memory_address, memory_data, memory_data_valid); 

input clk, rst_n; 
input miss_detected; // active high when tag match logic detects a miss 
input [15:0] miss_address; // address that missed the cache 

input [15:0] memory_data; // data returned by memory (after  delay) 
input memory_data_valid; // active high indicates valid data returning on memory bus 

output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal) 
output write_data_array; // write enable to cache data array to signal when filling with memory_data 
output write_tag_array; // write enable to cache tag array to signal when all words are filled in to data array 
output [15:0] memory_address; // address to read from memory 

logic [3:0] offset_value; //i dont like this

wire [3:0] offset_value_in,offset_value_out; //note: this signal is added to itself
//dff_4bit offset(.clk(clk), .rst(~rst_n), .q(offset_value_out), .d(offset_value_in), .wen(1'b1)); //used to incrememnt which address is request(is either 0,2,4, or 6)

/**
Cache is 2^11=2048 bytes & 2 way set associative with 16 byte cache blocks
-2^6 = 64 sets with 2^4 = 16 byte blocks/offset, so tag = 16 - 6 - 4 = 6 bits
t = 6, s = 6, o = 4
**/


typedef enum {IDLE,WAIT} state_t;
typedef enum {BYTES_0_1,BYTES_2_3,BYTES_4_5,BYTES_6_7, done} offset_byte_t;//used inside wait state
state_t state,next_state; //state defaults to IDLE, I think?
offset_byte_t offset_byte,next_offset_byte;

wire [15:0] offset_value_zero_extended;

assign offset_value_zero_extended = {12'h000,offset_value};

adder_16bit memory_address_adder(.A(miss_address), .B(offset_value_zero_extended), .Sub(1'b0), .Sum(memory_address), .Zero(), .Ovfl(), .Sign());

assign fsm_busy = (state == WAIT); //fsm_busy should 1 when fsm is gathering data
assign write_data_array = fsm_busy; //are these signals equivalent?

assign write_tag_array = fsm_busy & (offset_byte == done); //only high when all 4 mem reads are done


always @(posedge clk) begin

	state = next_state;

	case(state) 
		IDLE: begin
			if(miss_detected) begin
				next_state = WAIT;
				next_offset_byte = BYTES_0_1;
			end
		end

		WAIT: begin
		

			
			//tag = memory_address[15:10]; //tag is first 6 bits
				
			if(memory_data_valid) begin
				offset_byte = next_offset_byte;
			end
		end

		default: begin //should not be entered
		end

	endcase

	case(offset_byte)
			BYTES_0_1: begin
				offset_value = 4'h0;
				next_offset_byte = BYTES_2_3;
			end
				BYTES_2_3: begin
				offset_value = 4'h2;
				next_offset_byte = BYTES_4_5;
			end
				BYTES_4_5: begin
				offset_value = 4'h4;
				next_offset_byte = BYTES_6_7;
			end
				BYTES_6_7: begin
				offset_value = 4'h6;
				next_offset_byte = done;
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
endmodule
