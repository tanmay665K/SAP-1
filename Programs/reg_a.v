/*Implementation of accumalator register (A) in SAP-1. Primary register where all operations (+, -) will take place.*/

module reg_a(
    input clk, rst, load,
    input [7:0] bus,
    output [7:0] out
);

reg [7:0] reg_a;

initial begin
  reg_a = 0;
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
        reg_a <= 0;
    end
    else if(load) begin
        reg_a <= bus;
    end
end

assign out = reg_a;

endmodule