module ir(
    input clk, rst, load,
    input [7:0] bus,
    output [7:0] instruction
);

reg [7:0] ir_reg;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        ir_reg <= 8'b0;
    end else if (load) begin
        ir_reg <= bus;
    end
end

assign instruction = ir_reg;

endmodule