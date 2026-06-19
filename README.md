# RISC-V Processor in Verilog

A RV32I-subset processor built in two versions: a single-cycle design and a five-stage pipelined design. Both are written in Verilog, simulated with Icarus Verilog, and checked against GTKWave waveforms.

![Verilog](https://img.shields.io/badge/Language-Verilog-blue)
![RISC-V](https://img.shields.io/badge/ISA-RV32I%20(subset)-green)
![Architecture](https://img.shields.io/badge/Architecture-Single--Cycle%20%26%20Pipelined-orange)
![Simulation](https://img.shields.io/badge/Simulation-Icarus%20Verilog-success)
![Waveforms](https://img.shields.io/badge/Waveforms-GTKWave-yellow)

---

## Overview

This repo has two separate RTL implementations of a RISC-V core. The point of building both was to actually feel the trade off between a simple design and a fast one, instead of just reading about it.

| | Single-Cycle | Pipelined |
|---|---|---|
| **How it runs** | Each instruction goes from fetch to writeback in one clock cycle | Five instructions are in flight at once, across IF, ID, EX, MEM, WB |
| **Clock period** | Set by the slowest instruction's full path | Set by the slowest single stage, so it's much shorter |
| **Hazards** | None to worry about, since one instruction finishes before the next starts | Data hazards are handled with forwarding. See Known Limitations below for what isn't handled yet |
| **Why build it** | Reference design to check instruction semantics are correct | Shows instruction level parallelism and how forwarding actually works in hardware |

Both versions use a Harvard memory model (instruction memory and data memory are separate) and support the same instruction set: add, sub, and, or, slt, lw, sw, beq.

---

## Repository Structure

All the source files currently sit in one flat directory rather than separate folders. The grouping below is just for readability, it's not the literal folder layout.

**Single-cycle datapath**
```
single_cycle_top.v        Top level integration
single_cycle_top_tb.v     Testbench
pc.v                      Program counter
pcadder.v                 PC+4 and branch target adder
instruction_memory.v      Instruction ROM
register_file.v           32 x 32-bit register file (x0 to x31)
sign_extend.v             Immediate generation
alu.v                     Arithmetic and logic unit
alu_decoder.v             ALU control decode
main_decoder.v            Opcode to control signal decode
control_unit_top.v        Combines main and ALU decoders
branch_adder.v            Branch target calculation
data_memory.v             Data RAM
mux.v / mux_3by1.v        2:1 and 3:1 multiplexers
```

**Pipelined datapath**
```
pipeline_top.v             Top level integration
pipeline_tb.v               Testbench
fetch_cycle.v                IF stage plus IF/ID register
decode_cycle.v               ID stage plus ID/EX register (control decode, register read)
execute_cycle.v               EX stage plus EX/MEM register (ALU, forwarding muxes, branch resolution)
memory_cycle.v                MEM stage plus MEM/WB register
writeback_cycle.v             WB stage
hazard_unit.v                 Forwarding logic (EX/MEM and MEM/WB feeding back into EX)
```

**Shared files**
```
memfile.hex                 Sample program loaded into instruction memory
*.vcd, *.ron                  Waveform dumps and GTKWave session files
images/                      Datapath diagrams and waveform captures
```

---

## Single-Cycle Processor

Every instruction is fetched, decoded, executed, and written back inside one clock cycle. That means there's no hazard logic to write at all, since the previous instruction is fully done by the time the next one starts. The tradeoff is the clock period has to be long enough for the slowest possible instruction to finish, which is usually lw since it touches the ALU, data memory, and register file one after another.

<img width="689" height="398" alt="Single-cycle datapath" src="https://github.com/user-attachments/assets/c809cf91-7b99-4eeb-82f9-2cfacf617f73" />

| Module | File | What it does |
|---|---|---|
| Program Counter | pc.v | Holds the address of the instruction currently executing |
| PC Adder | pcadder.v | Computes PC + 4 |
| Instruction Memory | instruction_memory.v | Returns the instruction word at a given address |
| Register File | register_file.v | 32 general purpose 32-bit registers, two reads and one write |
| Sign Extension Unit | sign_extend.v | Expands instruction immediates to 32 bits depending on format type |
| ALU | alu.v | Does add, subtract, AND, OR, and comparisons |
| Main Decoder | main_decoder.v | Generates top level control signals from the opcode |
| ALU Decoder | alu_decoder.v | Works out the specific ALU operation from funct3/funct7 |
| Control Unit | control_unit_top.v | Combines the main and ALU decoders |
| Branch Adder | branch_adder.v | Computes the branch target address |
| Data Memory | data_memory.v | Handles lw and sw |
| Multiplexers | mux.v | Select which signal flows through the datapath at each decision point |

---

## Pipelined Processor

The pipelined design splits execution across five stages, with each stage working on a different instruction in the same clock cycle:

```
IF -> ID -> EX -> MEM -> WB
```

<img width="716" height="269" alt="Pipeline datapath" src="https://github.com/user-attachments/assets/c9012310-01fd-410a-b4d7-fcca74fe6a7f" />

| Stage | What it does |
|---|---|
| IF, Fetch | Reads the next instruction from memory and advances the PC |
| ID, Decode | Decodes the instruction, reads the source registers, generates control signals |
| EX, Execute | Runs the ALU operation and resolves the branch target and condition |
| MEM, Memory | Reads or writes data memory for lw and sw |
| WB, Writeback | Writes the result back into the register file |

Pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB) hold onto the control signals and data values each stage produces so the next stage can use them.

**Files:** fetch_cycle.v, decode_cycle.v, execute_cycle.v, memory_cycle.v, writeback_cycle.v, hazard_unit.v, mux_3by1.v

### Data Hazard Resolution

If an instruction needs a register value that an earlier instruction still in the pipeline hasn't written back yet, the design resolves it through forwarding. hazard_unit.v checks the destination registers sitting in the EX/MEM and MEM/WB stages against the source registers of whatever instruction is currently in EX, and routes the most recent value straight into the ALU inputs through mux_3by1.v, instead of waiting on the register file's normal write then read order.

### Known Limitations

This works correctly for back to back ALU, load, and store sequences, but there are two hazard cases it doesn't fully handle yet. Flagging them here rather than pretending the design is complete:

- **Load-use hazard.** A value loaded by lw isn't actually ready until the end of MEM, which is one cycle later than forwarding from EX/MEM would need. Right now there's no stall inserted for this case, so an lw immediately followed by an instruction that needs its result can end up reading a stale value. The fix is a hazard detection unit that stalls IF/ID and ID/EX for one cycle, and that's next on the list.
- **Branch flush.** beq gets resolved in EX (pcsrcE = branchE & zeroE in execute_cycle.v), and by that point two more instructions have already been fetched into IF/ID and ID/EX. The PC redirect itself works fine on a taken branch, but those two instructions already in the pipeline aren't squashed, so they'll incorrectly keep moving forward. Adding flush logic on IF/ID and ID/EX, triggered off pcsrcE, is the other item I'm planning to add.

Both of these are standard, well known pipeline hazards, not something unusual to this project. They're listed here because I'd rather be upfront about what's done and what isn't.

---

## Verification: Traced Program Execution

Simulating without errors isn't proof the pipeline actually computes the right thing, so I loaded a small six instruction program into instruction memory and traced it cycle by cycle in GTKWave.

memfile.hex, loaded starting at address 0x00000000:

```
@00000000
00500293
00300313
006283B3
00002403
00100493
00940533
```

Disassembled:

| Address | Hex | Instruction | Effect |
|---|---|---|---|
| 0x00 | 00500293 | addi x5, x0, 5 | x5 = 5 |
| 0x04 | 00300313 | addi x6, x0, 3 | x6 = 3 |
| 0x08 | 006283B3 | add  x7, x5, x6 | x7 = 8 |
| 0x0c | 00002403 | lw   x8, 0(x0) | x8 = Mem[0] |
| 0x10 | 00100493 | addi x9, x0, 1 | x9 = 1 |
| 0x14 | 00940533 | add  x10, x8, x9 | x10 = x8 + x9 |

GTKWave trace of pipeline_tb running this program:

<img width="1470" height="956" alt="Pipeline execution waveform trace" src="https://github.com/user-attachments/assets/71ed63f5-43aa-4af3-af36-9b93b30dc765" />

What the trace shows:

- The PC and fetched instruction move forward one at a time (0x00 through 0x14) with no stalls, which makes sense since none of these six instructions create a load-use hazard.
- At the EX stage, the decoded register fields line up exactly with the disassembly. add x10, x8, x9 shows up as rdE = 0a, rs1E = 08, rs2E = 09.
- When add x10, x8, x9 reaches EX, forwardAE turns on. x8 was produced by lw two instructions earlier and hasn't reached the register file yet, so the forwarding path pulls it straight from the pipeline register instead of stalling. This is forwarding doing exactly what it's supposed to, within the limits described above.
- Every instruction that writes a register asserts regwriteM and then regwriteW exactly once, which confirms each result actually lands correctly.

---

## Instruction Set Coverage

| Type | Opcode | funct3 | Instructions |
|---|---|---|---|
| R-Type | 0110011 | varies | add, sub, and, or, slt |
| I-Type (load) | 0000011 | 010 | lw |
| S-Type | 0100011 | 010 | sw |
| B-Type | 1100011 | 000 | beq |

### R-Type: Register to Register

```
31      25 24   20 19   15 14 12 11    7 6      0
+---------+-------+-------+------+-------+--------+
| funct7  | rs2   | rs1   |funct3|  rd   | opcode |
+---------+-------+-------+------+-------+--------+
```

| Instruction | Operation |
|---|---|
| add | rd = rs1 + rs2 |
| sub | rd = rs1 minus rs2 |
| and | rd = rs1 & rs2 |
| or | rd = rs1 \| rs2 |
| slt | rd = (rs1 < rs2) ? 1 : 0 |

**Example:** or x4, x5, x6, so x4 = x5 | x6, which assembles to 0x0062E233

<img width="600" alt="R-type waveform" src="https://github.com/user-attachments/assets/03cf9fb2-c3e6-41d5-875c-3b6dbdda7b50" />

### I-Type: Load

```
31                     20 19   15 14 12 11    7 6      0
+-----------------------+-------+------+-------+--------+
|      immediate        | rs1   |funct3|  rd   | opcode |
+-----------------------+-------+------+-------+--------+
```

rd = Mem[rs1 + immediate]

**Example:** lw x6, -4(x9), so x6 = Mem[x9 - 4], which assembles to 0xFFC4A303

<img width="600" alt="I-type waveform" src="https://github.com/user-attachments/assets/203b4162-d411-43ae-89a6-cad5273f31be" />

### S-Type: Store

```
31      25 24   20 19   15 14 12 11    7 6      0
+---------+-------+-------+------+-------+--------+
|imm[11:5]| rs2   | rs1   |funct3|imm[4:0]|opcode |
+---------+-------+-------+------+-------+--------+
```

Mem[rs1 + immediate] = rs2

**Example:** sw x6, 8(x9), so Mem[x9 + 8] = x6, which assembles to 0x0064A423

<img width="600" alt="S-type waveform" src="https://github.com/user-attachments/assets/8aa03144-7e39-417a-b031-bd4910bbe288" />

### B-Type: Conditional Branch

```
31      30 25 24   20 19   15 14 12 11   8 7     6      0
+--------+-----+-------+-------+------+-----+----+--------+
|imm[12] |10:5 | rs2   | rs1   |funct3|4:1 |11 | opcode |
+--------+-----+-------+-------+------+-----+----+--------+
```

if (rs1 == rs2) PC += offset, else PC += 4

**Example:** beq x2, x3, label

<img width="600" alt="B-type waveform" src="https://github.com/user-attachments/assets/0087680b-a7c4-4864-b19a-b2f68bbcdcd2" />

---

## Running the Simulation

```bash
# Single-cycle
iverilog -o sim_single single_cycle_top.v single_cycle_top_tb.v
vvp sim_single
gtkwave single_cycle.vcd

# Pipelined
iverilog -o sim_pipeline pipeline_top.v pipeline_tb.v
vvp sim_pipeline
gtkwave pipeline.vcd
```

---

## What's Next

Roughly in order of priority:

1. Load-use hazard detection: stall IF/ID and ID/EX for one cycle when an lw is immediately followed by something that depends on it.
2. Branch flush logic: squash the two instructions that get speculatively fetched into IF/ID and ID/EX whenever pcsrcE shows a taken branch.
3. RV32M extension (multiply and divide)
4. A synthesis flow (Yosys or Vivado) with area, timing, and utilization numbers
5. Assertion based or constrained random verification instead of the current directed testbenches
6. FPGA deployment

---

## References

- Digital Design and Computer Architecture: RISC-V Edition, Sarah Harris and David Harris
- The RISC-V Instruction Set Manual, Volume I: Unprivileged ISA
- Computer Organization and Design: RISC-V Edition, Patterson and Hennessy

---

## Author

**Yashvi Doshi**
