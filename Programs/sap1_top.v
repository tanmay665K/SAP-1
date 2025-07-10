module sap1_top(
    input clk_in,
    input rst,
    output [7:0] display
);

// ===== CLOCK MODULE =====
wire system_clk;

clock clock_controller(
    .clk_in(clk_in),
    .hlt(control_word[11]),
    .clk_out(system_clk)
);

// ===== INTERNAL BUSES AND SIGNALS =====
wire [7:0] bus;                    // Main 8-bit system bus
wire [12:0] control_word;          // 13-bit control word (expanded for PC enable)

// Component interconnection wires
wire [3:0] pc_out;                 // Program counter output (4-bit)
wire [3:0] mar_out;                // MAR output to RAM (4-bit)
wire [7:0] ir_output;              // Instruction register output (8-bit)
wire [7:0] a_out;                  // Accumulator output (8-bit)
wire [7:0] b_out;                  // B register output (8-bit)
wire [7:0] alu_result;             // ALU output (8-bit)
wire [7:0] ram_data;               // RAM output (8-bit)

// Extracted instruction components
wire [3:0] opcode;                 // Upper 4 bits of IR (instruction type)
wire [3:0] operand;                // Lower 4 bits of IR (address/data)

// System status
wire halt;                         // Halt signal from control unit

// ===== CONTROL SIGNAL EXTRACTION =====
// Extract individual control signals from 13-bit control word
wire pc_enable    = control_word[12];  // PC drives bus (NEW!)
wire hlt_signal   = control_word[11];  // Halt system
wire mar_load     = control_word[10];  // MAR loads from bus
wire pc_inc       = control_word[9];   // PC increment
wire ram_enable   = control_word[8];   // RAM drives bus
wire ir_enable    = control_word[7];   // IR drives bus (operand)
wire ir_load      = control_word[6];   // IR loads from bus
wire a_load       = control_word[5];   // Accumulator loads from bus
wire a_enable     = control_word[4];   // Accumulator drives bus
wire alu_enable   = control_word[3];   // ALU drives bus
wire alu_sub      = control_word[2];   // ALU subtract mode
wire b_load       = control_word[1];   // B register loads from bus
wire out_load     = control_word[0];   // Output register loads from bus

// ===== INSTRUCTION DECODING =====
assign opcode = ir_output[7:4];        // Extract opcode from instruction
assign operand = ir_output[3:0];       // Extract operand from instruction

// ===== BUS ARBITRATION (TRI-STATE LOGIC) =====
// Only one component can drive the bus at any time
assign bus = pc_enable  ? {4'b0000, pc_out} : 8'bz;        // PC → Bus
assign bus = ram_enable ? ram_data : 8'bz;                 // RAM → Bus
assign bus = ir_enable  ? {4'b0000, operand} : 8'bz;      // IR operand → Bus
assign bus = a_enable   ? a_out : 8'bz;                    // Accumulator → Bus
assign bus = alu_enable ? alu_result : 8'bz;               // ALU → Bus

// ===== COMPONENT INSTANTIATIONS =====

// Program Counter - tracks current instruction address
pc program_counter(
    .clk(system_clk),
    .rst(rst),
    .inc(pc_inc),
    .out(pc_out)
);

// Memory Address Register - holds address for RAM access
mar memory_address_register(
    .clk(system_clk),
    .rst(rst),
    .load(mar_load),
    .bus(bus),
    .address(mar_out)
);

// RAM - stores instructions and data
ram memory(
    .address(mar_out),
    .read_enable(ram_enable),
    .data_out(ram_data)
);

// Instruction Register - holds current instruction
ir instruction_register(
    .clk(system_clk),
    .rst(rst),
    .load(ir_load),
    .bus(bus),
    .instruction(ir_output)
);

// Accumulator (A Register) - primary working register
reg_a accumulator(
    .clk(system_clk),
    .rst(rst),
    .load(a_load),
    .bus(bus),
    .out(a_out)
);

// B Register - secondary operand register
regb b_register(
    .clk(system_clk),
    .rst(rst),
    .load(b_load),
    .bus(bus),
    .out(b_out)
);

// ALU - performs arithmetic operations
alu arithmetic_unit(
    .sub(alu_sub),
    .a(a_out),
    .b(b_out),
    .out(alu_result)
);

// Output Register - displays results
reg_out display_register(
    .clk(system_clk),
    .rst(rst),
    .load(out_load),
    .bus(bus),
    .out(display)
);

// Control Unit - generates all control signals
controller control_unit(
    .clk(system_clk),
    .rst(rst),
    .opcode(opcode),
    .cw(control_word),
    .halt(halt)
);

endmodule