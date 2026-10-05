# Architecture README

## Core architecture

The uploaded RTL implements a **32-bit single-cycle processor** with a custom control/datapath organization.

The top-level design contains:

`PC → Instruction Memory → Decoder/Register File/Immediate Logic → ALU/Memory/Control → Writeback/Next PC`

## Register file

The register file contains:

- 32 registers
- 32-bit data width
- 3 asynchronous read ports
- 2 synchronous write ports
- x0 held at zero
- write-port-1 priority on simultaneous destination conflicts

The three read ports support the processor's multi-source instruction formats.

## ALU datapath

The ALU is organized around operating modes:

- R4: A, B, C
- R3: A, B
- R2: A
- I/load/store: A and C

The power-aware version adds global and per-operand enables.

## Memory

The instruction-memory RTL uses a 32-bit word and addresses the array through `addr[8:2]` for 128 entries.

The uploaded data-memory RTL uses 32-bit words and indexes the array using `addr[6:2]`. The exact memory implementation should be parameterized or replaced with an SRAM macro for a commercial implementation.

## Control flow

The PC-control block supports:

- sequential `PC + 4`
- conditional branch target
- JAL target
- JALR target
- link value `PC + 4`

## Power-aware control

The architecture selectively isolates inputs to:

- ALU
- branch comparator
- immediate generator
- ALU operand multiplexer
- result multiplexer
- PC control

This allows individual datapath sections to be prevented from seeing unnecessary transitions.
