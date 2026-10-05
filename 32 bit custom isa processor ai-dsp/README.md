# 32-bit Custom RISC-V Processor with AI/DSP Extensions — ISA, Microarchitecture & PPA Analysis

## Overview

This repository documents the synthesis, timing and activity-based power analysis of a custom 32-bit RISC-V-style processor implemented in Verilog RTL.

The processor contains a custom ISA, multi-port register file, enhanced ALU, immediate generation, branch/jump control, instruction/data memories, and selected power-aware enable/isolation mechanisms.

The design was synthesized using the **NangateOpenCellLibrary 45 nm standard-cell library**.

> The power-aware results are specific to this RTL, synthesis flow and VCD workload. Enable/isolation logic is a PPA tradeoff, not a guarantee of improvement for every block.

---

## Headline Results

| Metric | Baseline | Power-Aware / Enable | Change |
|---|---:|---:|---:|
| **Area** | 31,692.038 µm² | **33,253.458 µm²** | **+4.93%** |
| Sequential area | 10,078.208 µm² | 10,078.208 µm² | 0% |
| Sequential area share | 31.80% | 30.31% | — |
| Worst data-path delay | 8.260 ns | **8.416 ns** | +1.89% |
| Setup slack @ 10 ns | 1.596 ns | **1.441 ns** | −0.155 ns |
| Minimum-delay slack | 0.014 ns | **0.015 ns** | +0.001 ns |
| Internal power | 1.05 mW | **0.844 mW** | **−19.62%** |
| Switching power | 0.678 mW | **0.496 mW** | **−26.84%** |
| Leakage power | 0.637 mW | **0.661 mW** | +3.77% |
| **Total power** | **2.37 mW** | **2.00 mW** | **−15.61%** |

### Maximum frequency estimate

Using `Fmax ≈ 1 / critical-path delay`:

- **Baseline critical-path-only estimate:** 1 / 8.260 ns ≈ **121.1 MHz**
- **Power-aware timing including 0.10 ns clock uncertainty and 0.044 ns setup time:** minimum period ≈ 8.560 ns, giving **≈116.8 MHz**

Both implementations meet the **100 MHz / 10 ns** timing target.

---

# Key Result

The processor-level isolation strategy achieved:

> **15.61% total power reduction with 4.93% area overhead while maintaining timing closure at 100 MHz.**

The sequential area is unchanged. The additional area comes from added combinational control/isolation logic.

---

# Processor Architecture

Major blocks:

- Program Counter
- Instruction Memory
- Main Decoder
- Register File
- Immediate Generator
- ALU
- ALU Control
- Operand MUX
- Branch Unit
- PC Control
- Data Memory
- Result MUX

The processor is a **32-bit single-cycle custom RISC-V-style processor** with multiple custom instruction formats and custom ALU operations.

---

# Custom ISA

The original ISA sheets are included in `isa_sheets/`.

## R4 Type

Opcode: `00001`

Format:

`FUNC | RS3 | RS2 | RS1 | RD | OPCODE`

Supports three source registers and one destination register, including ADD, SUB, OR, AND, NAND, NOR, XOR, XNOR, XOR_AND, NOT_AND_XOR, NOT_OR_AND, AND_NOT2, INC, DEC, MAX, MIN, MAC and MSC.

## R3 Type

Opcode: `00010`

Format:

`FUNC | RS2 | RS1 | RD | OPCODE`

Supports arithmetic, logical, comparison, shift, multiply and selected custom/vector operations including ADD, SUB, OR, AND, NAND, NOR, XOR, XNOR, AND_NOT, OR_NOT, INC, DEC, SLL, SLT, SRL, SRA, SGT, MAX, MIN, MUL, VADD8, VMAX8 and SDOTP4.

## R3I Type

Opcode: `00011`

Format:

`FUNC | IMM | RS2 | RS1 | RD | OPCODE`

Uses a 5-bit immediate and supports operations including ADD, SUB, OR, AND, NAND, NOR, XOR, XNOR, NOT_AND_XOR, NOT_OR_AND, AND_NOT2, INC, DEC, MAX, MIN, MAC and MSC.

## I Type

Opcode: `00100`

Format:

`FUNC | IMM[11:0] | RS1 | RD | OPCODE`

Defined immediate operations include ADDI, SUBI, ORI, ANDI, XORI, SLLI, SRLI and SRAI.

## Load Word

Opcode: `00111`

