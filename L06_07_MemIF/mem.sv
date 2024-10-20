///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : mem.sv
// Title       : Memory Module
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Defines the memory module
// Notes       :
// Synchronous 8x32 Memory Design
// Specification:
//  Memory is 8-bits wide and address range is 0 to 31.
//  Memory access is synchronous.
//  Write data into the memory on posedge of clk when write=1
//  Place memory[addr] onto data bus on posedge of clk when read=1
//  The read and write signals should not be simultaneously high.
// 
///////////////////////////////////////////////////////////////////////////

module mem (
/*   input        clk,
	input        read,
	input        write, 
	input  logic [4:0] addr  ,
	input  logic [7:0] data_in  ,
        output logic [7:0] data_out */
  mem_ifa mem_bus
	   );
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

// SYSTEMVERILOG: logic data type
logic [7:0] memory [0:31] ;
  
  always @(posedge mem_bus.clk)
    if (mem_bus.write && !mem_bus.read)
// SYSTEMVERILOG: time literals
      #1 memory[mem_bus.addr] <= mem_bus.data_in;

// SYSTEMVERILOG: always_ff and iff event control
  always_ff @(posedge mem_bus.clk iff ((mem_bus.read == '1)&&(mem_bus.write == '0)) )
       mem_bus.data_out <= memory[mem_bus.addr];

endmodule
