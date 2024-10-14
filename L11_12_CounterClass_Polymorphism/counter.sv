///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : counter.sv
// Title       : Simple class
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Simple counter class
// Notes       :
// 
///////////////////////////////////////////////////////////////////////////

module counterclass;

// add counter class here
virtual class counter;
    protected int count, max, min;

    function new(input int count = 0, input int max, input int min);
        this.count = count;
        this.max = max;
        this.min = min;
        $display("Initializing count = %d, max = %d, min = %d", count, max, min);
        check_limit(max, min);
        check_set(count);
    endfunction

    function void load(input int count);
        this.count = count;
        check_set(count);
    endfunction

    function int getcount();
        $display("count = %d", count);
        return this.count;
    endfunction

    function int check_limit(input int a, b);
        if (a > b) begin
            max = a;
            min = b;
            $display("Check limit: max = %d, min = %d", max, min);
        end
        else begin
            max = b;
            min = a;
            $display("Check limit: max = %d, min = %d", max, min);
        end
    endfunction

    function int check_set(input int set);
        if (set > max || set < min) begin
            $display("Error: set value is out of range, reset count to min");
            count = min;
        end
        else begin
            count = set;
        end
    endfunction

    virtual function void next();
        $display("You are in counter class");
    endfunction

endclass

class upcounter extends counter;
    bit carry;
    static int num;

    function new(input int count, input int max, input int min);
        super.new(count, max, min);
        carry = 1'b0;
        num++;
        $display("upcounter object %d created", num);
    endfunction

    virtual function void next();
        if (count < max) begin
            count = count + 1;
            carry = 1'b0;
        end
        else begin
            $display("Error: count is out of range, reset to min and set carry");
            count = min;
            carry = 1'b1;
        end
    endfunction

    static function int getnum();
        return num;
    endfunction
endclass

class downcounter extends counter;
    bit borrow;
    static int num;

    function new(input int count, input int max, input int min);
        super.new(count, max, min);
        borrow = 1'b0;
        num++;
        $display("downcounter object %d created", num);
    endfunction 

    virtual function void next();
        if (count > min) begin
            count = count - 1;
            borrow = 1'b0;
        end
        else begin   
            $display("Error: count is out of range, reset to max and set borrow");
            count = max;
            borrow = 1'b1;
        end
    endfunction 

    static function int getnum();
        return num;
    endfunction
endclass

class timer;
    local upcounter hours, minutes, seconds;

    function new(input int h, m, s);
        hours = new(h, 23, 0);
        minutes = new(m, 59, 0);
        seconds = new(s, 59, 0);
    endfunction

    function void load(input int h, m, s);
        hours.load(h);
        minutes.load(m);
        seconds.load(s);
    endfunction

    function void showval();
        $display("%d:%d:%d", hours.getcount(), minutes.getcount(), seconds.getcount());
    endfunction

    virtual function void next();
        seconds.next();
        if (seconds.carry) begin
            minutes.next();
            if (minutes.carry) begin
                hours.next();
                if (hours.carry) begin
                    $display("Timer expired");
                end
            end
        end
    endfunction
endclass

//For L11
/* counter mycounter = new(0, 5, 0);
upcounter myupcounter = new(1, 5, 0);
downcounter mydowncounter = new(4, 5, 0);
timer mytimer = new(23, 59, 55);

initial begin
    repeat(5) begin
        myupcounter.next();
    end
    mydowncounter = new(4, 5, 0); //can't use mydowncounter.getcount() here because object is still pointing to null
    repeat(5) begin
        mydowncounter.next();
    end
    mytimer.showval();
    repeat(5) begin
        mytimer.next();
        mytimer.showval();
    end
end */

//For L12
counter c1;
upcounter uc = new(1, 5, 0);
upcounter uc1 = new(2, 5, 0);

initial begin
    c1 = uc;
    $cast(uc1, c1);
    repeat(5) begin
        c1.next();
        c1.getcount();
    end
end

endmodule
