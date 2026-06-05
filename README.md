# EE577B Project Phase 4 — Synthesis, STA, LEC, and Place & Route

**University of Southern California | EE577B Spring 2026 | Group 14**

---

## Overview

This repository covers the back-end implementation flow for the 16-core Cardinal CMP from Phase 3. The design was taken through logic synthesis, static timing analysis, logical equivalence checking, and place & route using industry-standard CAD tools targeting the NCSU FreePDK 45nm standard-cell library (gscl45nm).

---

## Implementation Flow

| Step | Tool | Output |
|---|---|---|
| Logic Synthesis | Synopsys Design Compiler | Synthesized netlist, area/timing/power reports |
| Static Timing Analysis | Synopsys PrimeTime | Timing histogram, critical path report |
| Logical Equivalence Check | Cadence Conformal | LEC reports |
| Place & Route | Cadence SOC Innovus | Pre/post-CTS timing reports, floorplan summary |

---

## Key Results

- Synthesis target: NCSU FreePDK 45nm (gscl45nm)
- Clock constraint: 4.0ns (250 MHz) — met with 0.00ns slack
- Total cell area: ~2.4M µm²
- `set_dont_touch sfu*` workaround applied to prevent DesignWare uniquification explosion during synthesis

---

## File Structure

```
EE577B_Project_Phase_4/
├── cmp/
│   ├── design/           # All RTL .v files (cardinal_cmp.v and all submodules)
│   ├── tb/               # Post-synthesis testbench
│   ├── testcase_torus/   # Torus testcase files
│   ├── include/
│   ├── scripts/          # Synthesis TCL scripts
│   ├── src/
│   ├── netlist/          # Synthesized netlist (excluded from git)
│   ├── report_torus/     # Synthesis area/timing/power reports
│   ├── sta/              # Static timing analysis scripts and reports
│   ├── lec/              # Logic equivalence check reports
│   ├── pnr/              # Place & route files and reports
│   └── work/
├── .gitignore
└── README.md
```

---

## Setup

```bash
tcsh
source setup_ee577b_v26.csh
```

---

## Simulation

```bash
make sim
```

---

## Synthesis

Run in background (survives SSH disconnect):
```bash
nohup make syn &
```

- `nohup` protects the process from dying if you disconnect
- `&` runs it in the background so you get your prompt back immediately
- You can safely close your terminal or get disconnected accidentally

Monitor progress after SSHing back in:
```bash
tail -f dc.log
```

- Streams the log file in real time as DC writes to it
- Press `Ctrl+C` to stop watching — this does NOT kill synthesis
- Synthesis is done when the last line of `dc.log` shows `exit`
- Output reports will be in `report/` and netlist in `netlist/`

---

## STA (run after synthesis)

```bash
cd sta
pt_shell
source scripts/sta_tut.tcl
```

---

## Place & Route (run after synthesis)

```bash
cd pnr
innovus
```

When importing the design in Innovus:
- Common Timing Libraries: `/tools/PDK/NCSU45PDK/FreePDK45/osu_soc/lib/files/gscl45nm.tlf`
- LEF Files: `/tools/PDK/NCSU45PDK/FreePDK45/osu_soc/lib/files/gscl45nm.lef`

---

## LEC (run after synthesis)

```bash
cd lec
# Follow Cadence Conformal tutorial
# Compare cardinal_cmp.v (RTL) vs cardinal_cmp.syn.v (synthesized netlist)
```

Results:
- `lec_report1.txt` — equivalence check (RTL vs synthesized netlist)
- `lec_report2.txt` — intentional inverter insertion experiment (expected: non-equivalent)
- `lec_report1_summary.txt` — summary of any debugging steps

---

## Tools

- **Synthesis:** Synopsys Design Compiler
- **STA:** Synopsys PrimeTime
- **LEC:** Cadence Conformal
- **PnR:** Cadence SOC Innovus
- **PDK:** NCSU FreePDK45 / gscl45nm
