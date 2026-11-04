#!/bin/bash
# d2 agency: the same A/B on seeds 2 and 3. Usage: bash ab_seeds.sh
Q=${DR_WORK:-$HOME/DhabaRushQA}/qa
L=${DR_WORK:-$HOME/DhabaRushQA}/d2work/logs
BASE="waiter,waiter,galla,table,tandoor,lassi,kadai,tandoor_hire,chai_lvl50,tandoor_lvl57,lassi_lvl49,kadai_lvl50"
for s in 2 3; do
  COMMON=(--fresh --skip-tutorial --money=1000000 --no-notes --seed=$s --stats=60 --window=600 --quit-at=640)
  "$Q/run.sh" d2_m  "$L/A_t3_s$s.log"    900 -- "${COMMON[@]}" --buy="$BASE" &
  "$Q/run.sh" d2_m2 "$L/B_t5_s$s.log"    900 -- "${COMMON[@]}" --buy="$BASE,table,table" &
  "$Q/run.sh" d2_m3 "$L/C_cooks_s$s.log" 900 -- "${COMMON[@]}" --buy="$BASE,chai_hire,lassi_hire,kadai_hire,chai_speed,chai_speed" &
  "$Q/run.sh" d2_m4 "$L/D_sign_s$s.log"  900 -- "${COMMON[@]}" --buy="$BASE" --signboard=1 &
  wait
done
echo done
