# Verification plan

The testbench uses a 16-cycle period so each output pulse can be checked one clock position at a time.

| Input duty | Expected high cycles |
| --- | ---: |
| 0 percent | 0 |
| 25 percent | 4 |
| 50 percent | 8 |
| 100 percent | 16 |

The test also changes the inputs during an active period. The outputs must keep their old duty settings until the next period boundary. A final case checks integer rounding and a request above 100 percent.

Run `./scripts/run_sim.sh`. The testbench compares all four outputs at every counter position and stops on the first mismatch.