Uses a 12-bit immediate with RS1 as the base register and RD as the destination.

## Store Word

Opcode: `00101`

Uses a split 12-bit immediate with RS2 as store data and RS1 as the base register.

## Branch Type

Opcode: `00110`

Supports:

- BEQ
- BNEQ
- BGT
- BLT
- BGST
- BLST
- BLTZ
- BGTZ
- BGEZ
- BLEZ
- BEQZ
- BNEZ

Both two-register and single-register comparisons are supported.

## R2 Type

Opcode: `01011`

Includes NEG, ABS, NOT, INC, DEC and VRELU8.

## R4 MOV Type

Opcode: `01000`

Uses RS1, RS2, RD1 and RD2 fields for multi-register move functionality.

## R2 MOV Type

Opcode: `01010`

Uses RS1 and RD; the supplied ISA sheet specifies that the immediate is not required.

---

# Architecture Details

The processor follows the organization:

```text
PC → Instruction Memory → Decoder / Register File / Immediate Logic
  → ALU / Memory / Control → Writeback / Next PC
```

The register file contains **32 registers × 32 bits**, with **3 asynchronous read ports** and **2 synchronous write ports**. Register x0 is held at zero, and write-port-1 has priority when simultaneous writes target the same destination. The three read ports support the processor's multi-source instruction formats.

The ALU datapath is organized according to operation type:

- R4: A, B, C
- R3: A, B
- R2: A
- I/load/store: A and C

The PC-control logic supports sequential `PC + 4`, conditional branches, JAL, JALR and link generation from `PC + 4`.

The power-aware architecture selectively isolates inputs to the ALU, branch comparator, immediate generator, ALU operand MUX, result MUX and PC control.

# Combinational Activity Isolation Architecture

The power-aware version adds enable/isolation mechanisms to selected datapath blocks, including:

- ALU
- Immediate generator
- Register file controls
- Operand routing
- Result MUX
- Program Counter
- Instruction-memory read control
- Other datapath controls

The **main decoder intentionally has no additional enable**. It is required to decode every instruction and generate the control signals required by the rest of the processor.

This is an architectural choice: disabling the decoder would prevent the processor from generating the controls needed for the next operation.

---

# Block-Level Power Demonstrations

The processor-level result is supported by earlier block-level experiments.

| Block | Baseline | Power-Aware / Enable | Observation |
|---|---:|---:|---|
| **ALU** | 9.02 mW | **5.50 mW** | ~39.0% lower total power |
| **Immediate Generator** | 36.3 µW | **25.5 µW** | ~29.8% lower |
| **Result MUX** | 8.57 µW | **7.15 µW** | ~16.6% lower |
| **Instruction Memory** | 21.2 µW | **20.5 µW** | ~3.3% lower |
| **Program Counter** | 26.7 µW | **27.2 µW** | Workload showed a small increase |
| **Main Decoder** | — | **4.93 µW** | No enable; always required |

### ALU

The ALU demonstrated the strongest block-level reduction: 9.02 mW to 5.50 mW, with approximately 2.5% area overhead. The experiment used ALU enable, operand isolation and control isolation.

### Immediate Generator

`ImmEnable` reduced measured total power from 36.3 µW to 25.5 µW.

### Result MUX

The enable version reduced measured total power from 8.57 µW to 7.15 µW. The smaller mapped implementation observed in this Nangate flow should not be interpreted as a universal consequence of adding an enable.

### Instruction Memory

The tested read-enable version reduced power from 21.2 µW to 20.5 µW.

### Program Counter

The enable version measured 27.2 µW versus 26.7 µW for baseline. This demonstrates that isolation/enable logic can itself consume power and that the result depends on workload and synthesis mapping.

### Main Decoder

The decoder was kept normal without an enable because it is required on every instruction. Its measured total power was 4.93 µW.

---


# Block-Level Combinational Power Reduction

The processor-level power reduction is not presented as a single unexplained number. It is supported by separate gate-level PPA/power experiments performed on the major power-aware combinational blocks.

The strongest reductions were observed in the **ALU, Branch Unit, ALU Control and Immediate Generator**. These blocks were independently synthesized and evaluated with VCD activity using the Nangate 45 nm standard-cell library.

## Block-Level Power Comparison

