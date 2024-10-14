///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : control.sv
// Title       : Control Module
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Defines the Control module
// Notes       :
// 
///////////////////////////////////////////////////////////////////////////

// import SystemVerilog package for opcode_t and state_t
import typedefs::*;

module control (
                output logic      load_ac ,
                output logic      mem_rd  ,
                output logic      mem_wr  ,
                output logic      inc_pc  ,
                output logic      load_pc ,
                output logic      load_ir ,
                output logic      halt    ,
                input  opcode_t opcode  , // opcode type name must be opcode_t
                input             zero    ,
                input             clk     ,
                input             rst_   
                );
// SystemVerilog: time units and time precision specification
timeunit 1ns;
timeprecision 100ps;

state_t state;
logic ALUOP;


always_ff @(posedge clk or negedge rst_) begin
  if (!rst_) begin
     state <= INST_ADDR;
  end
  else begin
     case (state) 
        INST_ADDR: state <= INST_FETCH;
        INST_FETCH: state <= INST_LOAD;
        INST_LOAD: state <= IDLE;
        IDLE: state <= OP_ADDR;
        OP_ADDR: state <= OP_FETCH;
        OP_FETCH: state <= ALU_OP;
        ALU_OP: state <= STORE;
        STORE: state <= INST_ADDR;
        default: state <= INST_ADDR;
     endcase
  end
end

always_comb begin
   ALUOP = (opcode inside {ADD, AND, XOR, LDA})? 1 : 0;
   {load_ac, mem_rd, mem_wr, inc_pc, load_pc, load_ir, halt} = 7'b0;
   unique case (state)
      INST_ADDR: begin
         mem_rd  = 1'b0;
         load_ir = 1'b0;
         halt    = 1'b0;
         inc_pc  = 1'b0;
         load_ac = 1'b0;
         load_pc = 1'b0;
         mem_wr  = 1'b0;
      end
      INST_FETCH: begin
         mem_rd  = 1'b1;
         load_ir = 1'b0;
         halt    = 1'b0;
         inc_pc  = 1'b0;
         load_ac = 1'b0;
         load_pc = 1'b0;
         mem_wr  = 1'b0;
      end
      INST_LOAD: begin
         mem_rd  = 1'b1;
         load_ir = 1'b1;
         halt    = 1'b0;
         inc_pc  = 1'b0;
         load_ac = 1'b0;
         load_pc = 1'b0;
         mem_wr  = 1'b0;
      end
      IDLE: begin
         mem_rd  = 1'b1;
         load_ir = 1'b1;
         halt    = 1'b0;
         inc_pc  = 1'b0;
         load_ac = 1'b0;
         load_pc = 1'b0;
         mem_wr  = 1'b0;
      end
      OP_ADDR: begin
         mem_rd  = 1'b0;
         load_ir = 1'b0;
         halt    = (opcode == HLT)? 1'b1 : 1'b0;
         inc_pc  = 1'b1;
         load_ac = 1'b0;
         load_pc = 1'b0;
         mem_wr  = 1'b0;
      end
      OP_FETCH: begin
         mem_rd  = (ALUOP)? 1'b1 : 1'b0;
         load_ir = 1'b0;
         halt    = 1'b0;
         inc_pc  = 1'b0;
         load_ac = 1'b0;
         load_pc = 1'b0;
         mem_wr  = 1'b0;
      end
      ALU_OP: begin
         mem_rd  = (ALUOP)? 1'b1 : 1'b0;
         load_ir = 1'b0;
         halt    = 1'b0;
         inc_pc  = (opcode == SKZ && zero)? 1'b1 : 1'b0;
         load_ac = (ALUOP)? 1'b1 : 1'b0;
         load_pc = (opcode == JMP)? 1'b1 : 1'b0;
         mem_wr  = 1'b0;
      end
      STORE: begin
         mem_rd = (ALUOP)? 1'b1 : 1'b0;
         load_ir = 1'b0;
         halt    = 1'b0;
         inc_pc  = (opcode == JMP)? 1'b1 : 1'b0;
         load_ac = (ALUOP)? 1'b1 : 1'b0;
         load_pc = (opcode == JMP)? 1'b1 : 1'b0;
         mem_wr  = (opcode == STO)? 1'b1 : 1'b0;
      end
      default: begin
         mem_rd  = 1'b0;
         load_ir = 1'b0;
         halt    = 1'b0;
         inc_pc  = 1'b0;
         load_ac = 1'b0;
         load_pc = 1'b0;
         mem_wr  = 1'b0;
      end
   endcase
end
endmodule
