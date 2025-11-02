# I.  SAP-1 Overview

This repository is for the Verilog implementation of the SAP-1 as described in **"Digital Computer Electronics"** by Albert Malvino. It is a simple 8-bit computer which I have implemented using Icarus Verilog and GTKWave for waveform visualization.

Another very helpful reference were the blog posts by [Austin Morlan](https://austinmorlan.com/), which can be found at this [link](https://austinmorlan.com/posts/fpga_computer_sap1/). The explanations and breakdowns, make understanding the architecture quite easy for a beginner like me. He has also made similar posts for SAP-2 & SAP-3. Althogh some aspects of my design deviate from his, the basic structure of the blocks and their connections remain quite similar.

![SAP-1 Block Diagram](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEje-5qfLwK7MbSywZJXEEuvJJCN6Hww3ECKz3Ho6ayLmj1W5CxNARhY2BN7cgFLTc0j8ITa5hxnbOFHNQsxC2kDAIUI64fvfCerC2Ver6KOgI6ljXBTpJq6jt_uJLjUrzUFWbjTvT9T8Xc/s1600/image1.jpeg)

As seen by the block diagram, these are the following blocks involved in the SAP-1:

1. Data Bus
2. Accumalator (A) Register
3. Clock
4. 16x8 RAM 
5. Memory Address Register (MAR)
6. Program Counter (PC)
7. Instruction Register (IR)
8. Register B 
9. Output Register
10. Controller Sequencer
11. Adder/Subtractor (ALU)

## II. Instruction Set
The SAP-1 is a very simple architecture with only 5 instructions. In the brackets are the opcodes for each instruction which will be usedful when writing the assembly program. 
1. **LDA (0000)**: Used to load register A with the value stored at the address referenced. Eg. LDA 8H -> Loads A with the value stored at 8H in RAM

2. **ADD (0001)**: Used to add contents of registers A & B.
Eg. ADD 6H -> First loads B with the value stored at 6H in RAM, then does addition of contents of A & B

3. **SUB (0010)**: Similar to ADD, but rather than addition, it performs A-B

4. **OUT (1110)**: Tells SAP-1 to transfer contents of A to output register

5. **HLT (1111)**: Halts SAP-1 operation by enabling ```hlt``` signal of the clock

LDA, ADD, SUB are memory-reference instructions since they need a corresponding memory address for them to carry out operations.

OUT, HLT are non memory-reference instructions since they don't require memory addresses to carry out operations.

For this implementation, the SAP-1 will execute a program to compute **16+20+24-32**, which should output 28. The program for this is stored in the [program.bin](https://github.com/tanmay665K/SAP-1/blob/main/Programs/program.bin) file in the [Programs](https://github.com/tanmay665K/SAP-1/tree/main/Programs) directory.

## III. Blocks

### 1. Clock

It is the driving force of the entire operation. Without it, no operation could take place and the whole project would just be lines of code. It ensures synchronization of each block, so that one block does not get ahead of the other. In this design, we use a ```posedge clk```, meaning blocks trigger only on the positve edge of the clock. 
There is also a halt or ```hlt``` signal, so that clock turns **OFF** when it is asserted (```hlt == 1```). It gives a way to switch off the system after our program is done executing, and not waste any further clock cycles.


### 2. Program Counter (PC)
It holds the address of the next instruction that the system should execute. Without it, a computer would have no idea what to do next and it would be stuck. Since the SAP-1 has a 16x8 RAM, i.e. 16 memory locations, each of 8-bit width, our PC is a 4-bit value, covering all 16 locations in memory. Once each instruction is fetched, the PC is incremented, pointing to the next memory location. The PC resets only on 2 conditions - i) When reset signal is assereted **OR** ii) PC reaches maximum possible value (15, in this case).\

Signals:
1. Input:
- Clock (clk): PC increments on every positive edge
- Reset (rst): Reset signal, which forces PC to 0
- Increment (inc): Increment signal, PC will increment only when this signal is high. Used to control when to move to next instruction

2. Output:
- 4-bit output (0-F) of current address
### 3. Data Bus
It is responsible for transporting to-and-from each block. From the block diagram, most components use the bus to send data via the bus to other components, or be loaded with data from the bus.This is controlled by enable and load signals, which each block is defined with. If an enable signal is high, data moves from Block -> Bus, and vice-versa if load signal is high. Only one block can drive the bus at a time, to prevent any conflicts.

### 4. Accumalator (A) Register
Since the SAP-1 is an 8-bit computer, all it's registers will be 8-bit as well. It is the primary register of the SAP-1. All arithmetic operations are done in here, and then sent onto the bus, which then go to the output register. It is loaded using the **LDA** instruction, generally the first instruction of the assembly program.

Signals:

1. Input:
- Clock (clk): Triggers only on positive edge (```posedge```) of clk
- Reset (rst): If **HIGH** (1), A is wiped, and resets to a value of 0
- Load (load): If **HIGH** (1), A is loaded with data from the bus
- Bus (bus): 4-bit data from RAM (zero extended to 8-bit), loaded into A only if ```load``` is **HIGH** (1).

2. Output:
- Output (out): 8-bit output value that is sent to the bus/ALU only when ```enable``` signal is HIGH (1), which we will see in the top module