| Unit | Baseline / Without Isolation | Power-Aware / With Isolation | Total Power Change | Main Observation |
|---|---:|---:|---:|---|
| **ALU** | 9.02 mW | **5.50 mW** | **−39.02%** | Major reduction in arithmetic/AI datapath activity |
| **ALU Control** | 65.7 µW | **43.8 µW** | **−33.3%** | Strong control-path dynamic-power reduction |
| **Branch Unit** | 138 µW | **84.8 µW** | **−38.55%** | Operand isolation strongly reduces comparator activity |
| **Immediate Generator (`immext`)** | 36.3 µW | **25.5 µW** | **−29.8%** | Input/control isolation reduces unnecessary immediate-generation activity |
| **Result MUX** | 8.57 µW | **7.15 µW** | **−16.57%** | Enable suppresses unnecessary result-routing activity |
| **Instruction Memory** | 21.2 µW | **20.5 µW** | **−3.30%** | Small benefit from read-enable |
| **Program Counter** | 26.7 µW | 27.2 µW | **+1.87%** | Enable overhead exceeded savings for this workload |
| **Main Decoder** | — | 4.93 µW | No comparison | No enable intentionally used |

> **Important:** These block-level experiments use their own workloads and constraints. Their percentages must not be added together to predict processor-level savings. The processor result is measured separately using the same mixed workload for both top-level implementations.

## 1. ALU — Largest Power Consumer and Major Saving

The ALU is the most important power-aware datapath block because it contains the processor's arithmetic, logical and custom AI/DSP operations.

The final processor comparison uses:

| Metric | Baseline | Power-Aware |
|---|---:|---:|
| Internal power | 4.57 mW | **2.50 mW** |
| Switching power | 4.21 mW | **2.75 mW** |
| Leakage power | 0.238 mW | 0.252 mW |
| **Total power** | **9.02 mW** | **5.50 mW** |
| Area | 10,213.602 µm² | 10,468.696 µm² |

Measured improvements:

- **39.02% lower total power**
- **34.68% lower switching power**
- **45.30% lower internal power**
- **2.50% area overhead**

The ALU uses global enable plus per-operand isolation (`alu_enA`, `alu_enB`, `alu_enC`) and control isolation. This is particularly useful because the ALU supports many operations and can otherwise experience internal transitions even when a particular operand or operation is not required.

## 2. ALU Control — Strong Control-Path Saving

The ALU Control experiment independently demonstrated that isolation is useful even before the signal reaches the ALU.

| Metric | Without Isolation | With Isolation |
|---|---:|---:|
| Internal power | 28.2 µW | **20.4 µW** |
| Switching power | 34.7 µW | **20.1 µW** |
| Leakage power | 2.79 µW | 3.33 µW |
| **Total power** | **65.7 µW** | **43.8 µW** |
| Area | 126.616 µm² | 146.832 µm² |

Measured improvements:

- **42.1% lower switching power**
- **33.3% lower total power**
- **27.7% lower internal power**
- **15.97% area overhead**
- Leakage increased by **19.4%**

This is important because the ALU Control block generates operation/mode and operand-enable controls for a large downstream datapath. Reducing unnecessary control transitions can therefore prevent activity from propagating into larger blocks.

## 3. Branch Unit — Strong Dynamic-Power Reduction

The Branch Unit uses operand isolation according to the active branch condition.

| Metric | Baseline | Power-Aware |
|---|---:|---:|
| Internal power | 74.1 µW | **44.1 µW** |
| Switching power | 59.3 µW | **35.1 µW** |
| Leakage power | 4.53 µW | 5.65 µW |
| **Total power** | **138 µW** | **84.8 µW** |
| Area | 196.840 µm² | 248.444 µm² |

Measured improvements:

- **40.81% lower switching power**
- **38.55% lower total power**
- **40.49% lower internal power**
- **26.22% area overhead**
- Leakage increased by **24.72%**

The important point is that the Branch Unit is small compared with the ALU, but its relative dynamic-power reduction is excellent. It shows that selective operand isolation is useful for comparison logic as well as arithmetic logic.

## 4. Immediate Generator (`immext`) — Significant Saving with Low Area Impact

The immediate generator supports several instruction formats, including I, S, B, J, R3I and JALR forms.

| Metric | Without Isolation | With Isolation |
|---|---:|---:|
| Internal power | 12.3 µW | **9.03 µW** |
| Switching power | 20.9 µW | **13.8 µW** |
| Leakage power | 3.09 µW | **2.65 µW** |
| **Total power** | **36.3 µW** | **25.5 µW** |
| Area | 127.946 µm² | **111.188 µm²** |
| Cells | 117 | **91** |

