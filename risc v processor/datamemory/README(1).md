# 256x32 Data Memory — RTL, Synthesis & STA

## Overview

This project implements a 256 × 32-bit data memory in synthesizable Verilog.

- Depth: 256 words
- Width: 32 bits
- Capacity: 8,192 bits = 1 KB
- Read: Asynchronous
- Write: Synchronous
- Clock target: 100 MHz
- Clock period: 10 ns
- Technology library: Nangate 45 nm Open Cell Library
- Synthesis: Yosys
- STA: OpenSTA

The memory is evaluated in a standard-cell flow to study area, timing, and power implications of synthesizing a behavioral memory.

## RTL

```verilog
module data_memory (
    input        clk,
    input [31:0] waddr,
    input [31:0] raddr,
    input [31:0] wdata,
    input        wen,
    input        ren,
    output wire [31:0] rdata
);

    // 256 words × 32 bits = 8,192 bits = 1 KB
    reg [31:0] data [0:255];

    // Synchronous write
    always @(posedge clk) begin
        if (wen)
            data[waddr[9:2]] <= wdata;
    end

    // Asynchronous read
    assign rdata = ren ? data[raddr[9:2]] : 32'b0;

endmodule
```

### Addressing

The memory uses `waddr[9:2]` and `raddr[9:2]` as the 8-bit word index.

- `[1:0]`: byte offset
- `[9:2]`: 256-word index
- `[31:10]`: unused by this implementation

## STA Setup

OpenSTA was run with an ideal 10 ns clock:

```tcl
read_liberty /home/lenovo/nangate.lib
read_verilog data_memory_netlist.v
link_design data_memory

create_clock -name clk -period 10 [get_ports clk]

set_input_delay 1 -clock clk     [get_ports {waddr[*] raddr[*] wdata[*] wen ren}]

set_output_delay 1 -clock clk     [get_ports {rdata[*]}]

set_input_transition 0.1     [get_ports {waddr[*] raddr[*] wdata[*] wen ren}]
```

The analysis is pre-CTS, so the clock network is treated as ideal.

## Setup Timing Result

Worst reported read path:

```text
Startpoint: raddr[4]
Endpoint:   rdata[6]

Clock period:           10.00 ns
Input external delay:    1.00 ns
Output external delay:   1.00 ns
Data arrival time:       8.37 ns
Data required time:      9.00 ns
Setup slack:            +0.63 ns
```

### Read-path cell breakdown

```text
raddr[4]
  |
  v
INV_X1       6.46 ns
  |
OAI211_X1    0.33 ns
  |
AOI22_X1     0.23 ns
  |
AOI21_X1     0.02 ns
  |
AOI22_X1     0.23 ns
  |
OAI211_X1    0.03 ns
  |
AOI221_X1    0.07 ns
  |
  v
rdata[6]
```

The internal combinational delay in this reported path is:

**7.37 ns**

The total arrival time is 8.37 ns after including the 1 ns input external delay.

## Hold Timing Result

Worst reported minimum-delay register-to-register path:

```text
Data arrival time:   0.12 ns
Hold requirement:    0.01 ns
Hold slack:         +0.11 ns
```

**Hold timing: MET**

## Timing Summary

Reported OpenSTA summary:

```text
wns max = 0.00 ns
tns max = 0.00 ns
```

## Why 256×32?

A larger 1024×32 behavioral memory produced a very long asynchronous read path when mapped to standard cells. Reducing the depth to 256 words significantly reduced the synthesized decode/mux network.

The 256×32 implementation currently meets the 100 MHz standalone timing target with **+0.63 ns setup slack** under the stated I/O timing assumptions.

## Synthesis / Area

Yosys synthesis was performed after technology mapping to the Nangate 45 nm standard-cell library.

### Synthesis / Area Result

```text
Wires:              28,583
Wire bits:          36,643
Public wires:          263
Public wire bits:    8,323
Ports:                   7
Port bits:             131
Total cells:        28,352

Chip area:         66,468.346
Sequential area:   37,044.224
Sequential area:       55.73%
```

### Selected mapped cell counts

| Cell | Count |
|---|---:|
| `DFF_X1` | 8,192 |
| `MUX2_X1` | 9,924 |
| `INV_X1` | 898 |
| `AOI211_X1` | 1,426 |
| `AOI21_X1` | 1,844 |
| `AOI221_X1` | 271 |
| `AOI22_X1` | 126 |
| `OAI221_X1` | 205 |
| `OAI211_X1` | 874 |
| `AND2_X1` | 535 |
| `OR2_X1` | 438 |

The 8,192 `DFF_X1` cells correspond directly to the 256 × 32 = 8,192 memory storage bits.


## Power

> Power results will be added here after power analysis is completed.

Metrics to report:

- Internal power
- Switching power
- Leakage power
- Total power

## Power Analysis

Power was evaluated using **OpenSTA** with the Nangate 45 nm Liberty library and VCD-based activity under the same test workload for the two RTL variants.

### VCD activity annotation

For both runs:

```text
Annotated pin activities: 130
Unannotated:             112,820
```

The 130 annotated activities correspond to the top-level non-clock pin bits represented in the VCD. The large number of unannotated internal synthesized pins means the VCD-based power values should be treated primarily as a **comparative estimate** rather than a signoff-quality absolute power measurement.

### Without Read Enable

RTL form:

```verilog
assign rdata = data[raddr[9:2]];
```

OpenSTA result:

