# RISC-V Processor in Verilog

A RV32I-subset processor built in two versions: a single-cycle design and a five-stage pipelined design. Both are written in Verilog, simulated with Icarus Verilog, and verified against GTKWave waveforms.

![Verilog](https://img.shields.io/badge/Language-Verilog-blue)
![RISC-V](https://img.shields.io/badge/ISA-RV32I%20(subset)-green)
![Architecture](https://img.shields.io/badge/Architecture-Single--Cycle%20%26%20Pipelined-orange)
![Simulation](https://img.shields.io/badge/Simulation-Icarus%20Verilog-success)
![Waveforms](https://img.shields.io/badge/Waveforms-GTKWave-yellow)

---

## Overview

This repo contains two separate RTL implementations of a RISC-V core, built to compare a simple design against a fast one directly in hardware rather than just on paper.

| | Single-Cycle | Pipelined |
|---|---|---|
| **Execution model** | Each instruction completes fetch through writeback in one clock cycle | Five instructions are in flight at once, across IF, ID, EX, MEM, WB |
| **Clock period** | Bounded by the slowest instruction's full datapath delay | Bounded by the slowest single stage, so it's significantly shorter |
| **Hazards** | None — each instruction fully completes before the next begins | Data hazards are handled with forwarding (see Known Limitations) |
| **Purpose** | Reference design to validate instruction semantics | Demonstrates the structural basis for instruction-level parallelism |

Both versions use a Harvard memory model (separate instruction and data memory) and support the same instruction set: `add`, `sub`, `and`, `or`, `slt`, `lw`, `sw`, `beq`.

---

## Repository Structure

All source files currently sit in a single flat directory. The grouping below reflects how the files relate to each other, not separate folders on disk.

**Single-cycle datapath**
```
single_cycle_top.v        Top-level integration
single_cycle_top_tb.v     Testbench
pc.v                      Program counter
pcadder.v                 PC+4 and branch target adder
instruction_memory.v      Instruction ROM
register_file.v           32 x 32-bit register file (x0-x31)
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
pipeline_top.v             Top-level integration
pipeline_tb.v               Testbench
fetch_cycle.v                IF stage + IF/ID register
decode_cycle.v               ID stage + ID/EX register (control decode, register read)
execute_cycle.v               EX stage + EX/MEM register (ALU, forwarding muxes, branch resolution)
memory_cycle.v                MEM stage + MEM/WB register
writeback_cycle.v             WB stage
hazard_unit.v                 Forwarding logic (EX/MEM and MEM/WB feeding back into EX)
```

**Shared files**
```
memfile.hex                 Sample program loaded into instruction memory
*.vcd                       Waveform dumps
images/                     Datapath diagrams and waveform captures
```

---

## Single-Cycle Processor

Every instruction is fetched, decoded, executed, and written back within a single clock cycle. There is no hazard logic to implement, since each instruction fully completes before the next one starts. The tradeoff is that the clock period must be long enough for the slowest possible instruction — typically `lw`, since it chains the ALU, data memory, and register file in series.

<img width="689" height="398" alt="Single-cycle datapath" src="https://github.com/user-attachments/assets/c809cf91-7b99-4eeb-82f9-2cfacf617f73" />

| Module | File | Function |
|---|---|---|
| Program Counter | `pc.v` | Holds the address of the instruction currently executing |
| PC Adder | `pcadder.v` | Computes PC + 4 |
| Instruction Memory | `instruction_memory.v` | Returns the instruction word at a given address |
| Register File | `register_file.v` | 32 general-purpose 32-bit registers, two read ports, one write port |
| Sign Extension Unit | `sign_extend.v` | Expands instruction immediates to 32 bits based on format type |
| ALU | `alu.v` | Performs add, subtract, AND, OR, and comparison operations |
| Main Decoder | `main_decoder.v` | Generates top-level control signals from the opcode |
| ALU Decoder | `alu_decoder.v` | Derives the specific ALU operation from funct3/funct7 |
| Control Unit | `control_unit_top.v` | Combines the main and ALU decoders |
| Branch Adder | `branch_adder.v` | Computes the branch target address |
| Data Memory | `data_memory.v` | Handles `lw` and `sw` |
| Multiplexers | `mux.v` | Select which signal flows through the datapath at each decision point |

---

## Pipelined Processor

The pipelined design splits execution across five stages, with each stage operating on a different instruction in the same clock cycle:

```
IF -> ID -> EX -> MEM -> WB
```

<img width="716" height="269" alt="Pipeline datapath" src="https://github.com/user-attachments/assets/c9012310-01fd-410a-b4d7-fcca74fe6a7f" />

| Stage | Function |
|---|---|
| IF — Fetch | Reads the next instruction from memory and advances the PC |
| ID — Decode | Decodes the instruction, reads source registers, generates control signals |
| EX — Execute | Runs the ALU operation and resolves the branch target and condition |
| MEM — Memory | Reads or writes data memory for `lw` and `sw` |
| WB — Writeback | Writes the result back to the register file |

Pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB) carry control signals and data values from each stage into the next.

**Files:** `fetch_cycle.v`, `decode_cycle.v`, `execute_cycle.v`, `memory_cycle.v`, `writeback_cycle.v`, `hazard_unit.v`, `mux_3by1.v`

### Data Hazard Resolution

When an instruction needs a register value that an earlier, still-in-flight instruction hasn't written back yet, the design resolves it through forwarding. `hazard_unit.v` compares the destination registers held in the EX/MEM and MEM/WB pipeline stages against the source registers of the instruction currently in EX, and routes the most recent value directly into the ALU inputs via `mux_3by1.v` — bypassing the normal write-then-read order through the register file.

### Known Limitations

Back-to-back ALU, load, and store sequences are handled correctly. Two standard pipeline hazard cases are not yet handled:

- **Load-use hazard.** A value loaded by `lw` isn't available until the end of MEM — one cycle later than EX/MEM forwarding can supply it. There is currently no stall inserted for this case, so an `lw` immediately followed by an instruction that depends on its result can read a stale value. The fix is a hazard detection unit that stalls IF/ID and ID/EX for one cycle.
- **Branch flush.** `beq` resolves in EX (`pcsrcE = branchE & zeroE` in `execute_cycle.v`), by which point two more instructions have already been fetched into IF/ID and ID/EX. The PC redirect itself is correct on a taken branch, but the two in-flight instructions are not squashed, so they incorrectly continue down the pipeline. The fix is flush logic on IF/ID and ID/EX, triggered by `pcsrcE`.

Both are well-characterized pipeline hazards, not unique to this design — noted here for transparency about current scope.

---

## Verification: Traced Program Execution

A passing simulation isn't sufficient evidence that the pipeline computes the correct result, so a six-instruction program was loaded into instruction memory and traced cycle by cycle in GTKWave.

`memfile.hex`, loaded starting at address `0x00000000`:

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
| 0x00 | `00500293` | `addi x5, x0, 5` | x5 = 5 |
| 0x04 | `00300313` | `addi x6, x0, 3` | x6 = 3 |
| 0x08 | `006283B3` | `add  x7, x5, x6` | x7 = 8 |
| 0x0c | `00002403` | `lw   x8, 0(x0)` | x8 = Mem[0] |
| 0x10 | `00100493` | `addi x9, x0, 1` | x9 = 1 |
| 0x14 | `00940533` | `add  x10, x8, x9` | x10 = x8 + x9 |

GTKWave trace of `pipeline_tb` running this program:

<img width="1470" height="956" alt="Pipeline execution waveform trace" src="https://github.com/user-attachments/assets/71ed63f5-43aa-4af3-af36-9b93b30dc765" />

What the trace confirms:

- The PC and fetched instruction advance one at a time (0x00 through 0x14) with no stalls — expected, since none of these six instructions trigger a load-use hazard.
- At the EX stage, the decoded register fields match the disassembly exactly: `add x10, x8, x9` shows `rdE = 0a`, `rs1E = 08`, `rs2E = 09`.
- When `add x10, x8, x9` reaches EX, `forwardAE` asserts. `x8` was produced by `lw` two instructions earlier and hasn't reached the register file yet, so the forwarding path supplies it directly from the pipeline register instead of stalling — forwarding working as intended, within the limits described above.
- Every instruction that writes a register asserts `regwriteM` and then `regwriteW` exactly once, confirming each result is correctly committed.

---

## Instruction Set Coverage

| Type | Opcode | funct3 | Instructions |
|---|---|---|---|
| R-Type | `0110011` | varies | `add`, `sub`, `and`, `or`, `slt` |
| I-Type (load) | `0000011` | `010` | `lw` |
| S-Type | `0100011` | `010` | `sw` |
| B-Type | `1100011` | `000` | `beq` |

### R-Type: Register to Register

```
31      25 24   20 19   15 14 12 11    7 6      0
+---------+-------+-------+------+-------+--------+
| funct7  | rs2   | rs1   |funct3|  rd   | opcode |
+---------+-------+-------+------+-------+--------+
```

| Instruction | Operation |
|---|---|
| `add` | rd = rs1 + rs2 |
| `sub` | rd = rs1 − rs2 |
| `and` | rd = rs1 & rs2 |
| `or`  | rd = rs1 \| rs2 |
| `slt` | rd = (rs1 < rs2) ? 1 : 0 |

**Example:** `or x4, x5, x6` → x4 = x5 \| x6 → assembles to `0x0062E233`

<img width="600" alt="R-type waveform" src="https://github.com/user-attachments/assets/03cf9fb2-c3e6-41d5-875c-3b6dbdda7b50" />

### I-Type: Load

```
31                     20 19   15 14 12 11    7 6      0
+-----------------------+-------+------+-------+--------+
|      immediate        | rs1   |funct3|  rd   | opcode |
+-----------------------+-------+------+-------+--------+
```

rd = Mem[rs1 + immediate]

**Example:** `lw x6, -4(x9)` → x6 = Mem[x9 − 4] → assembles to `0xFFC4A303`

<img width="600" alt="I-type waveform" src="https://github.com/user-attachments/assets/203b4162-d411-43ae-89a6-cad5273f31be" />

### S-Type: Store

```
31      25 24   20 19   15 14 12 11    7 6      0
+---------+-------+-------+------+-------+--------+
|imm[11:5]| rs2   | rs1   |funct3|imm[4:0]|opcode |
+---------+-------+-------+------+-------+--------+
```

Mem[rs1 + immediate] = rs2

**Example:** `sw x6, 8(x9)` → Mem[x9 + 8] = x6 → assembles to `0x0064A423`

<img width="600" alt="S-type waveform" src="https://github.com/user-attachments/assets/8aa03144-7e39-417a-b031-bd4910bbe288" />

### B-Type: Conditional Branch

```
31      30 25 24   20 19   15 14 12 11   8 7     6      0
+--------+-----+-------+-------+------+-----+----+--------+
|imm[12] |10:5 | rs2   | rs1   |funct3|4:1 |11 | opcode |
+--------+-----+-------+-------+------+-----+----+--------+
```

if (rs1 == rs2) PC += offset; else PC += 4

**Example:** `beq x2, x3, label`

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

In rough priority order:

1. **Load-use hazard detection** — stall IF/ID and ID/EX for one cycle when an `lw` is immediately followed by a dependent instruction.
2. **Branch flush logic** — squash the two speculatively-fetched instructions in IF/ID and ID/EX whenever `pcsrcE` indicates a taken branch.
3. **RV32M extension** (multiply / divide).
4. **Synthesis flow** (Yosys or Vivado) with area, timing, and utilization results.
5. **Assertion-based or constrained-random verification** in place of the current directed testbenches.
6. **FPGA deployment.**

---

## References

- *Digital Design and Computer Architecture: RISC-V Edition* — Sarah Harris and David Harris
- *The RISC-V Instruction Set Manual, Volume I: Unprivileged ISA*
- *Computer Organization and Design: RISC-V Edition* — Patterson and Hennessy

---

## Author

**Yashvi Doshi**
