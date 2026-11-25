#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
WAVE_DIR="$ROOT_DIR/docs/waveforms"
mkdir -p "$BUILD_DIR" "$WAVE_DIR"
command -v iverilog >/dev/null 2>&1 || { echo "Install Icarus Verilog first." >&2; exit 127; }
command -v vvp >/dev/null 2>&1 || { echo "Icarus Verilog runtime (vvp) is missing." >&2; exit 127; }
cd "$ROOT_DIR"
iverilog -g2012 -Wall -s tb_pwm_generator -o "$BUILD_DIR/pwm_sim" \
    rtl/pwm_generator.v tb/tb_pwm_generator.v
vvp "$BUILD_DIR/pwm_sim" 2>&1 | tee "$BUILD_DIR/simulation.log"
python3 scripts/render_waveform.py "$BUILD_DIR/pwm_generator.vcd" "$WAVE_DIR/pwm_generator.png" \
    "Four Channel PWM Generator, duty cycle timing" \
    "tb_pwm_generator.clk,tb_pwm_generator.rst_n,tb_pwm_generator.duty0,tb_pwm_generator.duty1,tb_pwm_generator.duty2,tb_pwm_generator.duty3,tb_pwm_generator.pwm_out,tb_pwm_generator.dut.counter"
cp "$BUILD_DIR/pwm_generator.vcd" "$WAVE_DIR/pwm_generator.vcd"
cp "$BUILD_DIR/simulation.log" "$WAVE_DIR/simulation.log"
echo "Waveform, VCD and log saved in docs/waveforms/."
