#!/bin/bash
# Synthesis pacing runs: GA's wrapper (design_work/ga/ga_pace.py: the dinner rush) over tools/sim/pacing_v3.py,
# read-only, from the project root. k = traffic.ramp_capacity_k (GA-2 mirror; 1.05 = GA's calibrated proxy,
# 1.2 = the literal value, overstated); tips (GB-7 b) = --realized 0.92 x 1.0125 (nobody taps) or x 1.025 (all tapped);
# P3 = --set signboard.tpm_per_level=3.5. Outputs: design_work/syn/pace/<name>.txt
W=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/design_work
PY=/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13
cd /Users/almeer/Documents/HighwayDhaba
run(){ out=$1; shift; $PY -I -B $W/ga/ga_pace.py --promo --minutes 100 "$@" > $W/syn/pace/$out.txt 2>&1; echo "$out done"; }
K105="--set traffic.ramp_capacity_k=1.05"; K12="--set traffic.ramp_capacity_k=1.2"
P3="--set signboard.tpm_per_level=3.5"; TT="--realized 0.943"; TN="--realized 0.9315"
R="--ga-rush=1.5"
run base &
run r15k105 $R $K105 &
run r15k105_tt $R $K105 $TT &
run r15k105_tn $R $K105 $TN &
wait
run r15k105_p3 $R $K105 $P3 &
run r15k105_p3_tt $R $K105 $P3 $TT &
run r15k105_p3_tn $R $K105 $P3 $TN &
run k105_p3_tt $K105 $P3 $TT &
wait
run k105_tt $K105 $TT &
run k105_p3 $K105 $P3 &
run r15k12_p3_tt $R $K12 $P3 $TT &
run r15k12_tt $R $K12 $TT &
wait
# the recommended set at GA's two other rush phases (the end mark is sensitive to the phase)
run r15k105_p3_tt_p60 $R --ga-rush-from=0.60 --ga-rush-to=0.75 $K105 $P3 $TT &
run r15k105_p3_tt_p70 $R --ga-rush-from=0.70 --ga-rush-to=0.85 $K105 $P3 $TT &
run r15k105_tt_p60 $R --ga-rush-from=0.60 --ga-rush-to=0.75 $K105 $TT &
run r15k105_tt_p70 $R --ga-rush-from=0.70 --ga-rush-to=0.85 $K105 $TT &
wait
run p3 $P3 &
run r15_p3 $R $P3 &
run r15k105_p3_no_ads $R $K105 $P3 $TT --no-ads &
run base_no_ads --no-ads &
wait
echo ALL PACE DONE
# --- second set (P2 alternatives for the road-cap decision)
# run r15k105_cap22 --ga-rush=1.5 --set traffic.ramp_capacity_k=1.05 --set traffic.ramp_max_tpm=22
# run r15k105_cap22_tt --ga-rush=1.5 --set traffic.ramp_capacity_k=1.05 --set traffic.ramp_max_tpm=22 --realized 0.943
# run r15k105_cap24 --ga-rush=1.5 --set traffic.ramp_capacity_k=1.05 --set traffic.ramp_max_tpm=24
