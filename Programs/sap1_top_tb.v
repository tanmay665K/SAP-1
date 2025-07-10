`timescale 1ns/1ns
module sap1_top_tb;
    reg clk_in, rst;
    wire [7:0] display;
    
    sap1_top uut(.clk_in(clk_in), .rst(rst), .display(display));
    
    // Clock generation
    initial clk_in = 0;
    always #5 clk_in = ~clk_in;
    
    // Test sequence
    initial begin
        $dumpfile("sap1.vcd");
        $dumpvars(0, sap1_top_tb);  // Dump all signals
        
        // If you want to explicitly dump specific signals, use the correct names:
        $dumpvars(1, uut.pc_out);         // Program Counter
        $dumpvars(1, uut.ir_output);      // Instruction Register
        $dumpvars(1, uut.mar_out);        // Memory Address Register
        $dumpvars(1, uut.a_out);          // Register A
        $dumpvars(1, uut.b_out);          // Register B
        $dumpvars(1, uut.bus);            // Internal bus
        $dumpvars(1, uut.control_word);   // Control word
        $dumpvars(1, uut.control_unit.t_state); // T-state counter
        $dumpvars(1, uut.ram_data);       // RAM data
        $dumpvars(1, uut.opcode);         // Opcode
        $dumpvars(1, uut.pc_enable);      // PC Enable
        $dumpvars(1, uut.mar_load);       // MAR Load
        
        // You might also want to dump internal signals if they exist:
        // $dumpvars(1, uut.some_internal_module.internal_signal);
        
        rst = 1;
        #20 rst = 0;
     
        for(integer i = 0; i < 100; i++) begin
            @(posedge clk_in);
            #1;
            $display("Time = %t, PC = %d, IR = %d, MAR = %d, CW = %h, Bus = %h, T_State = %d, MAR Enable = %d, RAM Data = %d, Opcode = %b, PC Enable = %d. Reg. A = %d, Reg. B = %d,  Output = %d",
                     $time, uut.pc_out, uut.ir_output, uut.mar_out,
                     uut.control_word, uut.bus, uut.control_unit.t_state, uut.mar_load, uut.ram_data, uut.opcode, uut.pc_enable, uut.a_out, uut.b_out, display);
            $display("Debug: IR = %h, Upper4 = %b, Lower4 = %b, Opcode = %b, Cycle = %d", uut.ir_output, uut.ir_output[7:4], uut.ir_output[3:0], uut.opcode, i);
            if(uut.control_word[11]) begin
                $display("System Halted.");
                $finish;
            end
        end
        $finish;
    end
endmodule