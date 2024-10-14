
module register(input wire enable, 
                input wire clk, 
                output logic [7:0] out, 
                input wire [7:0] data, 
                input wire rst_);
timeunit 1ns;
timeprecision 100ps;

always_ff @(posedge clk or negedge rst_) begin
    if (!rst_) begin
        out <= 8'b0;
    end
    else begin 
        if (enable) begin
            out <= data;
        end 
        else begin
            out <= out;
        end
    end
end
endmodule
