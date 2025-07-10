`timescale 1ns/1ns

module mar_tb;
    reg clk, rst, load;
    reg [7:0] bus;
    wire [3:0] address;
    
    // Fixed port connections
    mar uut(.clk(clk), .rst(rst), .load(load), .bus(bus), .address(address));
    
    always #5 clk = ~clk;
    
    initial begin
        $dumpfile("mar_tb.vcd");
        $dumpvars(0, mar_tb);
        
        // Initialize
        clk = 0; rst = 1; load = 0; bus = 0;
        
        // Release reset
        #10 rst = 0; 
        $display("Reset released, MAR = %d", address);
        
        // Test 1: Load 0x06 (expect address = 6)
        #10 load = 1; bus = 8'h06;
        @(posedge clk); // Wait for clock edge
        #1; // Small delay for signal to settle
        $display("Bus = %h (%d), Address = %d, Time = %t", bus, bus, address, $time);
        
        // Test 2: Load 0x1C (expect address = 12)
        #10 bus = 8'h1C;
        @(posedge clk);
        #1;
        $display("Bus = %h (%d), Address = %d, Time = %t", bus, bus, address, $time);
        
        // Test 3: Load 0x0A (expect address = 10)
        #10 bus = 8'h0A;
        @(posedge clk);
        #1;
        $display("Bus = %h (%d), Address = %d, Time = %t", bus, bus, address, $time);
        
        // Test 4: Load 0x4B (expect address = 11)
        #10 bus = 8'h4B;
        @(posedge clk);
        #1;
        $display("Bus = %h (%d), Address = %d, Time = %t", bus, bus, address, $time);
        
        // Test 5: Disable load (should hold value)
        #10 load = 0; bus = 8'hFF;
        @(posedge clk);
        #1;
        $display("Load disabled, Bus = %h, Address = %d (should stay 11)", bus, address);
        
        // Test 6: Reset
        #10 rst = 1;
        #1;
        $display("Reset enabled, Address = %d (should be 0)", address);
        
        $display("MAR test complete");
        $finish;
    end
    
endmodule
