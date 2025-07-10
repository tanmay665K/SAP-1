# SAP-1

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
11. Adder/Subtractor

## II. Blocks

### 1. Clock

It is the driving force of the entire operation. Without it, no operation could take place and the whole project would just be lines of code. It ensures synchronization of each block, so that one block does not get ahead of the other. In this design, we use a ```posedge clk```, meaning blocks trigger only on the positve edge of the clock. 

![posedge clock](data:image/png;base64,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)

There is also a halt or ```hlt``` signal, so that clock turns **OFF** when it is asserted (```hlt == 1```). It gives a way to switch off the system after our program is done executing, and not waste any further clock cycles.


### 2. Program Counter (PC)
It holds the address of the next instruction that the system should execute. Without it, a computer would have no idea what to do next and it would be stuck. Since the SAP-1 has a 16x8 RAM, i.e. 16 memory locations, each of 8-bit width, our PC is a 4-bit value, covering all 16 locations in memory. Once each instruction is fetched, the PC is incremented, pointing to the next memory location. The PC resets only on 2 conditions - i) When reset signal is assereted **OR** ii) PC reaches maximum possible value (15, in this case).\

Signals -
1. Input - 
- Clock (clk): PC increments on every positive edge
- Reset (rst): Reset signal, which forces PC to 0
- Increment (inc): Increment signal, PC will increment only when this signal is high. Used to control when to move to next instruction

### 3. Data Bus
It is responsible for transporting to-and-from each block. From the block diagram, most components use the bus to send data via the bus to other components, or be loaded with data from the bus.This is controlled by enable and load signals, which each block is defined with. If an enable signal is high, data moves from Block -> Bus, and vice-versa if load signal is high. Only one block can drive the bus at a time, to prevent any conflicts.

### 4. Accumalator (A) Register
The primary register of the SAP-1. All arithmetic operations are done in here, and then sent onto the bus, which then go to the output register. It is loaded using the **LDA** instruction, generally the first instruction of the assembly program.


