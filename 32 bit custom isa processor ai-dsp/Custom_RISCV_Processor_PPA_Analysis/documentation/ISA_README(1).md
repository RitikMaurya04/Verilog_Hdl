# Custom ISA README

## ISA philosophy

The ISA is organized around the number and type of operands required by the operation.

| Family | Main idea |
|---|---|
| R4 | Three ALU operands |
| R3 | Two register operands |
| R3I | Register operands plus compact immediate |
| R2 | Single register operand |
| I | Register + immediate |
| Load/Store | Address-generation operations |
| Branch | Conditional control flow |
| JAL/JALR | PC-relative / register-based control flow |

## R4 compute

Supported R4 ALU functions:

`ADD, SUB, OR, AND, NAND, NOR, XOR, XNOR, XOR-AND, NOT-AND-XOR, NOT-OR-AND, AND-NOT2, INC, DEC, MAX, MIN, MAC, MSC`

R4 is useful for expressing three-source arithmetic and logic directly.

## R3 compute

Supported R3 functions:

`ADD, SUB, OR, AND, NAND, NOR, XOR, XNOR, AND-NOT, OR-NOT, INC, DEC, SLL, SLT, SRL, SRA, SGT, MAX, MIN, MUL, VADD8, VMAX8, SDOTP4`

## AI/DSP primitives

### VADD8

Four independent 8-bit additions are performed in parallel.

### VMAX8

Four independent signed INT8 maximum operations are performed in parallel.

### SDOTP4

Four signed 8-bit lane products are accumulated to form a dot-product style result.

### VRELU8

Four signed 8-bit lanes are processed independently with ReLU behavior.

### MAC / MSC

The ALU provides multiply-accumulate and multiply-subtract primitives.

## R2 compute

The R2 family contains:

`NEG, ABS, NOT, INC, DEC, VRELU8`

## Move instructions

The decoder contains a dedicated R4 MOVE path and an R2 MOV path.

The key architectural idea is that data movement can bypass unnecessary ALU computation.

## Immediate instructions

I-type operations include:

`ADDI, SUBI, ORI, ANDI, XORI, SLLI, SRLI, SRAI`

## Control flow

Branch conditions include equal, not-equal, signed/unsigned relational comparisons, and zero comparisons.

The design also supports:

`JAL` and `JALR`

with link generation from `PC + 4`.

## Important positioning point

The AI instructions should be described as **AI/ML-oriented primitives**, not as proof that the processor is a complete AI accelerator. A stronger commercial claim requires application benchmarks and software support.
