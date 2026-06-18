# 🚀 RISC-V Processor in Verilog

A complete implementation of the **RISC-V RV32I Instruction Set Architecture (ISA)** in **Verilog HDL**, featuring both **Single-Cycle** and **Five-Stage Pipelined Processor** architectures. This project was developed from the ground up to understand processor design, datapath organization, control logic, instruction execution, hazard handling, and hardware verification.

The processor follows a modular design methodology and demonstrates how instructions are fetched, decoded, executed, and written back according to the RISC-V specification. The project also serves as a foundation for more advanced features such as forwarding, branch prediction, cache memory, and RV32M extensions.

---

![Verilog](https://img.shields.io/badge/Language-Verilog-blue)
![RISC-V](https://img.shields.io/badge/ISA-RV32I-green)
![Architecture](https://img.shields.io/badge/Architecture-Single--Cycle%20%26%20Pipelined-orange)
![RTL Design](https://img.shields.io/badge/RTL-Design-red)
![Simulation](https://img.shields.io/badge/Simulation-Icarus%20Verilog-success)
![Waveforms](https://img.shields.io/badge/Waveforms-GTKWave-yellow)
![Platform](https://img.shields.io/badge/Platform-Ubuntu%20%7C%20macOS-lightgrey)

---
# 📖 Project Overview

This repository contains custom implementations of the **RISC-V RV32I processor** in **Verilog HDL**, featuring both **Single-Cycle** and **Five-Stage Pipelined** architectures.

The project focuses on understanding and implementing the fundamental concepts of processor design, including datapath construction, control signal generation, instruction execution, pipelining, and hardware verification.

### Key Highlights

* RV32I Instruction Set Implementation
* Single-Cycle Processor Architecture
* Five-Stage Pipelined Processor Architecture
* Modular Verilog RTL Design
* Separate Instruction and Data Memories
* Register File and ALU Design
* Immediate Generation and Branch Logic
* Hazard Detection and Data Forwarding
* Functional Verification using Icarus Verilog and GTKWave

---

# ✨ Features

### Architecture

* Single-Cycle Datapath
* Five-Stage Pipeline (IF-ID-EX-MEM-WB)
* Pipeline Registers
* Hazard Detection Unit
* Forwarding Unit
* Branch Handling

### Instruction Support

Supported instruction formats include:

| Instruction Type | Status |
| ---------------- | ------ |
| R-Type           | ✅      |
| I-Type           | ✅      |
| S-Type           | ✅      |
| B-Type           | ✅      |

Implemented instructions:

* **R-Type:** add, sub, and, or, slt
* **I-Type:** lw
* **S-Type:** sw
* **B-Type:** beq

### Verification

* Icarus Verilog Simulation
* GTKWave Waveform Analysis
* Signal Tracing and Debugging
* Register and Memory Verification


---
# 🏗 Processor Architecture

This repository contains two implementations of the RISC-V RV32I processor:

1. **Single-Cycle Processor**
2. **Five-Stage Pipelined Processor**

Both processors follow the **Harvard Architecture**, utilizing separate instruction and data memories for improved modularity and simplicity.

---

# 🔹 Single-Cycle Processor Architecture

In the single-cycle architecture, every instruction is fetched, decoded, executed, and completed within a single clock cycle.

```text
Instruction Fetch
       ↓
Instruction Decode
       ↓
Execute
       ↓
Memory Access
       ↓
Write Back
```

Because all stages are completed in one clock cycle, the clock period must be large enough to accommodate the slowest instruction.

---

# Single-Cycle Datapath

<img width="689" height="398" alt="Screenshot 2026-06-18 at 4 27 15 PM" src="https://github.com/user-attachments/assets/c809cf91-7b99-4eeb-82f9-2cfacf617f73" />

---

# Overall Single-Cycle Execution Flow

```text
PC
 ↓
Instruction Memory
 ↓
Control Unit
 ↓
Register File
 ↓
Immediate Generator
 ↓
ALU
 ↓
Data Memory
 ↓
Writeback
```

---

# 🔹 Five-Stage Pipelined Processor Architecture

The pipelined processor improves throughput by overlapping the execution of multiple instructions.

The execution is divided into five stages:

```text
IF → ID → EX → MEM → WB
```

Multiple instructions occupy different stages simultaneously.

---

# Pipeline Datapath
<img width="716" height="269" alt="Screenshot 2026-06-18 at 4 28 33 PM" src="https://github.com/user-attachments/assets/c9012310-01fd-410a-b4d7-fcca74fe6a7f" />


---

# Pipeline Stages

## 1. Instruction Fetch (IF)

Responsible for:

* Fetching instructions from instruction memory
* Incrementing the Program Counter
* Computing PC + 4

Outputs:

* Instruction
* PC
* PC + 4

---

## 2. Instruction Decode (ID)

Responsible for:

* Decoding instruction fields
* Reading source registers
* Generating control signals
* Immediate generation

Outputs:

* RD1
* RD2
* Immediate
* Control signals

---

## 3. Execute Stage (EX)

Responsible for:

* ALU operations
* Address calculation
* Branch target generation
* Branch comparison

Outputs:

* ALU Result
* Zero Flag
* Branch Target Address

---

## 4. Memory Stage (MEM)

Responsible for:

* Data memory read
* Data memory write

Outputs:

* Memory Data
* ALU Result

---

## 5. Writeback Stage (WB)

Responsible for writing results back into the register file.

Possible writeback sources:

* ALU Result
* Data Memory Output
* PC + 4

---

# Pipeline Registers

Pipeline registers isolate each stage and allow instructions to execute concurrently.

---

## IF/ID Register

Stores:

* Instruction
* PC
* PC + 4

---

## ID/EX Register

Stores:

* Register operands
* Immediate values
* Destination register
* Control signals

---

## EX/MEM Register

Stores:

* ALU result
* Memory write data
* Destination register
* Memory control signals

---

## MEM/WB Register

Stores:

* Memory read data
* ALU result
* Destination register
* Writeback control signals

---

# Harvard Architecture

The processor uses separate memories for instructions and data.

Advantages:

✅ Simultaneous instruction fetch and memory access

✅ Simplified datapath

✅ Increased throughput

✅ Better modularity

---
# 📂 Repository Structure

The project is organized into modular Verilog components to simplify debugging, testing, and future extensions. Each module performs a specific task within the processor datapath.

```text
RISC-V/
│
├── Single_Cycle/
│   ├── single_cycle_top.v
│   ├── single_cycle_tb.v
│   ├── pc.v
│   ├── pcadder.v
│   ├── instruction_memory.v
│   ├── register_file.v
│   ├── sign_extend.v
│   ├── alu.v 
│   ├── alu_decoder.v
│   ├── main_decoder.v
│   ├── control_unit_top.v
│   ├── branch_adder.v
│   ├── data_memory.v
│   ├── mux.v
│   └── memfile.hex
│
├── Pipeline/
│   ├── pipeline_top.v
│   ├── pipeline_tb.v
│   ├── fetch_cycle.v
│   ├── decode_cycle.v
│   ├── execute_cycle.v
│   ├── memory_cycle.v
│   ├── writeback_cycle.v
│   └── hazard_unit.v
│
├── images/
│   ├── single_cycle_datapath.png
│   ├── pipeline_datapath.png
│   ├── rtype_waveform.png
│   ├── itype_waveform.png
│   ├── stype_waveform.png
│   └── btype_waveform.png
│
└── README.md
```

---

# 🔧 Module Descriptions

The processor is divided into reusable modules, each responsible for a specific function.

---

## Program Counter (`pc.v`)

Maintains the address of the current instruction.

### Responsibilities

* Store current PC value
* Update PC every clock cycle
* Support branch target selection

### Inputs

* Clock
* Reset
* Next PC

### Outputs

* Current PC

---

## PC Adder (`pcadder.v`)

Computes:

```text
PC + 4
```

which points to the next sequential instruction.

---

## Instruction Memory (`instruction_memory.v`)

Stores machine instructions.

### Input

* PC

### Output

* Instruction

### Purpose

Provides instructions to the fetch stage.

---

## Register File (`register_file.v`)

Implements the 32 general-purpose RISC-V registers.

### Features

* Two read ports
* One write port
* Synchronous write
* Combinational read

### Registers

```text
x0 – x31
```

### Responsibilities

* Read rs1
* Read rs2
* Write rd

---

## Sign Extension Unit (`sign_extend.v`)

Generates immediate values for different instruction formats.

Supported immediates:

* I-Type
* S-Type
* B-Type

### Purpose

Converts instruction fields into 32-bit signed values.

---

## Arithmetic Logic Unit (`alu.v`)

Performs arithmetic and logical operations.

### Supported Operations

| Operation | Description   |
| --------- | ------------- |
| ADD       | Addition      |
| SUB       | Subtraction   |
| AND       | Bitwise AND   |
| OR        | Bitwise OR    |
| SLT       | Set Less Than |

### Outputs

* Result
* Zero flag

---

## Main Decoder (`main_decoder.v`)

Decodes the opcode field and generates control signals.

Generated signals:

* RegWrite
* ALUSrc
* MemWrite
* ResultSrc
* Branch
* ALUOp

---

## ALU Decoder (`alu_decoder.v`)

Uses:

* ALUOp
* funct3
* funct7

to generate the ALU control signal.

---

## Control Unit (`control_unit_top.v`)

Combines:

* Main Decoder
* ALU Decoder

to generate all processor control signals.

---

## Branch Adder (`branch_adder.v`)

Computes:

```text
PC + Immediate
```

Used for branch instructions.

---

## Data Memory (`data_memory.v`)

Provides memory access for:

### Load Operations

```assembly
lw
```

### Store Operations

```assembly
sw
```

Supports:

* Memory Read
* Memory Write

---

## Multiplexers (`mux.v`)

Control data flow throughout the datapath.

Used for selecting:

* ALU operands
* Writeback source
* Next PC

---
# 📚 Instruction Set Architecture

The processor implements a subset of the **RV32I Base Integer Instruction Set**. The current implementation supports **R-Type**, **I-Type**, **S-Type**, and **B-Type** instructions.

---

# Supported Instruction Formats

| Instruction Type | Description                     | Status |
| ---------------- | ------------------------------- | ------ |
| R-Type           | Register-to-Register Operations | ✅      |
| I-Type           | Load Operations                 | ✅      |
| S-Type           | Store Operations                | ✅      |
| B-Type           | Conditional Branch Operations   | ✅      |

---

# Supported Instructions

| Instruction | Type | Opcode  | funct3 | funct7  | Description   |
| ----------- | ---- | ------- | ------ | ------- | ------------- |
| add         | R    | 0110011 | 000    | 0000000 | Addition      |
| sub         | R    | 0110011 | 000    | 0100000 | Subtraction   |
| and         | R    | 0110011 | 111    | 0000000 | Bitwise AND   |
| or          | R    | 0110011 | 110    | 0000000 | Bitwise OR    |
| slt         | R    | 0110011 | 010    | 0000000 | Set Less Than |
| lw          | I    | 0000011 | 010    | -       | Load Word     |
| sw          | S    | 0100011 | 010    | -       | Store Word    |
| beq         | B    | 1100011 | 000    | -       | Branch Equal  |

---

# 🔹 R-Type Instructions

R-Type instructions perform arithmetic and logical operations between two source registers.

### Instruction Format

```text
31      25 24   20 19   15 14 12 11    7 6      0
+---------+-------+-------+------+-------+--------+
| funct7  | rs2   | rs1   |funct3|  rd   | opcode |
+---------+-------+-------+------+-------+--------+
```

---

## Implemented Operations

| Instruction | Operation                |
| ----------- | ------------------------ |
| add         | rd = rs1 + rs2           |
| sub         | rd = rs1 - rs2           |
| and         | rd = rs1 & rs2           |
| or          | rd = rs1 | rs2           |
| slt         | rd = (rs1 < rs2) ? 1 : 0 |

---

### Example

```assembly
or x4, x5, x6
```

Operation:

```text
x4 = x5 OR x6
```

Machine Code:

```text
0062E233
```
<img width="1470" height="956" alt="Rtype" src="https://github.com/user-attachments/assets/03cf9fb2-c3e6-41d5-875c-3b6dbdda7b50" />

---

# 🔹 I-Type Instructions

I-Type instructions use an immediate operand together with a source register.

### Instruction Format

```text
31                     20 19   15 14 12 11    7 6      0
+-----------------------+-------+------+-------+--------+
|      immediate        | rs1   |funct3|  rd   | opcode |
+-----------------------+-------+------+-------+--------+
```

---

## Implemented Operations

| Instruction | Operation                 |
| ----------- | ------------------------- |
| lw          | rd = Mem[rs1 + immediate] |

---

### Example

```assembly
lw x6, -4(x9)
```

Operation:

```text
x6 = Mem[x9 - 4]
```

Machine Code:

```text
FFC4A303
```
<img width="1470" height="956" alt="Itypess" src="https://github.com/user-attachments/assets/203b4162-d411-43ae-89a6-cad5273f31be" />
---

# 🔹 S-Type Instructions

S-Type instructions are used for memory write operations.

### Instruction Format

```text
31      25 24   20 19   15 14 12 11    7 6      0
+---------+-------+-------+------+-------+--------+
|imm[11:5]| rs2   | rs1   |funct3|imm[4:0]|opcode |
+---------+-------+-------+------+-------+--------+
```

---

## Implemented Operations

| Instruction | Operation                  |
| ----------- | -------------------------- |
| sw          | Mem[rs1 + immediate] = rs2 |

---

### Example

```assembly
sw x6, 8(x9)
```

Operation:

```text
Mem[x9 + 8] = x6
```

Machine Code:

```text
0064A423
```
<img width="1470" height="956" alt="stype" src="https://github.com/user-attachments/assets/8aa03144-7e39-417a-b031-bd4910bbe288" />

---

# 🔹 B-Type Instructions

B-Type instructions modify the Program Counter based on the result of a comparison.

### Instruction Format

```text
31      30 25 24   20 19   15 14 12 11   8 7     6      0
+--------+-----+-------+-------+------+-----+----+--------+
|imm[12] |10:5 | rs2   | rs1   |funct3|4:1 |11 | opcode |
+--------+-----+-------+-------+------+-----+----+--------+
```

---

## Implemented Operations

| Instruction | Operation            |
| ----------- | -------------------- |
| beq         | Branch if rs1 == rs2 |

---

### Example

```assembly
beq x2, x3, label
```

Operation:

```text
if (x2 == x3)
    PC = PC + offset
else
    PC = PC + 4
```
<img width="1470" height="956" alt="B type" src="https://github.com/user-attachments/assets/0087680b-a7c4-4864-b19a-b2f68bbcdcd2" />
---


# Pipeline Stages

## 1. Instruction Fetch (IF)

Responsible for:

* Fetching instructions from instruction memory
* Maintaining and updating the Program Counter
* Computing PC + 4

### Inputs

* Current PC

### Outputs

* Instruction
* PC
* PC + 4

---

## 2. Instruction Decode (ID)

Responsible for:

* Decoding the instruction
* Reading source registers
* Generating immediate values
* Producing control signals

### Outputs

* RD1
* RD2
* Immediate value
* Destination register
* Control signals

---

## 3. Execute Stage (EX)

Responsible for:

* Performing ALU operations
* Address calculation
* Branch target generation
* Operand selection

### Outputs

* ALU Result
* Zero Flag
* Branch Address

---

## 4. Memory Access Stage (MEM)

Responsible for:

* Reading from data memory
* Writing to data memory

### Outputs

* Read Data
* ALU Result

---

## 5. Write Back Stage (WB)

Responsible for writing results back into the register file.

Writeback sources:

* ALU Result
* Memory Read Data
* PC + 4

---

# Pipeline Registers

Pipeline registers isolate each stage and preserve intermediate results.

---

## IF/ID Register

Stores:

* Instruction
* PC
* PC + 4

Purpose:

Transfers information from Fetch stage to Decode stage.

---

## ID/EX Register

Stores:

* Register operands
* Immediate values
* Destination register
* Control signals

Purpose:

Transfers decoded information to Execute stage.

---

## EX/MEM Register

Stores:

* ALU result
* Write data
* Destination register
* Memory control signals

Purpose:

Transfers execution results to Memory stage.

---

## MEM/WB Register

Stores:

* Memory read data
* ALU result
* Destination register
* Writeback control signals

Purpose:

Transfers final results to Writeback stage.

---

# Instruction Overlap

Pipeline execution enables multiple instructions to occupy different stages simultaneously.

Example:

```assembly
lw   x1,0(x0)
lw   x2,4(x0)
or   x3,x1,x2
sw   x3,8(x0)
```

Pipeline execution:

```text
Cycle →      1    2    3    4    5    6    7    8

lw x1         IF   ID   EX  MEM  WB

lw x2              IF   ID   EX  MEM  WB

or x3                   IF   ID   EX  MEM  WB

sw x3                        IF   ID   EX  MEM
```

Thus, multiple instructions are executed concurrently.

---

# Data Hazards

A data hazard occurs when an instruction depends on the result of a previous instruction that has not yet completed.

Example:

```assembly
add x5,x1,x2
sub x6,x5,x3
```

The SUB instruction requires x5 before the ADD instruction completes.

---

# Forwarding Unit

To avoid unnecessary stalls, a forwarding unit is implemented.

It forwards results from later stages directly to the Execute stage.

Forwarding sources:

* EX/MEM stage
* MEM/WB stage

Benefits:

✅ Reduces stalls

✅ Improves throughput

✅ Eliminates unnecessary waiting

---

# Hazard Detection Unit

Some hazards cannot be resolved using forwarding alone.

Example:

```assembly
lw  x5,0(x1)
add x6,x5,x2
```

Since the data from memory becomes available only after the MEM stage, the ADD instruction must be delayed.

The hazard detection unit:

* Detects load-use hazards
* Inserts stalls when necessary
* Prevents incorrect execution

---

# Branch Hazards

Branch instructions can change program flow.

Example:

```assembly
beq x1,x2,label
```

Until the comparison is complete, the processor does not know the next PC value.

Branch hazards may cause:

* Incorrect instruction fetch
* Pipeline flushing

---

# Pipeline Performance

### Single-Cycle Processor

```text
One instruction completes every clock cycle.
```

Execution:

```text
Instr1
Instr2
Instr3
Instr4
```

Sequential execution.

---

### Pipelined Processor

```text
Multiple instructions execute simultaneously.
```

Execution:

```text
Cycle 1 : Instr1 IF

Cycle 2 : Instr1 ID
          Instr2 IF

Cycle 3 : Instr1 EX
          Instr2 ID
          Instr3 IF

Cycle 4 : Instr1 MEM
          Instr2 EX
          Instr3 ID
          Instr4 IF
```

Result:

Higher instruction throughput.

---

# Advantages of Pipelining

✅ Increased throughput

✅ Better hardware utilization

✅ Reduced average instruction execution time

✅ Improved processor performance

✅ Foundation for advanced architectures

---



# 📚 References

This project is based primarily on:

### Digital Design and Computer Architecture: RISC-V Edition

**Sarah Harris and David Harris**

Additional references:

* RISC-V ISA Manual
* Computer Organization and Design – Patterson & Hennessy
* RISC-V Foundation Documentation

---

#  Author

**Yashvi Doshi**


---
