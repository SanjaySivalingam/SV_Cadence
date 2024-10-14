///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : mem_intf.sv
// Title       : Memory interface
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Defines the Memory interface with clk port, modport and
// methods
// Notes       :
//
///////////////////////////////////////////////////////////////////////////

interface mem_intf(input logic clk);
//SYSTEMVERILOG: timeunit and timeprecision notation
  timeunit 1ns;
  timeprecision 100ps;

//SYSTEMVERILOG: logic data types
  logic [7:0] data_in;
  logic [7:0] data_out;
  logic [4:0] addr;
  logic read;
  logic write;

// SYSTEMVERILOG: modports in an interface
  modport tb  ( input data_out, clk,  
                output data_in, addr, read, write );

  modport mem ( output data_out, 
                input  clk, data_in, addr, read, write );

//moved to class
/*   task write_mem (input [4:0] waddr, input [7:0] wdata, input debug = 0);
    @(negedge clk);
    write <= 1;
    read  <= 0;
    addr  <= waddr;
    data_in  <= wdata;
    @(negedge clk);
    write <= 0;
    if (debug == 1)
      $display("Write - Address:%d  Data:%c", waddr, wdata);
  endtask
  
  task read_mem (input [4:0] raddr, output [7:0] rdata, input debug = 0);
     @(negedge clk);
     write <= 0;
     read  <= 1;
     addr  <= raddr;
     @(negedge clk);
     read <= 0;
     rdata = data_out;
     if (debug == 1) 
       $display("Read  - Address:%d  Data:%c", raddr, rdata);
  endtask */

endinterface : mem_intf
