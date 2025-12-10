# Reaction Timer — FPGA Project

A small FPGA project implementing a reaction-timer style system (for a class project). The repository contains VHDL modules and Quartus Block Design files for a reaction-timer and supporting display logic.

This README is intentionally technical and geared toward someone who wants to simulate, synthesize, or extend the designs.

## Contents

- `hexdisplay.vhd` — 4-bit to 7-segment mapper. Entity `hexdisplay` takes a 4-bit `a : UNSIGNED(3 downto 0)` and outputs `result : UNSIGNED(6 downto 0)` for a seven-segment display.
- `timer.vhd` — Moore finite-state machine for timing and state outputs. Entity `timer` ports:
  - `clk : in std_logic`
  - `reset : in std_logic` (active low in source)
  - `start : in std_logic`
  - `react : in std_logic`
  - `mstime : out unsigned(7 downto 0)` (upper bits of an internal counter)
  - `threegreens : out std_logic_vector(2 downto 0)` (three-state indicator outputs)

  The implementation uses a 28-bit `count` signal and a 3-state machine: `sIdle`, `sWait`, `sCount`. The output `mstime` is derived as `count(27 downto 20)`.

- `timerExtension.vhd` — Extended timer. Similar FSM to `timer` but adds a small pseudo-random LFSR-like `randomtime : unsigned(3 downto 0)` and an extra output `randomDisplay : out std_logic_vector(3 downto 0)`. `mstime` is a `std_logic_vector(7 downto 0)` here.

- `reaction.bdf`, `reactionExtension.bdf` — Quartus Block Design files. These are graphical netlist files generated/edited by Intel Quartus II block editor; they instantiate and wire the VHDL entities (for example, `hexdisplay` instances and timer FSMs). Do not edit BDF ports with a plain text editor if you plan to continue editing the block in Quartus’ Block Editor — the BDF format can be corrupted by manual edits.

## Design notes and contract

- Inputs/Outputs summary (top-level signals used by the BDF designs):
  - Inputs: `clk`, `reset`, `start`, `react`
  - Display outputs: several `hex_` signals (multiple `hexdisplay` instances drive these), `threegreens[2..0]`

- Timing: an internal 28-bit `count` is used and `mstime` is taken from `count(27 downto 20)` (8-bit). The threshold constants in `timer.vhd` are tuned to a particular board clock frequency — adjust constants if your board clock differs.

- Assumptions made when interpreting the code:
  - The original code targets an Altera/Intel FPGA and a typical development board (clock ~50 MHz is a common assumption). If your board uses a different clock, adapt the threshold constants or the bit slicing used to form `mstime`.
  - `reset` is treated as active-low in the VHDL sources (code checks `if reset = '0' then`), so be careful when connecting a board push-button or external reset.

## Simulation (recommended)

For functional simulation of the VHDL files you can do either of the following:

- Use ModelSim/Questa (recommended if you have a Quartus/ModelSim setup):
  - Create a testbench that instantiates `timer` or `timerExtension` and toggles `clk`, asserts/deasserts `start` and `react`, then run a behavioral simulation to inspect `mstime` and `threegreens`.

- Use GHDL (open-source VHDL simulator) for the VHDL units (you still need a testbench):

  Example (high level) sequence — you will need to adapt the top-level and testbench names in practice:

  ```bash
  # analyze
  ghdl -a hexdisplay.vhd
  ghdl -a timer.vhd
  ghdl -a <your_testbench>.vhd

  # elaborate
  ghdl -e <testbench_entity>

  # run (set a meaningful time)
  ghdl -r <testbench_entity> --vcd=result.vcd --stop-time=200us
  ```

  Open `result.vcd` in a waveform viewer or use `gtkwave`.

Note: this repo does not include an explicit testbench — add one to automate functional verification. A minimal testbench should:
- generate `clk` (50 MHz or whatever your board uses),
- toggle `reset`,
- assert `start` to begin the waiting/randomization period,
- assert `react` to signal a reaction,
- capture `mstime` and `threegreens` outputs for assertions.

## Synthesis and Quartus

- The `.bdf` files are intended to be opened in Intel Quartus II/Prime. They describe the top-level wiring and instantiate the VHDL modules.
- Typical flow in Quartus:
  - Create a new Quartus project, set the target device to your FPGA (DE-series or other board),
  - Add the VHDL files and the `.bdf` top-level into the project,
  - Assign pins (pin planner) for the `clk`, switches/buttons for `start`/`react`/`reset`, and the segment/digit pins for the `hex_..` signals,
  - Compile (Analysis & Synthesis, Fitter), then program the device.

Important: do not edit the `reaction.bdf` or `reactionExtension.bdf` port definitions in a plain text editor — use the Quartus block editor or instantiate a modified top-level VHDL file instead.

## Extension ideas / next steps

- Add a dedicated top-level VHDL wrapper that maps physical pins (with a recommended pin assignment file) so the project compiles for a specific board.
- Add a VHDL testbench and automated regression tests (GHDL + scripts or ModelSim).
- Provide a small debouncing component for push-buttons (start/react/reset) if you plan to use mechanical switches on hardware.
- Add constraints / pin assignment examples for a particular development board (e.g., DE0/DE2/DE10-Lite) — useful for grading or reproducible demos.

## Files changed / created

This repo currently contains the source files listed in the Contents section. This README was added to help document the project.

## Author

Christian Okyere
