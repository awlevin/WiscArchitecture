module cpu_master_tb();
  
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
   wire [15:0] MemData;

   wire        Halt;         /* Halt executed and in Memory or writeback stage */
        
   integer     inst_count;
   integer     cycle_count;

   integer     trace_file;
   integer     sim_log_file;

   reg clk; /* Clock input */
   reg rst_n; /* (Active low) Reset input */

     

   cpu DUT(.clk(clk), .rst_n(rst_n), .pc(PC), .hlt(Halt)); /* Instantiate your processor */
   






   /* Setup */
   initial begin
      $display("Hello world...simulation starting");
      $display("See verilogsim.log and verilogsim.trace for output");
      inst_count = 0;
      trace_file = $fopen("verilogsim.trace");
      sim_log_file = $fopen("verilogsim.log");
      
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

    always #50 begin  // delay 1/2 clock period each time thru loop
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

     Print_Instruction(Inst,PC);

      if (rst_n) begin
         if (Halt || RegWrite || MemWrite) begin
            inst_count = inst_count + 1;
         end
         $fdisplay(sim_log_file, "SIMLOG:: Cycle %d PC: %8x I: %8x R: %d %3d %8x M: %d %d %8x %8x",
                  cycle_count,
                  PC,
                  Inst,
                  RegWrite,
                  WriteRegister,
                  WriteData,
                  MemRead,
                  MemWrite,
                  MemAddress,
                  MemData);
         if (RegWrite) begin
            if (MemRead) begin
              // ld
               $fdisplay(trace_file,"INUM: %8d PC: 0x%04x REG: %d VALUE: 0x%04x ADDR: 0x%04x",
                         (inst_count-1),
                        PC,
                        WriteRegister,
                        WriteData,
                        MemAddress);
            end else begin
               $fdisplay(trace_file,"INUM: %8d PC: 0x%04x REG: %d VALUE: 0x%04x",
                         (inst_count-1),
                        PC,
                        WriteRegister,
                        WriteData );
            end
         end else if (Halt) begin
            $fdisplay(sim_log_file, "SIMLOG:: Processor halted\n");
            $fdisplay(sim_log_file, "SIMLOG:: sim_cycles %d\n", cycle_count);
            $fdisplay(sim_log_file, "SIMLOG:: inst_count %d\n", inst_count);
            $fdisplay(trace_file, "INUM: %8d PC: 0x%04x",
                      (inst_count-1),
                      PC );

            $fclose(trace_file);
            $fclose(sim_log_file);
            
            $stop;
         end else begin
            if (MemWrite) begin
              // st
               $fdisplay(trace_file,"INUM: %8d PC: 0x%04x ADDR: 0x%04x VALUE: 0x%04x",
                         (inst_count-1),
                        PC,
                        MemAddress,
                        MemData);
            end else begin
              // conditional branch or NOP
              // Need better checking in pipelined testbench
               inst_count = inst_count + 1;
               $fdisplay(trace_file, "INUM: %8d PC: 0x%04x",
                         (inst_count-1),
                         PC );
            end
         end 
      end
      
   end


   /* Assign internal signals to top level wires
      The internal module names and signal names will vary depending
      on your naming convention and your design */

  // Edit the example below. You must change the signal
  // names on the right hand side
    
//  assign PC = DUT.fetch0.pcCurrent; //You won't need this because it's part of the main cpu interface
  assign Inst = DUT.instr;//DUT.fetch0.instr;
   
  assign RegWrite = DUT.writeReg;//DUT.decode0.regFile0.write;
  // Is memory being read, one bit signal (1 means yes, 0 means no)
   
  assign WriteRegister = DUT.dstReg;//DUT.decode0.regFile0.writeregsel;
  // The name of the register being written to. (4 bit signal)

  assign WriteData = DUT.dstData;//DUT.decode0.regFile0.writedata;
  // Data being written to the register. (16 bits)
   
  assign MemRead = (DUT.dataEnable & ~DUT.dataWr);//DUT.memory0.memRead;
  // Is memory being read, one bit signal (1 means yes, 0 means no)
   
  assign MemWrite = (DUT.dataEnable & DUT.dataWr);//(DUT.memory0.memReadorWrite & DUT.memory0.memWrite);
  // Is memory being written to (1 bit signal)
   
  assign MemAddress = DUT.address;//DUT.memory0.aluResult;
  // Address to access memory with (for both reads and writes to memory, 16 bits)
   
  assign MemData = DUT.memDataIn;//DUT.memory0.writeData;
  // Data to be written to memory for memory writes (16 bits)
   
