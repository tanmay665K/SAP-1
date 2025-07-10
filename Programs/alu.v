module alu(
    input sub,
    input [7:0] a, b,
    output [7:0] out
);

reg[7:0] res;

initial begin   
    res = 0;
end

always @ (*) begin  
    if(sub) begin   
        res = a - b;
    end
else begin
        res = a + b;
end

end

assign out = res;
endmodule