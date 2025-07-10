module controller(
    input clk,
    input rst,
    input [3:0] opcode,
    output [12:0] cw,
    output reg halt
);

// ===== CONTROL WORD AND STATE REGISTERS =====
reg [12:0] control;
reg [2:0] t_state;

// ===== T-STATE PARAMETERS =====
parameter T1 = 3'b001;
parameter T2 = 3'b010;
parameter T3 = 3'b011;
parameter T4 = 3'b100;
parameter T5 = 3'b101;
parameter T6 = 3'b110;

// ===== INSTRUCTION PARAMETERS =====
parameter LDA = 4'b0000;
parameter ADD = 4'b0001;
parameter SUB = 4'b0010;
parameter OUT = 4'b1110;
parameter HLT = 4'b1111;

// ===== RING COUNTER (T-STATE GENERATOR) =====
always @(posedge clk or posedge rst) begin
    if (rst) begin
        t_state <= T1;
        halt <= 1'b0;
    end
    else if (!halt) begin
        case (t_state)
            T1: t_state <= T2;
            T2: t_state <= T3;
            T3: t_state <= T4;
            T4: begin
                if (opcode == HLT) begin
                    halt <= 1'b1;          // Set halt flag for HLT instruction
                    // Stay in T4 state when halted
                end else begin
                    t_state <= T5;
                end
            end
            T5: t_state <= T6;
            T6: t_state <= T1;              // Return to T1 for next instruction
            default: t_state <= T1;
        endcase
    end
end

// ===== CONTROL WORD GENERATION =====
always @(*) begin
    // Default: all control signals inactive
    control = 13'b0000000000000;
    
    case (t_state)
        // ===== FETCH CYCLE (T1-T3) - Same for all instructions =====
        T1: begin
            // PC → MAR: PC drives bus, MAR loads address
            control = 13'b1010000000000;
            // Bit 12: PC Enable = 1
            // Bit 10: MAR Load = 1
        end
        
        T2: begin
            // Memory → IR, PC++: RAM drives bus, IR loads, PC increments
            control = 13'b0001101000000;
            // Bit 9:  PC Increment = 1
            // Bit 8:  RAM Enable = 1
            // Bit 6:  IR Load = 1
        end
        
        T3: begin
            // Decode phase: no data movement, just internal processing
            control = 13'b0000000000000;
            // All bits = 0 (decode only)
        end
        
        // ===== EXECUTE CYCLE (T4-T6) - Varies by instruction =====
        T4: begin
            case (opcode)
                LDA: begin
                    // IR operand → MAR: IR drives operand address, MAR loads
                    control = 13'b0010010000000;
                    // Bit 10: MAR Load = 1
                    // Bit 7:  IR Enable = 1
                end
                
                ADD: begin
                    // IR operand → MAR: IR drives operand address, MAR loads
                    control = 13'b0010010000000;
                    // Bit 10: MAR Load = 1
                    // Bit 7:  IR Enable = 1
                end
                
                SUB: begin
                    // IR operand → MAR: IR drives operand address, MAR loads
                    control = 13'b0010010000000;
                    // Bit 10: MAR Load = 1
                    // Bit 7:  IR Enable = 1
                end
                
                OUT: begin
                    // Accumulator → Output: A drives bus, Output loads
                    control = 13'b0000000010001;
                    // Bit 4: A Enable = 1
                    // Bit 0: Output Load = 1
                end
                
                HLT: begin
                    // Halt system
                    control = 13'b0100000000000;
                    // Bit 11: Halt = 1
                end
                
                default: begin
                    control = 13'b0000000000000;
                end
            endcase
        end
        
        T5: begin
            case (opcode)
                LDA: begin
                    // Memory → Accumulator: RAM drives bus, A loads
                    control = 13'b0000100100000;
                    // Bit 8: RAM Enable = 1
                    // Bit 5: A Load = 1
                end
                
                ADD: begin
                    // Memory → B Register: RAM drives bus, B loads
                    control = 13'b0000100000010;
                    // Bit 8: RAM Enable = 1
                    // Bit 1: B Load = 1
                end
                
                SUB: begin
                    // Memory → B Register: RAM drives bus, B loads
                    control = 13'b0000100000010;
                    // Bit 8: RAM Enable = 1
                    // Bit 1: B Load = 1
                end
                
                OUT: begin
                    // OUT instruction completes in T4, T5 not used
                    control = 13'b0000000000000;
                end
                
                HLT: begin
                    // HLT instruction completes in T4, T5 not used
                    control = 13'b0000000000000;
                end
                
                default: begin
                    control = 13'b0000000000000;
                end
            endcase
        end
        
        T6: begin
            case (opcode)
                LDA: begin
                    // LDA instruction completes in T5, T6 not used
                    control = 13'b0000000000000;
                end
                
                ADD: begin
                    // ALU → Accumulator (Addition): ALU drives bus, A loads
                    control = 13'b0000000101000;
                    // Bit 5: A Load = 1
                    // Bit 3: ALU Enable = 1
                    // Bit 2: ALU Subtract = 0 (addition)
                end
                
                SUB: begin
                    // ALU → Accumulator (Subtraction): ALU drives bus, A loads
                    control = 13'b0000000101100;
                    // Bit 5: A Load = 1
                    // Bit 3: ALU Enable = 1
                    // Bit 2: ALU Subtract = 1 (subtraction)
                end
                
                OUT: begin
                    // OUT instruction completes in T4, T6 not used
                    control = 13'b0000000000000;
                end
                
                HLT: begin
                    // HLT instruction completes in T4, T6 not used
                    control = 13'b0000000000000;
                end
                
                default: begin
                    control = 13'b0000000000000;
                end
            endcase
        end
        
        default: begin
            control = 13'b0000000000000;
        end
    endcase
end

// ===== OUTPUT ASSIGNMENT =====
assign cw = control;

endmodule