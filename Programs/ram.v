module ram(
    input [3:0] address,
    input read_enable,
    output [7:0] data_out
);

reg [7:0] memory [0:15];

initial begin
  $readmemh("program.bin", memory);
end

assign data_out = read_enable ? memory[address] : 8'bz;

endmodule