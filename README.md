# Four-Channel PWM Generator

A four-output PWM block written in Verilog. All channels share one period counter, while each channel has its own duty-cycle input.

Duty settings are sampled at the start of a PWM period. That keeps the pulse width steady for the whole period even if an input changes partway through it. Values above 100 are limited to 100 percent.

## Interface

| Signal | Direction | Meaning |
| --- | --- | --- |
| `clk` | Input | System clock |
| `rst_n` | Input | Active-low asynchronous reset |
| `duty0` to `duty3` | Input | Requested duty cycle, 0 to 100 |
| `pwm_out[3:0]` | Output | Four PWM signals |

The period is set with the `PERIOD_CYCLES` parameter. The number of high clock cycles is rounded down to a whole cycle.

## Run the simulation

Install Icarus Verilog and Python with Matplotlib, then run:

```bash
./scripts/run_sim.sh
```

The testbench checks the output at every counter position, including 0 percent, 100 percent, mid-period updates, and inputs above 100 percent. The script saves the VCD, log, and waveform preview in `docs/waveforms/`.

## Scope

This version uses edge-aligned PWM and one shared period. It does not include complementary outputs, dead-time insertion, or centre-aligned PWM.

Sai Teja
