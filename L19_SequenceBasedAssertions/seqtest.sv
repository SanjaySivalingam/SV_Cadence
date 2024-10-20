///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : seq_test.sv
// Title       : sequence test
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Defines the initial sequence test with no assertions
// Notes       :
//
///////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ns

module assr_test ;

  parameter PERIOD  = 10; // clock period
  parameter CLENGTH = 30; // command length (maximum)
  integer   breakpoint;

  reg CLK, A, B, C, J, K, X ;

  task do_test;
      input [CLENGTH*8:1] seq;
      reg [7:0] c;
      integer i;
    begin
      @(posedge CLK);
      for (i=1;i<=CLENGTH;i=i+1)
        begin
          c = seq[CLENGTH*8:CLENGTH*8-7];
          seq = seq << 8;
          case (c)
            "A" : A <= 1;
            "B" : B <= 1;
            "C" : C <= 1;
            "J" : J <= 1;
            "K" : K <= 1;
            "X" : X <= 1;
            ";" : begin
                    @(posedge CLK);
                    A<=0; B<=0; C<=0; J<=0; K<=0; X<=0;
                  end
          endcase
        end
      @(posedge CLK);
      A<=0; B<=0; C<=0; J<=0; K<=0; X<=0;
      @(posedge CLK);
      breakpoint=breakpoint+1;
    end
  endtask

  always
    begin
      CLK <= 0 ;
      #(PERIOD/2) ;
      CLK <= 1 ;
      #(PERIOD/2) ;
    end

  initial
    begin : TEST
      $timeformat(-9,0,"ns:",6);
      breakpoint=0;
      @(posedge CLK);
      A<=0; B<=0; C<=0; J<=0; K<=0; X<=0;

      // $display("TESTING SIMPLE SEQUENCE");
      // $display("%t Testing incomplete enabling condition",$time);
      // do_test("A;B;J;K");
      // $display("%t Testing normal passing condition",$time);
      // do_test("A;B;C;J;K");
      // $display("%t Testing failing fulfilling condition",$time);
      // do_test("A;B;C;J");
      // $display("%t Testing overlapping passing conditions",$time);
      // do_test("A;B;CA;JB;KC;J;K");
      // $display("%t Testing two simultaneous failing fulfilling conditions",$time);
      // do_test("A;BA;CB;JC;J");
      // $display("%t Testing aborted fulfilling condition",$time);
      // do_test("A;B;C;J;X");

     $display("TESTING COMPLEX SEQUENCE");
     $display("%t Testing incomplete enabling sequence",$time);
     do_test("C;B;B;B");
     $display("%t Testing passing fulfilling sequence",$time);
     do_test("C;B;A;J;J;J;J;K");
     $display("%t Testing passing fulfilling sequence",$time);
     do_test("C;B;B;B;A;J;J;J;J;K");
     $display("%t Testing disabled enabling sequence",$time);
     do_test("C;B;B;B;X;J;J;J;J;;K");
     $display("%t Testing disabled fulfilling sequence",$time);
     do_test("C;B;B;A;J;J;J;J;X");
     $display("%t Testing failing fulfilling sequence",$time);
     do_test("C;B;A;J;J;J;J;;K");
     $display("%t Testing failing overalapping K with last J",$time);
     do_test("C;B;B;A;J;J;J;JK");
     $display("%t Testing failing overlapping A with Bs", $time);
     do_test("C;B;BA;BA;A;J;J;J;J;K");
     $display("%t Testing passing overlapping A with Bs", $time);
     do_test("C;B;BA;BAJ;AJ;J;J;JK;JK;K");
      $display("TESTING IS COMPLETE");
      
    $finish;
    end

// define assertions here
//#### EDIT ###

/* property SIMPLE_SEQ;
  @(negedge CLK) disable iff (X)
  A ##1 B ##1 C |=> J ##1 K;
endproperty

A1: assert property (SIMPLE_SEQ)
  else $error("SIMPLE_SEQ failed"); */

property COMPLEX_SEQ;
  @(negedge CLK) disable iff (X)
  C ##[1:3] B ##1 A |=> J[*4] ##1 K;
endproperty

A2: assert property (COMPLEX_SEQ)
  else $error("COMPLEX_SEQ failed");


//#### END OF EDIT ###

endmodule
