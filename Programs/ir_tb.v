module ir_tb;
reg clk, rst, load;
reg [7:0] bus;
wire [7:0] instruction;

ir uut(.clk(clk), .rst(rst), .load(load), .bus(bus), .instruction(instruction));

initial begin
    $dumpfile("ir_tb.vcd");
    $dumpvars(0, ir_tb);
    clk = 0; rst = 0; load = 0;
    #10 clk = 1; load = 1; bus = 64;
    @(posedge clk)
       #1 $display("Bus = %d, IR = %d, Time = %t (Expected = 64)", bus, instruction, $time);
    #15 bus = 78;
    @(posedge clk)
       #1 $display("Bus = %d, IR = %d, Time = %t (Expected = 78)", bus, instruction, $time);
   #15 bus = 82;
    @(posedge clk)
      #1  $display("Bus = %d, IR = %d, Time = %t (Expected = 82)", bus, instruction, $time);
    #10 load = 0; bus = 100;
    @(posedge clk)
   #1 $display("Load disabled, Bus = %d, Instruction = %d, Time = %t (Expected = 82)", bus, instruction, $time );
    #50 rst = 1;
    @(posedge clk)
   #1 $display("Reset enabled.");
end
always #5 clk = ~clk;

endmodule