Measured improvements:

- **29.8% lower total power**
- **33.9% lower switching power**
- **26.6% lower internal power**
- **13.1% lower synthesized area**
- Worst-path delay increased by approximately **0.13 ns**

This result is particularly useful because the isolation version synthesized smaller in this specific Nangate/Yosys implementation. That is a result of synthesis restructuring and must not be interpreted as a universal rule that adding an enable reduces area.

---

# Sources of Processor Combinational Power Reduction

The top-level result is best understood as the combined effect of these independently demonstrated block-level optimizations.

### Strongest individual power-saving blocks

1. **ALU** — 39.02% lower total power
2. **Branch Unit** — 38.55% lower total power
3. **ALU Control** — 33.3% lower total power
4. **Immediate Generator** — 29.8% lower total power

These are the blocks where the isolation strategy produced the clearest dynamic-power benefit.

The processor-level experiment then confirms that these techniques remain useful when integrated into the complete datapath:

```text
Baseline processor
       │
       │ 2.37 mW
       ▼
Power-aware processor
       │
       │ 2.00 mW
       ▼
15.61% lower total power
26.84% lower switching power
20.69% lower combinational power
```

The most important processor-level observation is therefore **not merely lower total power**. The stronger evidence is the reduction in the **combinational portion of power**, because the optimization targets combinational activity.

### Combinational power

```text
1.74 mW  →  1.38 mW
```

This is a:

> **20.69% reduction in total combinational power**

Within the combinational group:

- Internal power: **0.605 → 0.397 mW**, **34.38% reduction**
- Switching power: **0.671 → 0.488 mW**, **27.27% reduction**

The overall switching-power result is:

```text
0.678 mW → 0.496 mW
```

or:

> **26.84% lower total switching power**

This is the central evidence that the operand/control-isolation strategy is actually suppressing unnecessary activity in the integrated processor.

---

# Isolation Logic Overhead and Trade-offs

The power-aware design does not reduce every power component.

The added isolation and enable logic introduces overhead in some blocks:

### Leakage overhead

Several isolated blocks show higher leakage because additional standard-cell logic is present:

- ALU: **0.238 → 0.252 mW**
- ALU Control: **2.79 → 3.33 µW**
- Branch Unit: **4.53 → 5.65 µW**

At processor level:

```text
Leakage:
0.637 mW → 0.661 mW
```

This is a **3.77% increase**.

### Program Counter example

The Program Counter is a useful example of why low-power RTL cannot be judged only by whether an enable exists:

```text
Baseline:      26.7 µW
With enable:   27.2 µW
```

The measured result was a **1.87% increase in total power** for that workload. The additional MUX/control logic consumed enough power to offset the expected hold-related savings.

This is why the processor README presents the optimization as a **measured PPA trade-off**, rather than claiming that every enabled block automatically saves power.

### Main Decoder

The Main Decoder was intentionally **not given an enable**.

The decoder must remain available to decode the instruction and generate the controls required by the processor. Its measured standalone power was **4.93 µW**.

This is an architectural decision, not a missing optimization.

---

# Why Combinational Power Reduction Matters

A large portion of the processor's power-aware benefit comes from **combinational logic**, exactly where the RTL isolation was applied.

The top-level comparison shows:

| Power Metric | Baseline | Power-Aware | Change |
|---|---:|---:|---:|
| **Combinational power** | **1.74 mW** | **1.38 mW** | **−20.69%** |
| Combinational internal | 0.605 mW | 0.397 mW | **−34.38%** |
| Combinational switching | 0.671 mW | 0.488 mW | **−27.27%** |
| Sequential power | 0.624 mW | 0.625 mW | approximately unchanged |
| **Total power** | **2.37 mW** | **2.00 mW** | **−15.61%** |

This makes the architecture's low-power contribution clearer:

> **The optimization primarily reduces activity in the combinational datapath rather than relying on sequential clock/power reduction.**

The processor therefore provides a concrete RTL demonstration of **activity-aware combinational power reduction**.


# Data Memory Limitation

The Nangate 45 nm standard-cell library used in this project does **not provide a dedicated SRAM macro** for the implemented memory.

Therefore, the data memory is synthesized using standard cells/flip-flops and multiplexing logic.

For the tested memory:

- 32 words
- 32 bits/word
- 1,024 stored bits

This implementation has a large area and timing penalty compared with a real SRAM macro.

Consequently, the processor PPA numbers should be interpreted as **standard-cell research results**, not production SRAM PPA.

