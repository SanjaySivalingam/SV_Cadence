module counter(input wire [4:0] data, 
               input wire load, input wire enable, input wire clk, input wire rst_, 
               output logic [4:0] count);
    timeunit 1ns;
    timeprecision 100ps;
    
    always_ff @(posedge clk or negedge rst_) begin
        if (!rst_) begin
            count <= 5'b0;
        end
        else if(load) begin
            count <= data;
        end
        else if(enable) begin
            count <= count + 1'b1;
        end
        else begin
            count <= count;
        end
    end

endmodule
