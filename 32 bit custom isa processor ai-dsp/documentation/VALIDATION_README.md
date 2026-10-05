# Validation README

## Validation strategy

The processor was validated in stages:

1. RTL simulation
2. Synthesis
3. Technology-mapped gate-level simulation
4. Static timing analysis
5. Gate-level VCD power analysis

## Same-workload principle

The enable and no-enable processors were evaluated with the same mixed program so that the power comparison is not based on different instruction streams.

## Mixed workload

The validation program exercises:

- R4 arithmetic
- MAC
- vector INT8 addition
- multiply
- signed dot product
- R3I arithmetic
- R2 unary arithmetic
- MOV
- immediate arithmetic
- store
- load
- vector INT8 max
- branch
- JAL
- JALR

## Gate-level checks

The self-checking testbench checks:

- expected instruction word
- expected PC
- expected next PC
- expected result/writeback value where applicable
- loop return through JALR

Both the no-enable and with-enable gate-level simulations passed.

## Power-analysis VCDs

The gate-level simulations generate the VCD used by OpenSTA.

No-enable VCD:

`combined_gate_baseline_selfcheck.vcd`

With-enable VCD:

`combined_gate_enable_selfcheck.vcd`

Both power runs report zero unannotated pins.

## Why gate-level validation matters

RTL simulation demonstrates functional behavior at the behavioral level.

Gate-level simulation adds technology-mapped standard-cell models between the RTL and the simulator, providing a check that synthesis has preserved the intended behavior of the mapped implementation.

Power analysis is performed on the gate-level implementation so the reported activity corresponds to the synthesized cell network.