### 5. Register B
The secondary register of the SAP-1. It is only used for supporting Register A, carrying out arithmetic operations, A+B & A-B.
While there is no direct instruction for loading reg. B as there is for A, the **ADD** and **SUB** instructions are used to do so. The ADD/SUB instruction will first load B with the value stored in the referenced address and then perform the required operation.

Signals:
1. Input:
- Clock (clk): Acts only on ```posedge``` of the clock
- Reset (rst): Resets B to hold 0
- Load (load): Data from bus is loaded only when load is **HIGH**
- Bus: 4-bit value from RAM (zero extended to 8-bit)

2. Output (out): 8-bit output, sent to adder/subtractor

### 6. Adder/Subtractor

Used for arithmetic operations - addition and subtraction. The contents of A and B are loaded and based on the signal, addition or subtraction is carried out. After the operation, result is loaded onto the bus and sent back to A, where it is stored until the next instruction.

Signals:
1. Input:
- Subtract (sub): Tells the adder whether to carry out addition or subtraction. If HIGH: A-B, LOW: A+B
- A: 8-bit input from register A
- B: 8-bit input from register B

2. Output:
- Out: 8-bit output holding sum/difference, sent back to A after computation

### Instruction Register (IR):
When the computer needs to fetch instructions, it performs a memory read operation. This places the contents of the addresses memory location on the bus. The contents of the instruction register are split into two - opcode, operand, the width of each being 4 bits. 

The opcode is sent to the controller/sequencer, which will decide the control signals, the blocks to be activated. The operand is another location in memory, which contains the value to be loaded into either A or B (depending on the instruction).

Signals:

#### 1. Input:
1. Clock (clk): Acts only on the positive edge of clock
2. Reset (rst): Resets the IR
3. Load (load): IR is loaded by bus data, only when HIGH
4. Bus: 8-bit bus data via read operation from memory

#### 2. Output:
1. Instruction: 8-bit output data, which is split into 2 4-bit nibbles, upper nibble being **opcode** and lower nibble being **operand**. The split occurs in the top module

### Memory Address Register (MAR) & RAM:
Static TTL 16x8 RAM, which holds operands and instructions. For our implementation, we have created a .bin file (program.bin). It is a 16 line file, containing the assembly program to be executed in hex. 

The memory is read-only meaning the computer cannot write back to the memory. So, the program which we execute will be static throughout the duration of the run and no instructions or addresses can be changed.

Since there are no branch, jump, or conditional instructions, we do not require much memory. However, in SAP-2, these types of instructions are present and frequently used, which is why it has a 64K memory with both RAM and ROM.

The MAR is used to access the data stored in the RAM. It is a 4-bit value, 0-F and based on its value, that particular line in memory is read, decoded and then executed.

Signals (RAM):
1. Address: 4-bit value, comes from the MAR. Used to read specific address line.
2. Read Enable: Enable signal for reading from memory
3. Output Data: Data stored in RAM, sent as output

Signals (MAR):

1. Clock(clk): Acts only positive edge of the clock
2. Reset(rst): Resets the MAR
3. Load (load): Enable signal to load MAR from bus
4. Address(address): 4-bit output fed to MAR, holding the address to be read

### Output Register:

It holds the final output value after all operations have executed completely. When the computer encounters the OUT instruction (opcode 1110), it sends the final value stored in accumalator (A) onto the bus, loads the output register, which can be connected to a display device like LCDs, or 7 segment displays.

Signals:
##### 1. Input:
1. Clock (clk): Acts only on positive edge of the clock
2. Reset (rst): Resets the output register, by clearing it of all contents
3. Load (load): Enable signal to load it with contents from A
4. Bus: 8-bit data from A via bus

#### 2. Output
1. Out: 8-bit output
### Controller/Sequencer:
It is the most important and complex block of the SAP-1. It acts as the coordinator for the entire computer and is responsible for sending out signals which will carry out our instructions. It is a 12-bit word, each bit being a control signal telling the computer to perform a specific operation. 

```
11: HALT
10: MI (MAR Load)
9: PC_INC (PC Increment)
8: RO (RAM Read)
7: IO (IR address o/p to bus)
6: II (IR load)
5: AI (Accumalator load)
4: AO (Accumalator Output)
3: EO (ALU output)
2: SU (ALU subtract)
1: BI (B register load)
0: OI (Output register load)
```

We also need to talk about the timing states or T-states, which are used to fetch, decode and execute each instruction of our assembly program. Basically, it is the sequence of operation our computer follows when handling each instruction.

There are a total of 6 T-states (T1-T6), each one having a unique purpose. For any instruction, the first 3 T-states are common with the next three being unique to each instruction. For example, ADD goes through all 6 states, while HLT only needs 4.

The first state (T1) is called the **address state**. Here, the address in the PC is transferred to the MAR. The controller outputs the word ```0x090```.

The second state (T2) is called the **increment state**. As the name implies the PC is incremented, giving output control word (CW) ```0x1A0```.


T3 or the **memory state** is when SAP-1 reads the actual instruction from memory. The RAM outputs the instruction located at the address stored in MAR, and this instruction gets loaded into the Instruction Register (IR). The CW for this state is ```0x000```.

Now, we will move onto the remaining states (T4-T6) for each instruction (LDA, ADD, SUB, HLT, OUT).





















