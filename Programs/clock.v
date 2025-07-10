module clock(
    input clk_in, hlt,
    output reg clk_out
);

always @ (*) begin
if (hlt) begin
    assign clk_out = 1'b0;
end
else begin  
   assign clk_out = clk_in;
end
end

endmodule