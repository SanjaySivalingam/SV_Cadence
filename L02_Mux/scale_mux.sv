module scale_mux #(parameter WIDTH = 1) 
                  (input wire [WIDTH-1:0] in_a, 
                   input wire [WIDTH-1:0] in_b, 
                   input wire sel_a, 
                   output logic [WIDTH-1:0] out);
    
    timeunit        1ns ;
    timeprecision 100ps ;

    always_comb begin
        unique case (sel_a)
            1'b1: out = in_a;
            1'b0: out = in_b;
            default: out = {WIDTH{1'bx}};
        endcase 
    end

endmodule
