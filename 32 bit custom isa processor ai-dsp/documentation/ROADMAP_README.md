# Roadmap README

## Current stage

The processor is currently a synthesized and gate-level-validated RTL prototype with a measured low-power comparison.

### Completed

- 32-bit single-cycle processor
- Custom ISA
- R4/R3/R3I/R2/I instruction families
- AI/ML-oriented primitives
- MAC/MSC
- Move instructions
- Branch and jump control
- 3R/2W register file
- Operand/control isolation
- NanGate synthesis
- Gate-level functional validation
- STA
- Gate-level power analysis
- Same-workload power comparison

## Next engineering stage

### 1. ISA specification

Freeze the binary encoding and publish one authoritative ISA document.

### 2. Software support

Create:

- assembler syntax
- disassembler
- simulator
- compiler intrinsics
- tests for each custom instruction

### 3. Benchmarking

Build benchmark kernels for:

- vector addition
- dot products
- ReLU
- MAC loops
- memory copy / movement
- branch-heavy code

Measure:

- cycles
- instructions executed
- switching power
- energy per operation

### 4. Better memory architecture

Move integrated memories toward parameterized RAMs or technology-specific SRAM macros.

### 5. Timing scalability

The current processor is single-cycle.

A pipelined version could improve frequency and allow larger workloads while retaining the same ISA concepts.

### 6. Physical design

Run:

- floorplanning
- placement
- CTS
- routing
- post-layout STA
- post-layout power

### 7. Product IP

Prepare:

- integration guide
- timing/reset requirements
- verification plan
- configurable parameters
- licensing/package structure
- benchmark report
- application demo

## Product milestone

The key transition is:

**RTL prototype → reproducible IP block → benchmarked application processor → physically implemented silicon-ready IP**
