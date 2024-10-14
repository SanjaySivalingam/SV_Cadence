import typedefs::*;

module alu (input wire [7:0] accum, data, input logic [2:0] opcode, input wire clk, output logic [7:0] out, output logic zero);
    
    timeunit 1ns;
    timeprecision 100ps;

    always_comb begin
        zero = (accum == 8'b0)? 1'b1 : 1'b0;
    end

    always_ff @(negedge clk) begin
        unique case(opcode)
            HLT: out <= accum;
            SKZ: out <= accum;
            ADD: out <= accum + data;
            AND: out <= accum & data;
            XOR: out <= accum ^ data;
            LDA: out <= data;
            STO: out <= accum;
            JMP: out <= accum;
            default: out <= accum;
        endcase
    end

endmodule
