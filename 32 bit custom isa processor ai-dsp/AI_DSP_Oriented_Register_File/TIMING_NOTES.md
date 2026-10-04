# Timing Notes

The register file uses an asynchronous reset.

For the primary block-level timing metric, the headline worst delay/slack should refer to the normal functional data paths rather than asynchronous reset recovery/removal checks.

Observed functional timing:
- Baseline worst delay: 1.12 ns
- Read-isolated worst delay: 1.09 ns
- Both meet the 10 ns constraint

Asynchronous reset recovery/removal timing should be reported separately.
