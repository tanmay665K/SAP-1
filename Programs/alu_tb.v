`timescale 1ns/1ns

module alu_tb;
    reg sub;
    reg [7:0] a, b;
    wire [7:0] out;
    
    // Connect sub signal to ALU!
    alu uut(.sub(sub), .a(a), .b(b), .out(out));
    
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
        
        // Initialize
        sub = 0; a = 0; b = 0;
        #1; // Let signals settle
        $display("Initial: A=%d, B=%d, Sub=%d, Result=%d", a, b, sub, out);
        
        // Test 1: Addition
        #10 sub = 0; a = 45; b = 10;
        #1; // Settlement time
        $display("Add: A=%d, B=%d, Sub=%d, Result=%d (Expected: 55)", a, b, sub, out);
        
        // Test 2: Addition
        #10 sub = 0; a = 32; b = 12;
        #1;
        $display("Add: A=%d, B=%d, Sub=%d, Result=%d (Expected: 44)", a, b, sub, out);
        
        // Test 3: Subtraction
        #10 sub = 1; a = 31; b = 11;
        #1;
        $display("Sub: A=%d, B=%d, Sub=%d, Result=%d (Expected: 20)", a, b, sub, out);
        
        // Test 4: Addition
        #10 sub = 0; a = 12; b = 10;
        #1;
        $display("Add: A=%d, B=%d, Sub=%d, Result=%d (Expected: 22)", a, b, sub, out);
        
        // Test 5: Subtraction
        #10 sub = 1; a = 50; b = 30;
        #1;
        $display("Sub: A=%d, B=%d, Sub=%d, Result=%d (Expected: 20)", a, b, sub, out);
        
        // Test 6: Edge case - subtract larger from smaller
        #10 sub = 1; a = 10; b = 20;
        #1;
        $display("Sub: A=%d, B=%d, Sub=%d, Result=%d (Expected: 246 due to underflow)", a, b, sub, out);
        
        $display("ALU Test Complete");
        $finish;
    end
    
endmodule