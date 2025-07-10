`timescale 1ns/1ns

module pc_tb;
    reg clk, inc, rst;
    wire [3:0] out;
    
    pc uut(.clk(clk), .inc(inc), .rst(rst), .out(out));
    
    // Clock generation - this is crucial!
    always #5 clk = ~clk;
    
    initial begin  
        $dumpfile("pc_tb.vcd");
        $dumpvars(0, pc_tb);
        
        // Initialize
        clk = 0;
        rst = 1;
        inc = 0;
        
        // Apply reset
        #10 rst = 0;
        $display("After reset: PC = %d, Time = %t", out, $time);
        
        // Test increment
        #10 inc = 1;
        $display("Increment enabled: PC = %d, Time = %t", out, $time);
        
        // Let it increment several times
        #50 $display("After increments: PC = %d, Time = %t", out, $time);
        
        // Test reset during operation
        #10 rst = 1;
        #10 $display("Reset applied: PC = %d, Time = %t", out, $time);
        
        // Release reset
        #10 rst = 0;
        $display("Reset released: PC = %d, Time = %t", out, $time);
        
        // Test increment disable
        #20 inc = 0;
        $display("Increment disabled: PC = %d, Time = %t", out, $time);
        
        // Wait to verify PC holds value
        #30 $display("PC should hold value: PC = %d, Time = %t", out, $time);
        
        // Test wrap-around (increment to 15 and beyond)
        inc = 1;
        #160 $display("Near wrap-around: PC = %d, Time = %t", out, $time);
        
        #20 $finish;
    end
endmodule