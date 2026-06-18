# 🚀 RISC-V Processor in Verilog

A from-scratch implementation of the **RISC-V RV32I Instruction Set Architecture** in **Verilog HDL**, featuring both a **Single-Cycle** and a **Five-Stage Pipelined** processor — built to explore datapath design, control logic, hazard handling, and hardware verification.

![Verilog](https://img.shields.io/badge/Language-Verilog-blue)
![RISC-V](https://img.shields.io/badge/ISA-RV32I-green)
![Architecture](https://img.shields.io/badge/Architecture-Single--Cycle%20%26%20Pipelined-orange)
![RTL Design](https://img.shields.io/badge/RTL-Design-red)
![Simulation](https://img.shields.io/badge/Simulation-Icarus%20Verilog-success)
![Waveforms](https://img.shields.io/badge/Waveforms-GTKWave-yellow)
![Platform](https://img.shields.io/badge/Platform-Ubuntu%20%7C%20macOS-lightgrey)

---

## 📖 Overview

| | Single-Cycle | Five-Stage Pipelined |
|---|---|---|
| **Throughput** | 1 instruction per cycle, but cycle time = slowest instruction | ~1 instruction/cycle once the pipeline is full |
| **Datapath** | All stages collapsed into one clock cycle | IF → ID → EX → MEM → WB, overlapped |
| **Hazards** | None — no overlap to manage | Resolved via forwarding + stalling |
| **Best for** | Understanding the baseline datapath | Realistic, higher-throughput design |

Both designs use a **Harvard architecture** (separate instruction and data memories) and are verified with **Icarus Verilog** simulation + **GTKWave** waveform analysis.

**Instructions implemented:** `add` `sub` `and` `or` `slt` (R-type) · `lw` (I-type) · `sw` (S-type) · `beq` (B-type)

---

## 📂 Repository Structure

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

## 🔹 Single-Cycle Architecture

Every instruction is fetched, decoded, executed, and written back within a single clock cycle — so the clock period must accommodate the slowest instruction in the ISA.

<img width="689" height="398" alt="Single-cycle datapath" src="https://github.com/user-attachments/assets/c809cf91-7b99-4eeb-82f9-2cfacf617f73" />

| Module | File | Role |
|---|---|---|
| Program Counter | `pc.v` | Holds and updates the current instruction address |
| PC Adder | `pcadder.v` | Computes PC + 4 |
| Instruction Memory | `instruction_memory.v` | Returns the instruction stored at the current PC |
| Register File | `register_file.v` | 32 × 32-bit registers (x0–x31): 2 combinational read ports, 1 synchronous write port |
| Sign Extension Unit | `sign_extend.v` | Generates 32-bit signed immediates for I/S/B-type instructions |
| ALU | `alu.v` | ADD, SUB, AND, OR, SLT — outputs result and zero flag |
| Main Decoder | `main_decoder.v` | Decodes opcode into RegWrite, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp |
| ALU Decoder | `alu_decoder.v` | Combines ALUOp, funct3, funct7 into the ALU control signal |
| Control Unit | `control_unit_top.v` | Wraps the Main and ALU decoders |
| Branch Adder | `branch_adder.v` | Computes PC + immediate for branch targets |
| Data Memory | `data_memory.v` | Services `lw` / `sw` memory access |
| Multiplexers | `mux.v` | Select ALU operands, writeback source, and next PC |

---

## ⚡ Five-Stage Pipelined Architecture

Instruction execution is split into five overlapping stages so multiple instructions are in flight at once:

```text
IF → ID → EX → MEM → WB
```

<img width="716" height="269" alt="Pipeline datapath" src="https://github.com/user-attachments/assets/c9012310-01fd-410a-b4d7-fcca74fe6a7f" />

**Stages**

| Stage | Responsibilities | Outputs |
|---|---|---|
| **IF** — Fetch | Fetch instruction, increment PC | Instruction, PC, PC+4 |
| **ID** — Decode | Decode fields, read registers, generate immediate & control signals | RD1, RD2, Immediate, Control signals |
| **EX** — Execute | ALU operation, address/branch target calculation | ALU result, Zero flag, Branch target |
| **MEM** — Memory | Read/write data memory | Memory data, ALU result |
| **WB** — Writeback | Write the selected result into the register file | — |

**Pipeline Registers**

| Register | Stores |
|---|---|
| IF/ID | Instruction, PC, PC+4 |
| ID/EX | Operands, immediate, destination register, control signals |
| EX/MEM | ALU result, memory write data, destination register, memory control signals |
| MEM/WB | Memory read data, ALU result, destination register, writeback control signals |

**Files:** `fetch_cycle.v` · `decode_cycle.v` · `execute_cycle.v` · `memory_cycle.v` · `writeback_cycle.v` · `forwarding_unit.v` · `hazard_unit.v`

### Hazard Handling

- **Data hazards** — `add x5,x1,x2` followed by `sub x6,x5,x3` needs x5 before ADD finishes writing back. The **forwarding unit** routes results straight from the EX/MEM and MEM/WB registers into EX, eliminating the stall in most cases.
- **Load-use hazards** — a load's value isn't ready until MEM, so `lw x5,0(x1)` followed by `add x6,x5,x2` can't be fixed by forwarding alone. The **hazard detection unit** catches this and inserts one stall cycle.
- **Branch hazards** — the next PC is unknown until a branch resolves in EX; a misprediction means flushing whatever was already fetched behind it.

### Pipeline Overlap in Action

```text
              Cycle →   1    2    3    4    5    6    7    8
lw  x1, 0(x0)           IF   ID   EX   MEM  WB
lw  x2, 4(x0)                IF   ID   EX   MEM  WB
or  x3, x1, x2                    IF   ID   EX   MEM  WB
sw  x3, 8(x0)                          IF   ID   EX   MEM
```

Four instructions finish in 8 cycles instead of the 20 cycles a single-cycle design would need — the throughput gain that justifies the added hazard logic.

---

## 📚 Instruction Set

| Type | Opcode | funct3 | funct7 | Instructions |
|---|---|---|---|---|
| R-Type | `0110011` | varies | varies | `add` `sub` `and` `or` `slt` |
| I-Type | `0000011` | `010` | – | `lw` |
| S-Type | `0100011` | `010` | – | `sw` |
| B-Type | `1100011` | `000` | – | `beq` |

### R-Type — Register-to-Register

```text
31      25 24   20 19   15 14 12 11    7 6      0
+---------+-------+-------+------+-------+--------+
| funct7  | rs2   | rs1   |funct3|  rd   | opcode |
+---------+-------+-------+------+-------+--------+
```

| Instruction | Operation |
|---|---|
| add | rd = rs1 + rs2 |
| sub | rd = rs1 − rs2 |
| and | rd = rs1 & rs2 |
| or | rd = rs1 \| rs2 |
| slt | rd = (rs1 < rs2) ? 1 : 0 |

**Example:** `or x4, x5, x6` → `x4 = x5 | x6` → machine code `0x0062E233`

<img width="600" alt="R-type waveform" src="https://github.com/user-attachments/assets/03cf9fb2-c3e6-41d5-875c-3b6dbdda7b50" />

### I-Type — Load

```text
31                     20 19   15 14 12 11    7 6      0
+-----------------------+-------+------+-------+--------+
|      immediate        | rs1   |funct3|  rd   | opcode |
+-----------------------+-------+------+-------+--------+
```

`rd = Mem[rs1 + immediate]`

**Example:** `lw x6, -4(x9)` → `x6 = Mem[x9 - 4]` → machine code `0xFFC4A303`

<img width="600" alt="I-type waveform" src="https://github.com/user-attachments/assets/203b4162-d411-43ae-89a6-cad5273f31be" />

### S-Type — Store

```text
31      25 24   20 19   15 14 12 11    7 6      0
+---------+-------+-------+------+-------+--------+
|imm[11:5]| rs2   | rs1   |funct3|imm[4:0]|opcode |
+---------+-------+-------+------+-------+--------+
```

`Mem[rs1 + immediate] = rs2`

**Example:** `sw x6, 8(x9)` → `Mem[x9 + 8] = x6` → machine code `0x0064A423`

<img width="600" alt="S-type waveform" src="https://github.com/user-attachments/assets/8aa03144-7e39-417a-b031-bd4910bbe288" />

### B-Type — Conditional Branch

```text
31      30 25 24   20 19   15 14 12 11   8 7     6      0
+--------+-----+-------+-------+------+-----+----+--------+
|imm[12] |10:5 | rs2   | rs1   |funct3|4:1 |11 | opcode |
+--------+-----+-------+-------+------+-----+----+--------+
```

`if (rs1 == rs2) PC += offset; else PC += 4`

**Example:** `beq x2, x3, label`

<img width="600" alt="B-type waveform" src="https://github.com/user-attachments/assets/0087680b-a7c4-4864-b19a-b2f68bbcdcd2" />

---

## 🔭 Future Improvements

- Branch prediction & pipeline flushing logic
- Cache memory
- Dynamic hazard resolution / out-of-order execution
- Superscalar architecture
- RV32M extension
- FPGA implementation

---

## 📚 References

- *Digital Design and Computer Architecture: RISC-V Edition* — Sarah Harris & David Harris
- RISC-V ISA Manual
- *Computer Organization and Design* — Patterson & Hennessy
- RISC-V Foundation Documentation

---

## ✍️ Author

**Yashvi Doshi**
