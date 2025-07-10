`timescale 1ns/1ns

module controller_tb;

// Inputs
reg clk;
reg rst;
reg [3:0] opcode;

// Outputs
wire [11:0] cw;
wire halt;

// Instantiate the controller
controller uut (
    .clk(clk),
    .rst(rst),
    .opcode(opcode),
    .cw(cw),
    .halt(halt)
);

// Clock generation
always #5 clk = ~clk;

// Test sequence
initial begin
    // VCD dump for waveform viewing
    $dumpfile("controller_tb.vcd");
    $dumpvars(0, controller_tb);
    
    // Initialize inputs
    clk = 0;
    rst = 1;
    opcode = 4'b0000;
    
    // Display header
    $display("Time\tT-State\tOpcode\tControl Word\tHalt");
    $display("----\t-------\t------\t------------\t----");
    
    // Apply reset
    #10 rst = 0;
    $display("%4d\tReset Released", $time);
    
    // Test LDA instruction
    $display("\n=== Testing LDA Instruction ===");
    opcode = 4'b0000; // LDA
    
    // Monitor T-states for one complete LDA instruction
    repeat(6) begin
        @(posedge clk);
        #1; // Small delay for signals to settle
        $display("%4d\tT%1d\t%4b\t%12b\t%1b", 
                 $time, get_t_state(), opcode, cw, halt);
    end
    
    // Test ADD instruction
    $display("\n=== Testing ADD Instruction ===");
    opcode = 4'b0001; // ADD
    
    repeat(6) begin
        @(posedge clk);
        #1;
        $display("%4d\tT%1d\t%4b\t%12b\t%1b", 
                 $time, get_t_state(), opcode, cw, halt);
    end
    
    // Test SUB instruction
    $display("\n=== Testing SUB Instruction ===");
    opcode = 4'b0010; // SUB
    
    repeat(6) begin
        @(posedge clk);
        #1;
        $display("%4d\tT%1d\t%4b\t%12b\t%1b", 
                 $time, get_t_state(), opcode, cw, halt);
    end
    
    // Test OUT instruction
    $display("\n=== Testing OUT Instruction ===");
    opcode = 4'b1110; // OUT
    
    repeat(6) begin
        @(posedge clk);
        #1;
        $display("%4d\tT%1d\t%4b\t%12b\t%1b", 
                 $time, get_t_state(), opcode, cw, halt);
    end
    
    // Test HLT instruction
    $display("\n=== Testing HLT Instruction ===");
    opcode = 4'b1111; // HLT
    
    repeat(10) begin // Try more cycles to see if it stays halted
        @(posedge clk);
        #1;
        $display("%4d\tT%1d\t%4b\t%12b\t%1b", 
                 $time, get_t_state(), opcode, cw, halt);
        if (halt) begin
            $display("     \tSystem Halted - Ring Counter Stopped");
            break;
        end
    end
    
    // Test reset during halt
    $display("\n=== Testing Reset During Halt ===");
    #20 rst = 1;
    #10 rst = 0;
    opcode = 4'b0000; // LDA again
    
    repeat(3) begin
        @(posedge clk);
        #1;
        $display("%4d\tT%1d\t%4b\t%12b\t%1b", 
                 $time, get_t_state(), opcode, cw, halt);
    end
    
    // Test specific control word values
    $display("\n=== Control Word Verification ===");
    test_control_words();
    
    $display("\n=== Test Complete ===");
    $finish;
end

// Function to decode T-state for display
function [2:0] get_t_state;
    begin
        get_t_state = uut.t_state;
    end
endfunction

// Task to verify specific control word values
task test_control_words;
    begin
        $display("Verifying expected control word values...");
        
        // Reset and check T1
        rst = 1; #10; rst = 0;
        opcode = 4'b0000; // LDA
        @(posedge clk); #1;
        
        if (cw === 12'h090)
            $display("✓ T1 control word correct: %h", cw);
        else
            $display("✗ T1 control word incorrect: %h (expected 090)", cw);
            
        // Check T2
        @(posedge clk); #1;
        if (cw === 12'h1A0)
            $display("✓ T2 control word correct: %h", cw);
        else
            $display("✗ T2 control word incorrect: %h (expected 1A0)", cw);
            
        // Check T3
        @(posedge clk); #1;
        if (cw === 12'h000)
            $display("✓ T3 control word correct: %h", cw);
        else
            $display("✗ T3 control word incorrect: %h (expected 000)", cw);
            
        // Check T4 for LDA
        @(posedge clk); #1;
        if (cw === 12'h090)
            $display("✓ T4 LDA control word correct: %h", cw);
        else
            $display("✗ T4 LDA control word incorrect: %h (expected 090)", cw);
            
        // Check T5 for LDA
        @(posedge clk); #1;
        if (cw === 12'h120)
            $display("✓ T5 LDA control word correct: %h", cw);
        else
            $display("✗ T5 LDA control word incorrect: %h (expected 120)", cw);
    end
endtask

// Monitor for debugging
initial begin
    $monitor("Time=%4d, T-State=%1d, Opcode=%4b, CW=%12b, Halt=%1b", 
             $time, get_t_state(), opcode, cw, halt);
end

endmodule