///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : mem_test.sv
// Title       : Memory Testbench Module
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Defines the Memory interface testbench module with 
// clk port, modport and methods
// Notes       :
// Memory Specification: 8x32 memory
//   Memory is 8-bits wide and address range is 0 to 31.
//   Memory access is synchronous.
//   The Memory is written on the positive edge of clk when "write" is high.
//   Memory data is driven onto the "data" bus when "read" is high.
//   The "read" and "write" signals should not be simultaneously high.
//
///////////////////////////////////////////////////////////////////////////

module mem_test ( 
                  mem_intf.tb mbus, mem_intf.tb m2bus 
                );
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

class randmem;
  rand bit [7:0] data;
  rand bit [4:0] addr;
  typedef enum logic [1:0] { M1=2'b00, M2=2'b01, M3=2'b10, M4=2'b11 } mode_t; // control knob
  
  rand mode_t mode;

  virtual interface mem_intf vif;

  constraint c1 { mode == M1 -> data >= 8'h20; data <= 8'h7f; } //printable ASCII
  constraint c2 { mode == M2 -> data inside { [8'h41:8'h5a] }; } //A-Z
  constraint c3 { mode == M3 -> data inside { [8'h61:8'h7a] }; } //a-z
  constraint c4 { mode == M4 -> data dist { [8'h41:8'h5a]:=80, [8'h61:8'h7a]:=20 }; } //A-Z 80% and a-z 20%

  function new (input bit [7:0] d, input bit [4:0] a);
    data = d;
    addr = a;
  endfunction

  function void configure (virtual interface mem_intf aif);
    vif = aif;
  endfunction

  task write_mem (input [4:0] waddr, input [7:0] wdata, input debug = 0);
    @(negedge vif.clk);
    vif.write <= 1;
    vif.read  <= 0;
    vif.addr  <= waddr;
    vif.data_in  <= wdata;
    @(negedge vif.clk);
    vif.write <= 0;
    if (debug == 1)
      $display("Write - Address:%0d  Data:%h", waddr, wdata);
  endtask
  
  task read_mem (input [4:0] raddr, output [7:0] rdata, input debug = 0);
     @(negedge vif.clk);
     vif.write <= 0;
     vif.read  <= 1;
     vif.addr  <= raddr;
     @(negedge vif.clk);
     vif.read <= 0;
     rdata = vif.data_out;
     if (debug == 1) 
       $display("Read  - Address:%0d  Data:%h", raddr, rdata);
  endtask

endclass

covergroup memcov @ (posedge mbus.clk);
  c1 : coverpoint mbus.addr;
  c2 : coverpoint mbus.data_in {
       bins uppercase = {[8'h41:8'h5a]};
       bins lowercase = {[8'h61:8'h7a]};
       bins rest      = default;
      }
  c3 : coverpoint mbus.data_out {
       bins uppercase = {[8'h41:8'h5a]};
       bins lowercase = {[8'h61:8'h7a]};
       bins rest      = default;
      }
endgroup: memcov

memcov cg = new();

randmem m1, m2;

bit         debug = 1;
logic [7:0] rdata;      // stores data read from memory for checking

bit [4:0] addr_store [31:0];

logic [7:0] dyn_arr [];

logic [7:0] assoc_arr [int];
int assoc_idx; 

typedef struct {
  bit [7:0] data;
  bit [4:0] addr;
} queue_struct;
queue_struct queue [$];
queue_struct item;
bit used_addr [int];


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
    int ok;

    m1 = new(8'h00, 5'h00);
    m1.configure(mbus); // 1st memory interface

    m2 = new(8'h00, 5'h00);
    m2.configure(m2bus); // 2nd memory interface
     
    $display("Clear Memory Test");
