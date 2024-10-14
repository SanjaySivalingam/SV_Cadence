///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : mem_test.sv
// Title       : Memory Testbench Module
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Defines the Memory testbench module
// Notes       :
// 
///////////////////////////////////////////////////////////////////////////

module mem_test ( /* input logic clk, 
                  output logic read, 
                  output logic write, 
                  output logic [4:0] addr, 
                  output logic [7:0] data_in,     // data TO memory
                  input  wire [7:0] data_out     // data FROM memory */
                  mem_ifa mem_bus
                );
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

// SYSTEMVERILOG: new data types - bit ,logic
bit         debug = 1;
logic [7:0] rdata;      // stores data read from memory for checking

// Monitor Results
  initial begin
      $timeformat ( -9, 0, " ns", 9 );
// SYSTEMVERILOG: Time Literals
      #40000ns $display ( "MEMORY TEST TIMEOUT" );
      $finish;
    end

initial
  begin: memtest
    int error_status;

    @(negedge mem_bus.clk) mem_bus.read = 0; mem_bus.write = 1; mem_bus.addr = 0;

    $display("Clear Memory Test");

    for (int i = 0; i< 32; i++) 
      begin
        @(posedge mem_bus.clk)
       // Write zero data to every address location
        mem_bus.write_mem(.wr_addr(i), .wr_data(8'b0), .debug(debug));
      end
    
    @(negedge mem_bus.clk) mem_bus.read = 1; mem_bus.write = 0; mem_bus.addr = 0;

    for (int i = 0; i<32; i++)
      begin 
       // Read every address location
        @(posedge mem_bus.clk)
        mem_bus.read_mem(.rd_addr(i), .rd_data(rdata), .debug(debug));
       // check each memory location for data = 'h00
        if (rdata != 8'b0) begin
          $display("ERROR: Memory location %d has data = %h, expected = %h", i, rdata, 8'h00);
          error_status = error_status + 1;
        end
      end

   // print results of test
    mem_bus.printstatus(error_status);

    $display("Data = Address Test");
    
    @(negedge mem_bus.clk) mem_bus.read = 0; mem_bus.write = 1; mem_bus.addr = 0;

    for (int i = 0; i< 32; i++)
      begin
       // Write data = address to every address location
       @(posedge mem_bus.clk)
       mem_bus.write_mem(.wr_addr(i), .wr_data(i), .debug(debug));
      end

    @(negedge mem_bus.clk) mem_bus.read = 1; mem_bus.write = 0; mem_bus.addr = 0;

    for (int i = 0; i<32; i++)
      begin
       // Read every address location
       @(posedge mem_bus.clk)
       mem_bus.read_mem(.rd_addr(i), .rd_data(rdata), .debug(debug));
       // check each memory location for data = address
       if (rdata != i-1 && mem_bus.addr != 5'b0) begin
         $display("ERROR: Memory location %d has data = %h, expected = %h", i, rdata, i);
         error_status = error_status + 1;
       end
      end

   // print results of test
    mem_bus.printstatus(error_status);

    $finish;
  end : memtest

/* // add read_mem and write_mem tasks
task write_mem (input logic [4:0] wr_addr, input logic [7:0] wr_data, input logic debug = 0);
  addr = wr_addr;
  data_in = wr_data;
  if (debug) $display("Write: addr = %d, data = %d", addr, data_in);
endtask : write_mem

task read_mem (input logic [4:0] rd_addr, input logic debug = 0, output logic [7:0] rd_data);
  addr = rd_addr;
  #1 rd_data = data_out;
  if (debug) $display("Read: addr = %d, data = %d", addr, rd_data);
endtask : read_mem

// add result print function
function void printstatus (input integer error_status);
 if (error_status == 0)
    $display("TEST PASSED");
 else 
    $display("TEST FAILED");
endfunction : printstatus */

endmodule
