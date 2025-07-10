
module regb(
    input clk, rst, load,
    input [7:0] bus,
    output [7:0] out
);

reg [7:0] regb;

initial begin
  regb = 0;
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
        regb <= 0;
    end
    else if(load) begin
        regb <= bus;
    end
end

assign out = regb;

endmodule