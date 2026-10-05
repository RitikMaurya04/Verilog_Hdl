# Power Analysis README

## Objective

The main low-power objective is to suppress **unnecessary switching activity** in inactive or partially inactive datapath logic.

The with-enable implementation uses activity/operand isolation at multiple points rather than relying only on a single global enable.

## Comparison methodology

The comparison uses:

- the same processor architecture
- the same mixed instruction program
- the same gate-level validation workload
- the same NanGate standard-cell library
- the same 10 ns clock constraint
- the same clock uncertainty
- gate-level VCD activity annotation

## Same mixed workload

`R4 ADD → R4 MAC → R3 VADD8 → R3 MUL → R3 SDOTP4 → R3I ADD → R2 NEG → R2 MOV → I ADDI → SW → LW → R3 VMAX8 → BEQ → JAL → JALR`

## Gate-level power

| Metric | No Enable | With Enable | Change |
|---|---:|---:|---:|
| **Total power** | 2.37 mW | **2.00 mW** | **-15.61%** |
| **Switching power** | 0.678 mW | **0.496 mW** | **-26.84%** |
| Internal power | 1.05 mW | 0.844 mW | -19.62% |
| Combinational power | 1.74 mW | 1.38 mW | -20.69% |
| Leakage power | 0.637 mW | 0.661 mW | +3.77% |

## Primary result

**Switching power is reduced by 26.84%.**

That is the most relevant project result because switching reduction is the intended effect of operand/control isolation.

## Combinational power

Total combinational power decreases:

`1.74 mW → 1.38 mW`

which is a **20.69% reduction**.

Within the combinational group:

- internal power: **0.605 → 0.397 mW** (**34.38% reduction**)
- switching power: **0.671 → 0.488 mW** (**27.27% reduction**)

The total switching-power figure for the complete design is 0.678 → 0.496 mW because the OpenSTA total also includes the sequential contribution.

## Area trade-off

| Metric | No Enable | With Enable |
|---|---:|---:|
| Top-level area | 31,692.038 µm² | 33,253.458 µm² |
| Area change | — | **+4.93%** |

## Timing trade-off

| Metric | No Enable | With Enable |
|---|---:|---:|
| Critical delay | 8.260 ns | 8.416 ns |
| Slack | 1.596 ns | 1.441 ns |
| Timing | MET | MET |

The reported delay increase is **0.156 ns (1.89%)**.

## Frequency

With 8.416 ns data arrival, 0.10 ns clock uncertainty, and 0.044 ns setup time, the implied minimum period is approximately:

`8.416 + 0.100 + 0.044 = 8.560 ns`

which corresponds to approximately:

**116.8 MHz**

The tested 100 MHz target therefore meets timing with positive slack.

## VCD coverage

No Enable:

- 78,958 annotated pin activities
- 0 unannotated

With Enable:

- 79,081 annotated pin activities
- 0 unannotated

## Important interpretation

The power-aware design costs some area and a small amount of timing margin. Its main measured benefit is **lower switching power**, not lower leakage.

This is the correct way to present the result:

> **26.84% lower total switching power, 15.61% lower total power, at 4.93% area overhead and a 0.156 ns critical-path increase under the same workload.**
