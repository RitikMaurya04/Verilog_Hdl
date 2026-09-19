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

## Next Updates

- Add final Yosys synthesis and area numbers
- Add power results
- Add final PPA summary
