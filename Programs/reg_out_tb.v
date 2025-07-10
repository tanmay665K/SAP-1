`timescale 1ns/1ns

module reg_out_tb;
    reg clk;
    reg rst;
    reg load;
    reg [7:0] bus;
    wire [7:0] out;
    
    // Instantiate the output register
    reg_out uut(
        .clk(clk),
        .rst(rst),
        .load(load),
        .bus(bus),
        .out(out)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    initial begin
        $dumpfile("reg_out_tb.vcd");
        $dumpvars(0, reg_out_tb);
        
        // Initialize
        clk = 0;
        rst = 1;
        load = 0;
        bus = 8'h00;
        
        $display("=== Output Register Test ===");
        
        // Test reset
        #10 rst = 0;
        #1;
        $display("After reset: Out = %h (expected 00)", out);
        
        // Test 1: Load value 0x2A
        #10 load = 1; bus = 8'h2A;
        @(posedge clk);
        #1;
        $display("Load 2A: Bus = %h, Out = %h (expected 2A)", bus, out);
        
        // Test 2: Load value 0xFF
        #10 bus = 8'hFF;
        @(posedge clk);
        #1;
        $display("Load FF: Bus = %h, Out = %h (expected FF)", bus, out);
        
        // Test 3: Load disable (should hold previous value)
        #10 load = 0; bus = 8'h55;
        @(posedge clk);
        #1;
        $display("Load disabled: Bus = %h, Out = %h (should stay FF)", bus, out);
        
        // Test 4: Change bus again with load disabled
        #10 bus = 8'h99;
        @(posedge clk);
        #1;
        $display("Load still disabled: Bus = %h, Out = %h (should stay FF)", bus, out);
        
        // Test 5: Enable load again
        #10 load = 1; bus = 8'h3C;
        @(posedge clk);
        #1;
        $display("Load enabled: Bus = %h, Out = %h (expected 3C)", bus, out);
        
        // Test 6: Reset during operation
        #10 rst = 1;
        #1;
        $display("Reset applied: Out = %h (expected 00)", out);
        
        // Test 7: Recovery after reset
        #10 rst = 0; load = 1; bus = 8'h77;
        @(posedge clk);
        #1;
        $display("After reset recovery: Bus = %h, Out = %h (expected 77)", bus, out);
        
        // Test 8: SAP-1 typical values (simulate OUT instruction)
        $display("\n=== SAP-1 OUT Instruction Simulation ===");
        
        rst = 1; #5; rst = 0;  // Quick reset
        
        // Simulate accumulator value 15 (decimal)
        #10 load = 1; bus = 8'h0F;
        @(posedge clk);
        #1;
        $display("OUT instruction: Accumulator = %d, Display = %d", bus, out);
        
        // Simulate accumulator value 42 (decimal)
        #10 bus = 8'h2A;
        @(posedge clk);
        #1;
        $display("OUT instruction: Accumulator = %d, Display = %d", bus, out);
        
        // Simulate accumulator value 255 (decimal)
        #10 bus = 8'hFF;
        @(posedge clk);
        #1;
        $display("OUT instruction: Accumulator = %d, Display = %d", bus, out);
        
        $display("\n=== Test Complete ===");
        $finish;
    end
    
    // Monitor for continuous observation
    initial begin
        $monitor("Time = %0d, rst = %b, load = %b, bus = %h, out = %h", 
                 $time, rst, load, bus, out);
    end
    
endmodule