// SYSTEMVERILOG: enhanced for loop
    for (int i = 0; i< 32; i++)
       m1.write_mem (i, 0, debug);
    for (int i = 0; i<32; i++)
      begin 
       m1.read_mem (i, rdata, debug);
       // check each memory location for data = 'h00
       error_status = checkit (i, rdata, 8'h00);
      end
// SYSTEMVERILOG: void function
    printstatus(error_status);


    $display("Data = Address Test");
// SYSTEMVERILOG: enhanced for loop
    for (int i = 0; i< 32; i++)  
       m1.write_mem (i, i, debug);
    for (int i = 0; i<32; i++)
      begin
       m1.read_mem (i, rdata, debug);
       // check each memory location for data = address
       error_status = checkit (i, rdata, i);
      end
// SYSTEMVERILOG: void function
    printstatus(error_status);


    $display("Random Data Test");
// SYSTEMVERILOG: enhanced for loop
    for (int i = 0; i< 32; i++)
      begin
        ok = randomize(mbus.data_in); //random data 8bits
        m1.write_mem (i, mbus.data_in, debug);
      end
    for (int i = 0; i<32; i++)
      begin
        m1.read_mem (i, rdata, debug);
        error_status = checkit (i, rdata, mbus.data_out);
      end
// SYSTEMVERILOG: void function
    printstatus(error_status);


    $display("Random Data Test with Constraints-1");
// SYSTEMVERILOG: enhanced for loop
    for (int i = 0; i< 32; i++)
      begin
        ok = randomize(mbus.data_in) with { mbus.data_in >= 8'h20 && mbus.data_in <= 8'h7f; }; //printable ASCII
        m1.write_mem (i, mbus.data_in, debug);
      end
    for (int i = 0; i<32; i++)
      begin
        m1.read_mem (i, rdata, debug);
        error_status = checkit (i, rdata, mbus.data_out);
      end
// SYSTEMVERILOG: void function
    printstatus(error_status);


    $display("Random Data Test with Constraints-2");
// SYSTEMVERILOG: enhanced for loop
    for (int i = 0; i< 32; i++)
      begin
        ok = randomize(mbus.data_in) with { (mbus.data_in >= 8'h41 && mbus.data_in <= 8'h5a) || (mbus.data_in >= 8'h61 && mbus.data_in <= 8'h7a); }; //A-Z a-z
        m1.write_mem (i, mbus.data_in, debug);
      end
    for (int i = 0; i<32; i++)
      begin
        m1.read_mem (i, rdata, debug);
        error_status = checkit (i, rdata, mbus.data_out);
      end
// SYSTEMVERILOG: void function
    printstatus(error_status);


    $display("Random Data Test with Constraints-3");
// SYSTEMVERILOG: enhanced for loop
    for (int i = 0; i< 32; i++)
      begin
        randcase
          80: ok = randomize(mbus.data_in) with { mbus.data_in >= 8'h41 && mbus.data_in <= 8'h5a; }; //A-Z
          20: ok = randomize(mbus.data_in) with { mbus.data_in >= 8'h61 && mbus.data_in <= 8'h7a; }; //a-z
        endcase
        m1.write_mem (i, mbus.data_in, debug);
      end
    for (int i = 0; i<32; i++)
      begin
        m1.read_mem (i, rdata, debug);
        error_status = checkit (i, rdata, mbus.data_out);
      end
// SYSTEMVERILOG: void function
    printstatus(error_status);

    fork

      begin: mbus   
        $display("Random Data Test with Class for mbus");
        // SYSTEMVERILOG: enhanced for loop
        for (int i = 0; i<32; i++)
          begin
            ok = m1.randomize(); //random data 8bits
            $display("Mode: %d", m1.mode);
            addr_store[i] = m1.addr;
            m1.write_mem (m1.addr, m1.data, debug);
          end
        for (int i = 0; i<32; i++)
          begin
            m1.read_mem (addr_store[i], rdata, debug);
            error_status = checkit (addr_store[i], rdata, mbus.data_out);
          end 
        // SYSTEMVERILOG: void function
        printstatus(error_status);
      end: mbus

      begin: m2bus
        $display("Random Data Test with Class for m2bus");
        // SYSTEMVERILOG: enhanced for loop
        for (int i = 0; i<32; i++)
          begin
            ok = m2.randomize(); //random data 8bits
            $display("Mode: %d", m2.mode);
            addr_store[i] = m2.addr;
            m2.write_mem (m2.addr, m2.data, debug);
          end
        for (int i = 0; i<32; i++)
          begin
            m2.read_mem (addr_store[i], rdata, debug);
            error_status = checkit (addr_store[i], rdata, m2bus.data_out);
          end 
        // SYSTEMVERILOG: void function
        printstatus(error_status);
      end: m2bus
    join 

    // QDA
    //Dynamic array scoreboard
    $display("Dynamic Array Test");
    dyn_arr = new[32];

    $display("dyn_arr size before processing: %d", dyn_arr.size());

    $display("Writing random data to memory");
    for (int i = 0; i < dyn_arr.size(); i++) begin
      ok = m1.randomize(); 
      dyn_arr[m1.addr] = m1.data;
      m1.write_mem(m1.addr, m1.data, debug);
    end

    $display("Reading random data from memory");
    for (int i = 0; i < dyn_arr.size(); i++) begin
      m1.read_mem(i, rdata, debug);
      if (dyn_arr[i] === 8'hxx)
        $display("Address %0d has not been written", i);
      else if (dyn_arr[i] != rdata) 
        $display("ERROR:  Address:%0d  Data:%h  Expected:%h", i, rdata, dyn_arr[i]);
    end

    dyn_arr.delete();
    $display("dyn_arr size after processing: %d", dyn_arr.size());

    //Associative array scoreboard
    $display("Associative Array Test");

    $display("Writing random data to memory");
    repeat(32) begin
      ok = m1.randomize();
      m1.write_mem(m1.addr, m1.data, debug);
      assoc_arr[m1.addr] = m1.data;
    end

    $display("Total addresses written: %d", assoc_arr.num());

    $display("Reading random data from memory");
    if (assoc_arr.first(assoc_idx)) begin
      do begin
        m1.read_mem(assoc_idx, rdata, debug);
        if (assoc_arr[assoc_idx] != rdata) 
          $display("ERROR:  Address:%0d  Data:%h  Expected:%h", assoc_idx, rdata, assoc_arr[assoc_idx]);
        assoc_arr.delete(assoc_idx);
      end while (assoc_arr.next(assoc_idx));
    end

    //Queue scoreboard
    $display("Queue Test");

    $display("Writing random data to memory");
    for (int i = 0; i < 32; i++) begin
      do begin
        ok = m1.randomize();
      end while (used_addr.exists(m1.addr));
      used_addr[m1.addr] = 1'b1;

      m1.write_mem(m1.addr, m1.data, debug);
      item.data = m1.data;
      item.addr = m1.addr;
      queue.push_back(item);
    end
    
    $display("Total addresses written: %d", queue.size());

    $display("Reading random data from memory");
    for (int i = 0; i < 32; i++) begin
      item = queue.pop_front();
      m1.read_mem(item.addr, rdata, debug);
      if (item.data != rdata)
        $display("ERROR:  Address:%0d  Data:%h  Expected:%h", item.addr, rdata, item.data);
    end

    $finish;
  end

function int checkit (input [4:0] address,
                      input [7:0] actual, expected);
  static int error_status;   // static variable
  if (actual !== expected) begin
    $display("ERROR:  Address:%0d  Data:%h  Expected:%h",
                address, actual, expected);
// SYSTEMVERILOG: post-increment
     error_status++;
   end
// SYSTEMVERILOG: function return
   return (error_status);
endfunction: checkit

// SYSTEMVERILOG: void function
function void printstatus(input int status);
if (status == 0)
   $display("Test Passed - No Errors!");
else
   $display("Test Failed with %d Errors", status);
endfunction

endmodule