```text
Sequential:
  Internal power   = 5.70e-03 W
  Switching power  = 4.86e-07 W
  Leakage power    = 6.23e-04 W
  Total power      = 6.32e-03 W  (51.4%)

Combinational:
  Internal power   = 4.85e-03 W
  Switching power  = 5.70e-04 W
  Leakage power    = 5.43e-04 W
  Total power      = 5.97e-03 W  (48.6%)

Total:
  Internal power   = 1.06e-02 W
  Switching power  = 5.71e-04 W
  Leakage power    = 1.17e-03 W
  Total power      = 1.23e-02 W
                  = 12.3 mW

Power breakdown:
  Internal   = 85.9%
  Switching  = 4.6%
  Leakage   = 9.5%
```

![OpenSTA power report without read enable](power_without_enable.png)

### With Read Enable

RTL form:

```verilog
assign rdata = ren ? data[raddr[9:2]] : 32'b0;
```

OpenSTA result:

```text
Sequential:
  Internal power   = 5.70e-03 W
  Switching power  = 4.95e-07 W
  Leakage power    = 6.23e-04 W
  Total power      = 6.32e-03 W  (51.3%)

Combinational:
  Internal power   = 4.91e-03 W
  Switching power  = 5.52e-04 W
  Leakage power    = 5.38e-04 W
  Total power      = 6.00e-03 W  (48.7%)

Total:
  Internal power   = 1.06e-02 W
  Switching power  = 5.52e-04 W
  Leakage power    = 1.16e-03 W
  Total power      = 1.23e-02 W
                  = 12.3 mW

Power breakdown:
  Internal   = 86.1%
  Switching  = 4.5%
  Leakage   = 9.4%
```

![OpenSTA power report with read enable](power_with_enable.png)

### Power comparison

Under the same simulated workload:

| Metric | Without `ren` | With `ren` |
|---|---:|---:|
| Internal power | 10.6 mW | 10.6 mW |
| Switching power | 0.571 mW | 0.552 mW |
| Leakage power | 1.17 mW | 1.16 mW |
| **Total power** | **12.3 mW** | **12.3 mW** |
| Sequential power | 6.32 mW | 6.32 mW |
| Combinational power | 5.97 mW | 6.00 mW |

The read-enable version reduced the reported switching power from **0.571 mW to 0.552 mW**, a reduction of approximately **3.3%** in the switching-power component:

\[
\frac{0.571-0.552}{0.571}\times100 \approx 3.3\%
\]

However, the reported **total power remains approximately 12.3 mW** after rounding because the additional enable/mux logic offsets most of the switching-power reduction.

This demonstrates an important RTL power-design trade-off: adding an enable can reduce switching activity without necessarily producing a large reduction in total power.

### Power-analysis limitation

The power results above are based on the current standard-cell synthesis and OpenSTA activity flow. They are useful for **same-workload comparison between the two RTL implementations**, but they should not be interpreted as signoff-quality absolute power numbers because many synthesized internal pins remain unannotated in the VCD-based activity report.

## Tool Flow

```text
Verilog RTL
    |
    v
Yosys synthesis
    |
    v
Nangate 45 nm standard-cell mapping
    |
    v
Synthesized netlist
    |
    v
OpenSTA
    |
    +--> Setup
    +--> Hold
    +--> WNS / TNS
    |
    v
Power analysis
```

## Implementation Note / Library Limitation

This memory was synthesized using the **Nangate 45 nm Open Cell Library**.

A key limitation of this flow is that the standard-cell library used for this experiment does **not provide a dedicated SRAM macro** for the 256 × 32 memory. As a result, the behavioral Verilog memory is mapped into ordinary standard cells, including thousands of flip-flops and selection logic.

This has a major impact on the reported results:

- The **8,192 DFF_X1** cells represent the 8,192 storage bits of the 256 × 32 memory.
- The reported **66,468.346 area** is the area of the standard-cell implementation, not the area of a compact SRAM macro.
- The reported asynchronous read-path delay is likewise specific to this synthesized standard-cell implementation.

With a **dedicated SRAM macro**, the implementation would use a specialized memory array and peripheral circuitry rather than 8,192 standard-cell flip-flops and the associated mux/decode network. Therefore, the **area and timing results would be expected to be substantially different**. The exact improvement cannot be determined from this experiment because no SRAM macro characterization was used.

Accordingly, these results should be presented as **technology/library-specific standard-cell results for RTL and architecture comparison**, not as representative physical results for a modern dedicated-SRAM implementation.

## Current Baseline

| Parameter | Result |
|---|---:|
| Memory depth | 256 words |
| Word width | 32 bits |
| Capacity | 1 KB |
| Read | Asynchronous |
| Write | Synchronous |
| Clock period | 10 ns |
| Clock frequency | 100 MHz |
| Input external delay | 1 ns |
| Output external delay | 1 ns |
| Input transition | 0.1 ns |
| Internal read-path delay | 7.37 ns |
| Setup slack | **+0.63 ns** |
| Hold slack | **+0.11 ns** |
| Total mapped cells | **28,352** |
| DFF_X1 count | **8,192** |
| MUX2_X1 count | **9,924** |
| Synthesized area | **66,468.346** |
| Sequential area | **37,044.224 (55.73%)** |
| Total power, no `ren` | **12.3 mW** |
| Total power, with `ren` | **12.3 mW** |
| Switching power, no `ren` | **0.571 mW** |
| Switching power, with `ren` | **0.552 mW** |

## Next Updates

- Add final Yosys synthesis and area numbers
- Add power results
- Add final PPA summary
