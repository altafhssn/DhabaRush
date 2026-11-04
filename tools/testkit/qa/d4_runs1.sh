#!/bin/bash
Q=${DR_WORK:-$HOME/DhabaRushQA}/qa
L=$Q/logs/d4
MID="waiter,waiter,tandoor,lassi,table,chai_lvl30,tandoor_lvl26,lassi_lvl12"
FULL="waiter,waiter,tandoor,lassi,kadai,table,table,table,chai_lvl60,tandoor_lvl55,lassi_lvl52,kadai_lvl30"
COMMON="--fresh --skip-tutorial --no-notes --stats=30 --window=600 --d4-every=1 --quit-at=905"
for s in 1 2; do
  $Q/run.sh d4_m$s $L/mid_s$s.log 600 -- $COMMON --money=2000 --buy="$MID" --seed=$s &
  $Q/run.sh d4_m$((s+2)) $L/full_s$s.log 600 -- $COMMON --money=20000 --buy="$FULL" --signboard=1 --claims=25 --seed=$s &
done
wait
echo ALLDONE
