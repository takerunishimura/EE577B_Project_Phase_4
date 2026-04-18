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

## STA (run after synthesis)
```bash
cd sta
pt_shell
source scripts/sta_tut.tcl
```

## PNR (run after synthesis)
```bash
cd pnr
innovus
```

## LEC (run after synthesis)
TBD