A real ASIC implementation would normally replace this structure with an SRAM macro, changing area, delay, leakage, dynamic power and routing significantly.

---

# Important Timing Optimization: Single Data-Memory Address Port

During processor optimization, separate read-address and write-address paths were initially used.

The ALU result was driving both address paths. This created unnecessary loading/fanout and increased the critical-path delay.

The design was changed to use a **single address port**.

After removing the redundant separate read/write address paths, the observed critical-path delay decreased by approximately:

> **2 ns**

This was a major timing improvement.

It also demonstrates an important architectural lesson from the implementation: reducing unnecessary fanout and duplicate routing can provide a much larger timing benefit than adding local optimization logic.

---

# Timing

## Baseline

Worst data arrival:

`8.260 ns`

Setup slack at 10 ns:

`1.596 ns — MET`

Estimated maximum frequency:

`≈ 121.1 MHz`

## Activity-Isolated

Worst data arrival:

`8.416 ns`

Setup slack at 10 ns:

`1.441 ns — MET`

Estimated maximum frequency:

`≈ 118.8 MHz`

The power-aware logic adds approximately 0.156 ns to the observed critical path, but the processor still meets 100 MHz.

---

# Why Area Increases

The enable/isolation architecture adds combinational logic, especially multiplexing and control logic.

Top-level area:

`31,692.038 → 33,253.458 µm²`

Area overhead:

`+4.93%`

Sequential area remains:

`10,078.208 µm²`

The area increase is therefore primarily combinational.

---

# Applications and Market Positioning

A defensible positioning for this prototype is:

> **A configurable 32-bit low-power custom processor core with AI/ML-oriented INT8 primitives and workload-specific instructions.**

The strongest fit is as a **custom compute IP / research-to-product platform**, rather than as a direct replacement for high-end general-purpose CPU cores.

Potential application areas include:

- Edge-AI preprocessing
- Sensor and signal-processing controllers
- Custom DSP workloads
- Embedded application-specific controllers
- Custom silicon prototypes
- Academic/research processor platforms
- Application-specific accelerator/control cores

The architecture combines a custom ISA, multi-operand operations, MAC/MSC, INT8-oriented primitives, dedicated move paths and selective operand/control isolation.

The AI instructions should be described as **AI/ML-oriented primitives**, not as proof that the processor is a complete AI accelerator. Application fit still needs real workload benchmarks and software support.

---

# Advantages

- Custom 32-bit processor
- Multiple custom instruction formats
- Multi-source operations
- Custom ALU functions
- Branch and jump support
- Multi-port register file
- Gate-level verification
- VCD-based power analysis
- Static timing analysis
- Nangate 45 nm synthesis
- Processor-level PPA comparison
- Block-level power optimization
- Architectural timing optimization
- Measured processor-level power reduction

---

# Limitations

1. **Flip-flop-based data memory:** not representative of production SRAM.
2. **Single-cycle architecture:** places substantial logic on one clock period and limits Fmax.
3. **Custom ISA:** requires a custom software/toolchain flow.
4. **Workload-dependent power:** VCD power changes with stimulus.
5. **Enable/isolation overhead:** can increase area, delay and sometimes power.
6. **No physical implementation:** results do not include place-and-route, extracted parasitics, IR drop or EM analysis.
7. **45 nm standard-cell library:** results are technology-specific.

---

# Tools

| Category | Tool |
|---|---|
| RTL | Verilog HDL |
| Simulation | Icarus Verilog |
| Waveform | GTKWave |
| Synthesis | Yosys |
| STA | OpenSTA |
| Power | OpenSTA + VCD |
| Standard cells | NangateOpenCellLibrary |
| Technology | 45 nm |
| Target clock | 10 ns / 100 MHz |

---

# Reproducibility

Typical OpenSTA setup:

```tcl
read_liberty /home/lenovo/NangateOpenCellLibrary_typical.lib
read_verilog top_baseline_netlist.v
link_design top_baseline

create_clock -name clk -period 10 [get_ports clk]
set_clock_uncertainty 0.10 [get_clocks clk]
set_false_path -from [get_ports rst]

report_checks -path_delay max -digits 3
report_checks -path_delay min -digits 3
```

Power-aware version:

