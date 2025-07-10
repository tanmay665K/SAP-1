module mar(
    input clk, rst, load,
    input [7:0] bus,
    output [3:0] address
);

reg [3:0] addr;

always @ (posedge clk or posedge rst) begin
  if (rst) begin
    addr <= 4'b0000;
end
else if (load) begin
    addr <= bus[3:0];
end
end

assign address = addr;

endmodule