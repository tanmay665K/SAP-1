`timescale 1ns/1ns
module regb_tb;
    reg clk, rst, load;
    reg [7:0] bus;
    wire [7:0] out;
    
    regb uut(.clk(clk), .rst(rst), .load(load), .bus(bus), .out(out));
    
    // Clock generation
    always #5 clk = ~clk;
    
    initial begin
         $dumpfile("regb_tb.vcd");    
        $dumpvars(0, regb_tb);
        // Initialize
        clk = 0;
        rst = 1;
        load = 0;
        bus = 0;
        
        // Apply reset
        #10 rst = 0;  // Release reset after 10ns
        
        // Test case 1: Load 64
        #10 load = 1; bus = 64;
        #10 $display("Register B - Bus data = %d, Output = %d, Time = %t", bus, out, $time);
        
        // Test case 2: Load 56
        #10 bus = 56;
        #10 $display("Register B - Bus data = %d, Output = %d, Time = %t", bus, out, $time);
        
        // Test case 3: Load 94
        #10 bus = 94;
        #10 $display("Register B - Bus data = %d, Output = %d, Time = %t", bus, out, $time);
        
        // Test case 4: Load 255
        #10 bus = 255;
        #10 $display("Register B - Bus data = %d, Output = %d, Time = %t", bus, out, $time);
        
        // Test load disable
        #10 load = 0; bus = 100;
        #10 $display("Load disabled - Bus data = %d, Output = %d, Time = %t", bus, out, $time);
        
        // Test reset
        #10 rst = 1;
        #10 $display("After reset - Output = %d, Time = %t", out, $time);
        
        #10 $finish;
    end
    
endmodule