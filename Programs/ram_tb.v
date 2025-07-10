`timescale 1ns/1ns

module ram_tb;
    reg [3:0] address;
    reg read_enable;           // Changed from ram_enable
    wire [7:0] data_out;
    
    // Make sure port names match your RAM module
    ram uut(.address(address), .read_enable(read_enable), .data_out(data_out));
    
    integer i;  // Declare integer properly
    
    initial begin
        $dumpfile("ram_tb.vcd");
        $dumpvars(0, ram_tb);
        
        // Initialize
        address = 4'h0;
        read_enable = 0;
        
        $display("=== RAM Test ===");
        
        // Test with read_enable = 0 first
        #10 $display("Read disabled: Address = %d, Data = %h (should be z)", address, data_out);
        
        // Enable reading and test all addresses
        read_enable = 1;
        
        for (i = 0; i < 16; i = i + 1) begin
            address = i;           // Connect loop variable to address
            #5;                    // Wait for signals to settle
            $display("Address = %d, Data = %h, Time = %t", address, data_out, $time);
        end
        
        // Test read disable again
        #10 read_enable = 0;
        #5 $display("Read disabled again: Address = %d, Data = %h (should be z)", address, data_out);
        
        $display("RAM test complete");
        $finish;
    end
    
endmodule