```tcl
read_liberty /home/lenovo/NangateOpenCellLibrary_typical.lib
read_verilog top_netlist.v
link_design top

create_clock -name clk -period 10 [get_ports clk]
set_clock_uncertainty 0.10 [get_clocks clk]
set_false_path -from [get_ports rst]

report_checks -path_delay max -digits 3
report_checks -path_delay min -digits 3

read_vcd combined_gate_enable_selfcheck.vcd -scope tb_gate_combined_enable_selfcheck/dut

report_activity
report_power
```

Baseline power:

```tcl
read_vcd combined_gate_baseline_selfcheck.vcd -scope tb_gate_combined_baseline_selfcheck/dut

report_activity
report_power
```

---

# Repository Contents

```text
Custom_RISCV_Processor_PPA_Analysis/
├── README.md
├── results/
│   ├── processor_ppa_summary.txt
│   └── processor_enable/
│       ├── 01_synthesis_area.png
│       ├── 02_sta_min.png
│       ├── 03_power.png
│       ├── 04_sta_max_part1.png
│       └── 05_sta_max_part2.png
└── isa_sheets/
    ├── R4TYPESHEET(1).pdf
    ├── R3 TYPE SHEET(1).pdf
    ├── R3I TYPE SHEET(1).pdf
    ├── I TYPE SHEET(1).pdf
    ├── LOAD WORD SHEET(1).pdf
    ├── STORE WORD SHEET(1).pdf
    ├── BRANCH WORD SHEET(1).pdf
    ├── R2TYPE(1).pdf
    ├── R4MOVTYPEINSSHEET.pdf
    └── R2MOV SHEEET(1).pdf
```

---

# Validation Methodology

The processor validation flow is:

```text
RTL simulation
      ↓
Synthesis
      ↓
Technology-mapped gate-level simulation
      ↓
Static timing analysis
      ↓
Gate-level VCD power analysis
```

The baseline and enable processors use the **same mixed instruction program**, so the power comparison is not based on different instruction streams.

The mixed workload exercises:

```text
R4 ADD → R4 MAC → R3 VADD8 → R3 MUL → R3 SDOTP4
→ R3I ADD → R2 NEG → R2 MOV → I ADDI
→ SW → LW → R3 VMAX8 → BEQ → JAL → JALR
```

The self-checking gate-level testbench checks instruction word, PC, next PC, result/writeback values where applicable, and the JALR loop return. Both gate-level versions passed validation.

The corresponding VCDs are:

```text
combined_gate_baseline_selfcheck.vcd
combined_gate_enable_selfcheck.vcd
```

Both power runs reported zero unannotated pins.

---

# Productization Roadmap

The current stage is a **synthesized and gate-level-validated RTL prototype with a measured low-power comparison**.

The next engineering steps are:

1. Freeze the binary ISA encoding and publish one authoritative ISA document.
2. Add assembler, disassembler, simulator and compiler-intrinsic support.
3. Benchmark vector addition, dot products, ReLU, MAC loops, memory movement and branch-heavy workloads.
4. Measure cycles, instructions, switching power and energy per operation.
5. Replace the current standard-cell memory implementation with parameterized RAMs or technology-specific SRAM macros.
6. Consider pipelining to improve frequency while retaining the ISA concepts.
7. Perform floorplanning, placement, CTS, routing, post-layout STA and post-layout power.
8. Prepare integration, timing/reset, verification, configurability and benchmark documentation.

The intended progression is:

```text
RTL prototype
    ↓
Reproducible IP block
    ↓
Benchmarked application processor
    ↓
Physically implemented silicon-ready IP
```

# Final Assessment

The custom processor demonstrates an end-to-end RTL-to-ASIC evaluation using a 45 nm standard-cell library.

The power-aware implementation achieves:

- **33,253.458 µm² area**
- **2.00 mW total power**
- **8.416 ns worst data-path delay**
- **1.441 ns setup slack at 100 MHz**
- **≈118.8 MHz estimated maximum frequency**

Compared with baseline, the processor achieves approximately:

> **15.61% lower total power for 4.93% additional area.**

The most important architectural optimization was also not an isolation circuit: removing redundant read/write address paths and using a single data-memory address port reduced the critical-path delay by approximately **2 ns**.

Overall, the project demonstrates a practical PPA tradeoff:

```text
+4.93% Area
     |
     v
Power-aware datapath
     |
     v
-15.61% Total Power
     |
     v
100 MHz Timing Met
```

The results are specific to the Nangate 45 nm standard-cell implementation, the single-cycle architecture, the synthesized flip-flop-based data memory, and the workloads used for VCD-based power analysis.
