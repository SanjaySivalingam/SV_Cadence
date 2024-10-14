interface mem_ifa (input clk);
    logic read, write;
    logic [4:0] addr;
    logic [7:0] data_in;
    logic [7:0] data_out;


    // add read_mem and write_mem tasks
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
    endfunction : printstatus

    modport mem (input read, write, addr, data_in, output data_out);
    modport mem_test (input data_out, output read, write, addr, data_in, import read_mem, write_mem, printstatus);
    
endinterface
