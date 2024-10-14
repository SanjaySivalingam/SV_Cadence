////////////////////////////////////////////////////////////////////////
// (c) Copyright 2007 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : mailbox_if.sv
// Title       : Mailbox Transaction Interface
// Project     : SystemVerilog Verify Training
// Created     : 2013-4-8
// Description : Demonstrates the use of a mailbox to synchronize
//               between producers and consumers of transactions.
// Notes       : This unit is a "wrapper" around a mailbox. It declares
//               and constructs the mailbox and provides mailbox-like
//               methods that users can call in lieu of the mailbox.
//               When IUS supports hierarchical references to mailboxes
//               we will simply instantiate a mailbox at the top level.
//
///////////////////////////////////////////////////////////////////////

interface mailbox_if ;

  timeunit       1ns;
  timeprecision 10ps;

  import ex_trans_pkg::*;

  mailbox mbox = new();

  function int num() ;
    return mbox.num();
  endfunction : num

  /////////////////////////////////////////////////////////////////////////////
  // This is the users "blocking put" interface to the mailbox. We need to   //
  // pass the base transaction class handle by reference as passing by value //
  // copies only the base parts. Having a reference argument means we must   //
  // make the task automatic, and as the task consumes time and is used by   //
  // multiple callers, we need to make it automatic anyway. This task takes  //
  // the incoming transaction, determines what kind it is, dynamically casts //
  // it to its particular kind, and puts it in the mailbox.                  //
  /////////////////////////////////////////////////////////////////////////////
  task automatic put(ref my_tr_base_c my_tr_base) ;
    my_tr_config_c my_tr_config ;
    my_tr_synch_c  my_tr_synch  ;
    my_tr_comms_c  my_tr_comms  ;
    if ( my_tr_base.get_type() == "my_tr_config_c" )
      begin // post the configuration transaction
        if ( $cast(my_tr_config, my_tr_base) == 0 )
          begin $display("Cannot cast trans class"); $finish(0); end
        mbox.put(my_tr_config)
      end
    else if ( my_tr_base.get_type() == "my_tr_synch_c" )
      begin // post the synchronization transaction
        if ( $cast(my_tr_synch, my_tr_base) == 0 )
          begin $display("Cannot cast trans class"); $finish(0); end
        mbox.put(my_tr_synch)
      end
    else if ( my_tr_base.get_type() == "my_tr_comms_c" )
      begin // post the communications transaction
        if ( $cast(my_tr_comms, my_tr_base) == 0 )
          begin $display("Cannot cast trans class"); $finish(0); end
        mbox.put(my_tr_comms)
      end
  endtask : put

  /////////////////////////////////////////////////////////////////////////////
  // This is the users "non-blocking put" interface to the mailbox.          //
  // It is much like the blocking put but of course does not block           //
  // and returns the status.                                                 //
  /////////////////////////////////////////////////////////////////////////////
  function automatic int try_put(ref my_tr_base_c my_tr_base) ;
    my_tr_config_c my_tr_config ;
    my_tr_synch_c  my_tr_synch  ;
    my_tr_comms_c  my_tr_comms  ;
    if ( my_tr_base.get_type() == "my_tr_config_c" )
      begin // post the configuration transaction
        if ( $cast(my_tr_config, my_tr_base) == 0 )
          begin $display("Cannot cast trans class"); $finish(0); end
        if (mbox.try_put(my_tr_config)) $display("Successful config put");
      end
    else if ( my_tr_base.get_type() == "my_tr_synch_c" )
      begin // post the synchronization transaction
        if ( $cast(my_tr_synch, my_tr_base) == 0 )
          begin $display("Cannot cast trans class"); $finish(0); end
        if (mbox.try_put(my_tr_synch)) $display("Successful synch put");
      end
    else if ( my_tr_base.get_type() == "my_tr_comms_c" )
      begin // post the communications transaction
        if ( $cast(my_tr_comms, my_tr_base) == 0 )
          begin $display("Cannot cast trans class"); $finish(0); end
        if (mbox.try_put(my_tr_comms)) $display("Successful comms put");
      end
  endfunction : try_put

  task automatic get(ref my_tr_base_c my_tr_base) ;
    mbox.get(my_tr_base);
  endtask : get

  function automatic int try_get(ref my_tr_base_c my_tr_base) ;
    if(mbox.try_get(my_tr_base)) $display("Successful get");
  endfunction : try_get

  task automatic peek(ref my_tr_base_c my_tr_base) ;
    mbox.peek(my_tr_base);
  endtask : peek

  function automatic int try_peek(ref my_tr_base_c my_tr_base) ;
    if(mbox.try_peek(my_tr_base)) $display("Successful peek");
  endfunction : try_peek

  modport put_port (import num, put, try_put);
  modport get_port (import num, get, try_get, peek, try_peek);

endinterface : mailbox_if
