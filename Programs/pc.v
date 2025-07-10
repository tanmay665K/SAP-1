module pc(
    input clk, inc, rst,
    output [3:0] out
);
reg [3:0] pc;

initial begin  
    pc = 0;
end

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        pc <= 4'b0;
    end
    else if (inc) begin
        pc <= pc + 1;  // Automatically wraps from 15 to 0
    end
end

assign out = pc;
endmodule