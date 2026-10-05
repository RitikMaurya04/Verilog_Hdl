# Market Positioning README

## Proposed product identity

The most defensible product identity for this project is:

> **A configurable 32-bit low-power custom processor core with AI/ML-oriented INT8 primitives and workload-specific instructions.**

This is a proposed positioning statement, not a claim of production-market leadership.

## Why a customer could care

### Application-specific compute

A custom ISA makes it possible to add operations that match the dominant workload.

This can reduce the amount of instruction sequencing required for operations such as MAC, vector INT8 arithmetic, dot-product, and other custom datapath functions.

### Low-power intent is built into the RTL

The processor was not designed only for functional correctness.

The datapath includes explicit isolation and enable mechanisms intended to suppress unnecessary switching.

The mixed-workload gate-level experiment measured:

**26.84% reduction in total switching power.**

### AI/ML-oriented primitives

The processor has hardware support for:

- VADD8
- VMAX8
- SDOTP4
- VRELU8

These operations make the architecture relevant to experiments around quantized/INT8 compute and small edge-oriented workloads.

### DSP capability

MAC and MSC provide compact arithmetic primitives for signal processing and filter-style workloads.

### Data movement

Dedicated move paths provide simple register movement without requiring every data movement operation to activate the ALU datapath.

### Simple architecture

The current single-cycle organization is relatively straightforward to inspect, customize, verify, and synthesize.

That simplicity can be valuable for an IP development platform and for rapidly evaluating new instructions.

---

# Suggested target market

The current architecture is better positioned as a **custom compute IP / research-to-product platform** than as a direct replacement for high-end general-purpose CPU cores.

Potential target areas include:

- edge AI preprocessing
- sensor and signal-processing controllers
- custom DSP workloads
- embedded application-specific controllers
- custom silicon prototypes
- academic/research processor platforms
- application-specific accelerator/control cores

These are potential application areas based on the architecture's instruction and power features; application fit should be demonstrated with real workload benchmarks.

---

# Strongest sales message

A concise technical sales message could be:

> **Build the compute instructions your workload actually needs — and avoid switching datapath logic that is not needed.**

Supporting evidence from the current prototype:

- Custom 32-bit ISA
- Multi-operand R4 operations
- MAC/MSC
- INT8 vector primitives
- dedicated move paths
- 3-read/2-write register file
- selective operand/control isolation
- 26.84% lower switching power in the measured mixed workload
- 4.93% area overhead for the power-aware implementation
- approximately 116.8 MHz estimated Fmax from the reported with-enable STA path

---

# What should not be claimed yet

The current evidence does **not** establish:

- silicon-level power
- production yield
- commercial benchmark leadership
- software ecosystem maturity
- compiler optimization quality
- PPA superiority against a named commercial CPU
- production readiness
- a complete AI accelerator

Those claims require additional validation.

---

# What turns this into a sellable IP story

The next layer should be evidence that a customer can relate to:

1. **Benchmark kernels**  
   Measure cycles and energy for representative workloads.

2. **Compiler/toolchain support**  
   Add an assembler/disassembler and ideally compiler intrinsic support for custom instructions.

3. **Application demos**  
   Show an actual signal-processing or INT8 workload running end-to-end.

4. **PPA comparison**  
   Compare the same workload against a clearly specified baseline under identical technology/library assumptions.

5. **Parameterized architecture**  
   Make memory depth, ISA extensions, and optional AI blocks configurable.

6. **Physical implementation**  
   Move beyond synthesis estimates to place-and-route and post-layout power/timing.

7. **System features**  
   Add interrupts, exceptions, debug, reset strategy, and SoC integration features as required by the target market.

## Productization direction

A strong commercial direction would be to offer:

**Base Core**
+ Custom ISA
+ Standard scalar operations
+ Load/store/control flow

**AI Extension**
+ VADD8
+ VMAX8
+ SDOTP4
+ VRELU8

**Power Extension**
+ Operand isolation
+ Functional-unit enables
+ Activity-aware control

This makes the architecture potentially configurable rather than forcing every customer to buy exactly the same datapath.
