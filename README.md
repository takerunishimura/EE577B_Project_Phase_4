# EE577B Phase 4 - Cardinal Torus CMP

## Setup
```bash
tcsh
source setup_ee577b_v26.csh
```

## Simulation
```bash
make sim
```

## Synthesis
Run in background (survives SSH disconnect):
```bash
nohup make syn &
tail -f dc.log  # monitor progress
```
Outputs will be in `report/` and `netlist/` when complete.

## STA (run after synthesis)
```bash
cd sta
pt_shell
source scripts/sta_tut.tcl
```

## PNR (run after synthesis)
```bash
cd pnr
source setup_ee577b_v26.csh
innovus
```

## LEC (run after synthesis)
TBD
