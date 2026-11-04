#!/bin/bash
# GA pacing runs (re-run from anywhere). Output: design_work/ga/pace/<name>.txt; summary: pace_summary.txt
W=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/design_work/ga
PY=/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13
cd /Users/almeer/Documents/HighwayDhaba
run(){ out=$1; shift; $PY -I -B $W/ga_pace.py --promo --minutes 100 "$@" > $W/pace/$out.txt 2>&1; }
run base
run base_seed1 --seed 1; run base_seed2 --seed 2
run r15 --ga-rush=1.5                                   # GA-3 as designed (phase 0.64-0.79 = 90 s)
run r15_p60 --ga-rush=1.5 --ga-rush-from=0.60 --ga-rush-to=0.75
run r15_p70 --ga-rush=1.5 --ga-rush-from=0.70 --ga-rush-to=0.85
run r15k105 --ga-rush=1.5 --set traffic.ramp_capacity_k=1.05     # + GA-2 calibrated to the in-game gain
run r15k105_p60 --ga-rush=1.5 --ga-rush-from=0.60 --ga-rush-to=0.75 --set traffic.ramp_capacity_k=1.05
run r15k105_p70 --ga-rush=1.5 --ga-rush-from=0.70 --ga-rush-to=0.85 --set traffic.ramp_capacity_k=1.05
run r15L120 --ga-rush=1.5 --ga-rush-from=0.64 --ga-rush-to=0.84  # 120 s rush
run r15L120_p60 --ga-rush=1.5 --ga-rush-from=0.60 --ga-rush-to=0.80
run r15L120_p70 --ga-rush=1.5 --ga-rush-from=0.70 --ga-rush-to=0.90
run r13 --ga-rush=1.3; run r13_p60 --ga-rush=1.3 --ga-rush-from=0.60 --ga-rush-to=0.75
run r13_p70 --ga-rush=1.3 --ga-rush-from=0.70 --ga-rush-to=0.85
run r13_k105 --ga-rush=1.3 --set traffic.ramp_capacity_k=1.05
run r15x2 --ga-rush=1.5 --ga-rush-windows=0.30-0.45,0.64-0.79   # two rushes a day
run r15x2_b --ga-rush=1.5 --ga-rush-windows=0.34-0.49,0.70-0.85
run k105 --set traffic.ramp_capacity_k=1.05; run k12 --set traffic.ramp_capacity_k=1.2
run r15k12 --ga-rush=1.5 --set traffic.ramp_capacity_k=1.2      # upper bound (the tool pays k x floor)
