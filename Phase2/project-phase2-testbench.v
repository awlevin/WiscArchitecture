module cpu_ptb();
  

   wire [15:0] PC;
   wire [15:0] Inst;           /* This should be the 15 bits of the FF that
                                  stores instructions fetched from instruction memory
                               */
   wire        RegWrite;       /* Whether register file is being written to */
   wire [3:0]  WriteRegister;  /* What register is written */
   wire [15:0] WriteData;      /* Data */
   wire        MemWrite;       /* Similar as above but for memory */
   wire        MemRead;
   wire [15:0] MemAddress;
   wire [15:0] MemDataIn;	/* Read from Memory */
   wire [15:0] MemDataOut;	/* Written to Memory */

   wire        Halt;         /* Halt executed and in Memory or writeback stage */
        
   integer     inst_count;
   integer     cycle_count;

   integer     trace_file;
   integer     sim_log_file;

   reg clk; /* Clock input */
   reg rst_n; /* (Active low) Reset input */

     

   cpu DUT(.clk(clk), .rst_n(rst_n), .pc_out(PC), .hlt(Halt)); /* Instantiate your processor */
   






   /* Setup */
   initial begin
      $display("Hello world...simulation starting");
      $display("See verilogsim.plog and verilogsim.ptrace for output");
      inst_count = 0;
      trace_file = $fopen("verilogsim.ptrace");
      sim_log_file = $fopen("verilogsim.plog");
      
   end





  /* Clock and Reset */
// Clock period is 100 time units, and reset length
// to 201 time units (two rising edges of clock).

   initial begin
      $dumpvars;
      cycle_count = 0;
      rst_n = 0; /* Intial reset state */
      clk = 1;
      #201 rst_n = 1; // delay until slightly after two clock periods
    end

    always #50 begin   // delay 1/2 clock period each time thru loop
      clk = ~clk;
    end
	
    always @(posedge clk) begin
    	cycle_count = cycle_count + 1;
	if (cycle_count > 100000) begin
		$display("hmm....more than 100000 cycles of simulation...error?\n");
		$stop;
	end
    end








  /* Stats */
   always @ (posedge clk) begin
      if (rst_n) begin
         if (Halt || RegWrite || MemWrite) begin
            inst_count = inst_count + 1;
         end
         $fdisplay(sim_log_file, "SIMLOG:: Cycle %d PC: %8x I: %8x R: %d %3d %8x M: %d %d %8x %8x %8x",
                  cycle_count,
                  PC,
                  Inst,
                  RegWrite,
                  WriteRegister,
                  WriteData,
                  MemRead,
                  MemWrite,
                  MemAddress,
                  MemDataIn,
		  MemDataOut);
         if (RegWrite) begin
            $fdisplay(trace_file,"REG: %d VALUE: 0x%04x",
                      WriteRegister,
                      WriteData );            
         end
         if (MemRead) begin
            $fdisplay(trace_file,"LOAD: ADDR: 0x%04x VALUE: 0x%04x",
                      MemAddress, MemDataOut );
         end

         if (MemWrite) begin
            $fdisplay(trace_file,"STORE: ADDR: 0x%04x VALUE: 0x%04x",
                      MemAddress, MemDataIn  );
         end
         if (Halt) begin
            $fdisplay(sim_log_file, "SIMLOG:: Processor halted\n");
            $fdisplay(sim_log_file, "SIMLOG:: sim_cycles %d\n", cycle_count);
            $fdisplay(sim_log_file, "SIMLOG:: inst_count %d\n", inst_count);

            $fclose(trace_file);
            $fclose(sim_log_file);
	    #5;
            $finish;
         end 
      end
      
   end
   /* Assign internal signals to top level wires
      The internal module names and signal names will vary depending
      on your naming convention and your design */

   // Edit the example below. You must change the signal
   // names on the right hand side
    
//   assign PC = DUT.fetch0.pcCurrent; //You won't need this because it's part of the main cpu interface
   
//   assign Halt = DUT.memory0.halt; //You won't need this because it's part of the main cpu interface
   // Is processor halted (1 bit signal)
   

  assign Inst = DUT.instr;//DUT.fetch0.instr;
   
  assign RegWrite = DUT.mem_wb_regWrite_out;
  // Is memory being read, one bit signal (1 means yes, 0 means no)
   
  assign WriteRegister = DUT.mem_wb_dstReg_out;//Dst reg??
  // The name of the register being written to. (4 bit signal)

  assign WriteData = DUT.writeback_write_data;
  // Data being written to the register. (16 bits)
   
  assign MemRead = (DUT.ex_mem_memRead_out & ~DUT.ex_mem_memWrite_out);
  // Is memory being read, one bit signal (1 means yes, 0 means no)
   
  assign MemWrite = (~DUT.ex_mem_memRead_out & DUT.ex_mem_memWrite_out);
  // Is memory being written to (1 bit signal)
   
  assign MemAddress = DUT.ex_mem_alu_result_out;
  // Address to access memory with (for both reads and writes to memory, 16 bits)
   
  assign MemData = DUT.ex_mem_dataIn_in;
  // Data to be written to memory for memory writes (16 bits)
   
//  assign Halt = DUT.memory0.halt; //You won't need this because it's part of the main cpu interface
  // Is processor halted (1 bit signal)

  assign MemDataIn = DUT.ex_mem_dataIn_out;

  assign MemDataOut = DUT.mem_wb_read_memData_in;


   /* Add anything else you want here */

   
endmodule
