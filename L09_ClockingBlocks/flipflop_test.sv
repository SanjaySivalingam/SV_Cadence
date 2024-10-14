///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : flipflop_test.sv
// Title       : Flipflop Testbench Module
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Defines the Flipflop testbench module
// Notes       :
// 
///////////////////////////////////////////////////////////////////////////

module testflop ();
timeunit 1ns;
timeprecision 100ps;

logic reset;
logic [7:0] qin,qout,dreg;

// ---- clock generator code begin------
`define PERIOD 10
logic clk = 1'b1;

always
    #(`PERIOD/2)clk = ~clk;

// ---- clock generator code end------


flipflop DUV(.*);

default clocking rc @ (posedge clk);
    default input #1step output #4ns;
    input qout;
    output qin, reset;
endclocking

initial begin
    @(rc);
    rc.reset <= 1'b1;
    ##3 rc.reset <= 1'b0;

    for (int i = 0; i < 8; i++) begin
        @(rc);
        rc.qin <= i;
        dreg <= rc.qout; //to check rc.qout value
        $display("qin=%d, qout=%d, dreg=%d", i, rc.qout, dreg);
    end
    
    end
endmodule
