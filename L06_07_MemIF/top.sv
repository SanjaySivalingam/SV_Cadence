///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : top.sv
// Title       : top module for Memory labs 
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Defines the top module for memory labs
// Notes       :
// Memory Lab - top-level 
// A top-level module which instantiates the memory and mem_test modules
// 
///////////////////////////////////////////////////////////////////////////

module top;
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

// SYSTEMVERILOG: logic and bit data types
bit         clk;
/*wire       read;
wire       write;
wire [4:0] addr;

wire [7:0] data_out;      // data_from_mem
wire [7:0] data_in;       // data_to_mem */

mem_ifa busA(clk);

// SYSTEMVERILOG:: implicit .* port connections
mem_test test (.mem_bus(busA.mem_test)); //modport

// SYSTEMVERILOG:: implicit .name port connections
mem memory (.mem_bus(busA.mem)); //modport

always #5 clk = ~clk;
endmodule
