module reg_out(
    input clk,
    input rst,
    input load,
    input [7:0] bus,
    output [7:0] out
);

reg [7:0] output_reg;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        output_reg <= 8'b0;
    end else if (load) begin
        output_reg <= bus;
    end
end

assign out = output_reg;

endmodule