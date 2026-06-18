# 🚀 RISC-V Processor in Verilog

I built a working CPU — one that actually reads and runs RISC-V instructions — in two versions: a **simple, one-step-at-a-time design** and a **fast, five-stage pipelined design**. Both are written in Verilog, simulated with Icarus Verilog, and verified waveform-by-waveform in GTKWave.

![Verilog](https://img.shields.io/badge/Language-Verilog-blue)
![RISC-V](https://img.shields.io/badge/ISA-RV32I-green)
![Architecture](https://img.shields.io/badge/Architecture-Single--Cycle%20%26%20Pipelined-orange)
![RTL Design](https://img.shields.io/badge/RTL-Design-red)
![Simulation](https://img.shields.io/badge/Simulation-Icarus%20Verilog-success)
![Waveforms](https://img.shields.io/badge/Waveforms-GTKWave-yellow)
![Platform](https://img.shields.io/badge/Platform-Ubuntu%20%7C%20macOS-lightgrey)

---

## 📖 What's Inside

Think of a CPU as a tiny factory: instructions come in ("add these two numbers," "load this value"), and results come out. This project builds that factory two different ways.

| | 🐢 Single-Cycle | ⚡ Pipelined |
|---|---|---|
| **How it runs instructions** | Finishes one instruction completely before starting the next | Works on multiple instructions at once, like an assembly line |
| **Speed** | One instruction per (long) clock cycle | Close to one instruction per (much shorter) clock cycle |
| **Complexity** | Simple — easy to follow and debug | Needs extra logic so instructions don't trip over each other |
| **What it's good for** | Learning how a CPU works, step by step | Seeing how real-world CPUs actually get fast |

Both versions keep instructions and data in separate memories — a setup called a **Harvard architecture** — and both support the same eight instructions: `add` `sub` `and` `or` `slt` `lw` `sw` `beq`.

---

## 📂 How the Code Is Organized

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

## 🔹 Single-Cycle Processor: The Simple Version

Picture reading one full instruction, doing everything it asks for, and only then moving to the next. That's the single-cycle design: fetch, decode, execute, access memory, and write back the result — all within one clock tick. Because everything has to fit in that one tick, the clock has to run slow enough for even the most complicated instruction to finish.

<img width="689" height="398" alt="Single-cycle datapath" src="https://github.com/user-attachments/assets/c809cf91-7b99-4eeb-82f9-2cfacf617f73" />

| Module | File | What it does |
|---|---|---|
| Program Counter | `pc.v` | Keeps track of the address of the instruction currently running |
| PC Adder | `pcadder.v` | Works out the next instruction's address (current address + 4) |
| Instruction Memory | `instruction_memory.v` | Looks up the instruction stored at a given address |
| Register File | `register_file.v` | The CPU's 32 scratchpad slots (x0–x31) for holding values |
| Sign Extension Unit | `sign_extend.v` | Turns the short immediate values packed into an instruction into full 32-bit numbers |
| ALU | `alu.v` | Does the actual math and logic — add, subtract, AND, OR, compare |
| Main Decoder | `main_decoder.v` | Reads the opcode and decides what the rest of the CPU should do |
| ALU Decoder | `alu_decoder.v` | Figures out exactly which ALU operation to run |
| Control Unit | `control_unit_top.v` | Combines the two decoders above into one control hub |
| Branch Adder | `branch_adder.v` | Works out where to jump to for branch instructions |
| Data Memory | `data_memory.v` | Handles reading and writing data for `lw` and `sw` |
| Multiplexers | `mux.v` | Pick which signal flows through the datapath at each decision point |

---

## ⚡ Pipelined Processor: The Fast Version

Now imagine an assembly line instead of one person doing every step alone. While one instruction is being decoded, the next is already being fetched, and the one before that is already running through the ALU. That's pipelining — five stages, each working on a different instruction, all at the same time.

```text
IF → ID → EX → MEM → WB
```

<img width="716" height="269" alt="Pipeline datapath" src="https://github.com/user-attachments/assets/c9012310-01fd-410a-b4d7-fcca74fe6a7f" />

**The five stages, in plain terms**

| Stage | What it does |
|---|---|
| **IF** — Fetch | Grabs the next instruction and moves the program counter forward |
| **ID** — Decode | Figures out what the instruction wants and reads the registers it needs |
| **EX** — Execute | Does the math, or works out a memory/branch address |
| **MEM** — Memory | Reads from or writes to data memory, if the instruction needs it |
| **WB** — Writeback | Saves the result back into the register file |

A small register sits between every pair of stages, holding everything the next stage will need: instruction details, computed values, control signals. These are the **IF/ID**, **ID/EX**, **EX/MEM**, and **MEM/WB** registers.

**Files:** `fetch_cycle.v` · `decode_cycle.v` · `execute_cycle.v` · `memory_cycle.v` · `writeback_cycle.v` · `forwarding_unit.v` · `hazard_unit.v`

### When Instructions Get in Each Other's Way

Running five instructions at once works great — until one of them needs a result that another hasn't produced yet. This design handles three of those situations:

- **"I need that number, but it's not ready yet."** One instruction computes a value, and the very next instruction needs it immediately. Instead of waiting, the **forwarding unit** grabs the result straight from a later stage and feeds it in early.
- **"I need it, but it's still coming from memory."** A value loaded from memory isn't ready until the MEM stage, so forwarding alone can't save it. The **hazard detection unit** spots this and pauses the pipeline for exactly one cycle.
- **"I don't know where to go next."** Until a branch instruction is fully resolved, the CPU doesn't know whether to keep going straight or jump elsewhere. Guess wrong, and it has to throw away (flush) whatever it already started fetching.

### Seeing the Speedup

```text
              Cycle →   1    2    3    4    5    6    7    8
lw  x1, 0(x0)           IF   ID   EX   MEM  WB
lw  x2, 4(x0)                IF   ID   EX   MEM  WB
or  x3, x1, x2                    IF   ID   EX   MEM  WB
sw  x3, 8(x0)                          IF   ID   EX   MEM
```

These four instructions finish in 8 cycles here, instead of the 20 cycles a single-cycle design would need for the same four — that's the whole point of pipelining.

---

## 🧪 Proof It Works: A Real Program, Traced Step by Step

Designing a pipeline on paper is one thing. Proving it actually runs a program correctly is another. Here's a tiny six-instruction program, loaded straight into the processor, with the GTKWave trace to back it up.

`memfile.hex`, loaded into instruction memory starting at address `0x00000000`:

```text
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
| 0x00 | `00500293` | `addi x5, x0, 5` | x5 = 5 |
| 0x04 | `00300313` | `addi x6, x0, 3` | x6 = 3 |
| 0x08 | `006283B3` | `add  x7, x5, x6` | x7 = 8 |
| 0x0c | `00002403` | `lw   x8, 0(x0)` | x8 = Mem[0] |
| 0x10 | `00100493` | `addi x9, x0, 1` | x9 = 1 |
| 0x14 | `00940533` | `add  x10, x8, x9` | x10 = x8 + x9 |

GTKWave trace of `pipeline_tb` running this program:

<img width="1470" height="956" alt="Pipeline execution waveform trace" src="https://github.com/user-attachments/assets/71ed63f5-43aa-4af3-af36-9b93b30dc765" />

What this trace proves:

- The program counter and fetched instruction step forward one at a time (`0x00 → 0x14`) with zero stalls, since none of these six instructions create a load-use hazard.
- At the EX stage, the register numbers in the hardware match exactly what we'd expect — e.g. `add x10, x8, x9` shows up as `rdE=0a`, `rs1E=08`, `rs2E=09`.
- Right when `add x10, x8, x9` reaches EX, `forwardAE` switches on. That's the forwarding unit stepping in: `x8` was written two instructions earlier by `lw` and hasn't reached the register file yet, so its value gets routed in directly instead of stalling the pipeline.
- Every instruction that writes to a register lights up `regwriteM` and then `regwriteW` exactly once, confirming all five results land correctly.

---

## 📚 Instructions It Understands

| Type | Opcode | funct3 | funct7 | Instructions |
|---|---|---|---|---|
| R-Type | `0110011` | varies | varies | `add` `sub` `and` `or` `slt` |
| I-Type | `0000011` | `010` | – | `lw` |
| S-Type | `0100011` | `010` | – | `sw` |
| B-Type | `1100011` | `000` | – | `beq` |

Here's how each type is laid out in memory, bit by bit:

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

## 🔭 What's Next

Ideas for taking this further:

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