//  assign Halt = DUT.memory0.halt; //You won't need this because it's part of the main cpu interface
  // Is processor halted (1 bit signal)
   
   /* Add anything else you want here */

task Print_Instruction;
  input logic [15:0] instr,PC; 
  casex(instr[15:12])

  /* ADD */ 
  4'h0 :
  begin $display("ADD %d %d %d",instr[11:8],instr[7:4],instr[3:0]); end

  /* SUB */ 
  4'h1 :
  begin $display("SUB %d %d %d",instr[11:8],instr[7:4],instr[3:0]); end

  /* XOR */ 
  4'h2 :
  begin $display("XOR %d %d %d",instr[11:8],instr[7:4],instr[3:0]); end

  /* RED */ 
  4'h3 :
  begin $display("RED %d %d %d",instr[11:8],instr[7:4],instr[3:0]); end

  /* SLL */ 
  4'h4 :
  begin $display("SLL %d %d %d",instr[11:8],instr[7:4],instr[3:0]); end

  /* SRA */ 
  4'h5 :
  begin $display("SRA %d %d %d",instr[11:8],instr[7:4],instr[3:0]); end

  /* ROR */ 
  4'h6 :
  begin $display("ROR %d %d %d",instr[11:8],instr[7:4],instr[3:0]); end

  /* PADDSB */  
  4'h7 :
  begin $display("PADDSB %d %d %d",instr[11:8],instr[7:4],instr[3:0]); end

  /* LW */  
  4'h8 : 
  begin $display("LW %d,%d(%d)",instr[11:8],instr[7:4],{{11{instr[3]}}, instr[3:0], 1'b0}); end 

  /* SW */  
  4'h9  : 
  begin $display("SW %d,%d(%d)",instr[11:8],instr[7:4],{{11{instr[3]}}, instr[3:0], 1'b0}); end 

  /* LLB */ 
  4'hA  : 
  begin $display("LLB %d %d %d",instr[11:8],instr[11:8],instr[7:0]); end 

  /* LHB */
  4'hB : 
  begin  $display("LHB %d %d %d",instr[11:8],instr[11:8],instr[7:0]); end 

  /* B */
  4'b1100 : 
  begin  $display("B CCC:%h to:%d",instr[11:9],instr[8:0]); end

  /* BR */
  4'b1101 : 
  begin  $display("BR CCC:%h to: %d",instr[11:9],instr[7:4]); end

  /* PCS */
  4'b1110 : 
  begin  $display("PCS %d gets %h",instr[11:8],PC); end

  /* HALT */
  4'b1111 :
  begin $display("HALT"); end
  default
  begin 
/*
    //wire [15:0] instr; // bits [15:12] are the opcode

    // Register Vars
    srcReg1    = 1'b0; 
    srcReg2    = 1'b0;
    dstReg     = 1'b0;
    writeReg   = 1'b0;

    // ALU Vars
    aluIn1     = 16'h0000;
    aluIn2     = 16'h0000;
    aluOp    = 4'h0;

    //LHB/LLB
    immediate  = 16'h0000;

    // Memory Vars
    offset     = 16'h0000;
    address    = 16'h0000;
    memDataIn  = 16'h0000;
    dataWr     = 1'b0;
    dataEnable = 1'b0;
*/
  end 
endcase 
endtask
endmodule
