#!/bin/bash
# d2 agency: in-game A/B while the road binds (headless, own slots). Usage: bash ab_runs.sh
Q=${DR_WORK:-$HOME/DhabaRushQA}/qa
L=${DR_WORK:-$HOME/DhabaRushQA}/d2work/logs
mkdir -p "$L"
BASE="waiter,waiter,galla,table,tandoor,lassi,kadai,tandoor_hire,chai_lvl50,tandoor_lvl57,lassi_lvl49,kadai_lvl50"
COMMON=(--fresh --skip-tutorial --money=1000000 --no-notes --seed=1 --stats=60 --window=600 --quit-at=640)
"$Q/run.sh" d2_m  "$L/A_t3.log"    900 -- "${COMMON[@]}" --buy="$BASE" &
"$Q/run.sh" d2_m2 "$L/B_t5.log"    900 -- "${COMMON[@]}" --buy="$BASE,table,table" &
"$Q/run.sh" d2_m3 "$L/C_cooks.log" 900 -- "${COMMON[@]}" --buy="$BASE,chai_hire,lassi_hire,kadai_hire,chai_speed,chai_speed" &
"$Q/run.sh" d2_m4 "$L/D_sign.log"  900 -- "${COMMON[@]}" --buy="$BASE" --signboard=1 &
wait
for f in A_t3 B_t5 C_cooks D_sign; do tail -1 "$L/$f.log"; done
