# Block-Level Power Optimization Summary

All figures below are from the separate unit-level experiments used to support the integrated processor PPA story.

## ALU
Baseline: 9.02 mW
Power-aware: 5.50 mW
Total reduction: 39.02%
Switching reduction: 34.68%
Internal reduction: 45.30%
Area: 10,213.602 -> 10,468.696 um^2 (+2.50%)

## ALU Control
Without isolation: 65.7 uW
With isolation: 43.8 uW
Total reduction: 33.3%
Switching reduction: 42.1%
Internal reduction: 27.7%
Area: 126.616 -> 146.832 um^2 (+15.97%)
Leakage: 2.79 -> 3.33 uW (+19.4%)

## Branch Unit
Baseline: 138 uW
Power-aware: 84.8 uW
Total reduction: 38.55%
Switching reduction: 40.81%
Internal reduction: 40.49%
Area: 196.840 -> 248.444 um^2 (+26.22%)
Leakage: 4.53 -> 5.65 uW (+24.72%)

## Immediate Generator (immext)
Without isolation: 36.3 uW
With isolation: 25.5 uW
Total reduction: 29.8%
Switching reduction: 33.9%
Internal reduction: 26.6%
Area: 127.946 -> 111.188 um^2 (-13.1%)
Worst-path delay: 0.37 -> 0.50 ns

## Integrated Processor
Baseline total power: 2.37 mW
Power-aware total power: 2.00 mW
Total reduction: 15.61%
Switching: 0.678 -> 0.496 mW (-26.84%)
Combinational power: 1.74 -> 1.38 mW (-20.69%)
Combinational internal: 0.605 -> 0.397 mW (-34.38%)
Combinational switching: 0.671 -> 0.488 mW (-27.27%)
Leakage: 0.637 -> 0.661 mW (+3.77%)
Area: 31,692.038 -> 33,253.458 um^2 (+4.93%)

Important: unit-level percentages are not additive. Each block was evaluated with its own workload; the integrated processor result is the authoritative system-level measurement.
