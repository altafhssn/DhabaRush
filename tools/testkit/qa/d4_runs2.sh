#!/bin/bash
Q=${DR_WORK:-$HOME/DhabaRushQA}/qa
L=$Q/logs/d4
MID="waiter,waiter,tandoor,lassi,table,chai_lvl30,tandoor_lvl26,lassi_lvl12"
FULL="waiter,waiter,tandoor,lassi,kadai,table,table,table,chai_lvl60,tandoor_lvl55,lassi_lvl52,kadai_lvl30"
COMMON="--fresh --skip-tutorial --no-notes --stats=30 --window=600 --d4-every=1 --quit-at=905"
$Q/run.sh d4_k1 $L/k125_mid_s1.log 900 -- $COMMON --money=2000 --buy="$MID" --seed=1 &
$Q/run.sh d4_k2 $L/k125_full_s1.log 900 -- $COMMON --money=20000 --buy="$FULL" --signboard=1 --claims=25 --seed=1 &
$Q/run.sh d4_p1 $L/buy_mid_s1.log 900 -- $COMMON --money=2000 --buy="$MID" --seed=1 --d4-buy="300:galla;600:tandoor_hire" &
$Q/run.sh d4_p2 $L/buy_full_s1.log 900 -- $COMMON --money=20000 --buy="$FULL" --signboard=1 --claims=25 --seed=1 --d4-buy="300:signboard;600:galla" &
wait
$Q/run.sh d4_a1 $L/arr_mid_s1.log 900 -- $COMMON --money=2000 --buy="$MID" --seed=1 --arrivals=18 &
$Q/run.sh d4_a2 $L/arr_full_s1.log 900 -- $COMMON --money=20000 --buy="$FULL" --signboard=1 --claims=25 --seed=1 --arrivals=30 &
$Q/run.sh d4_g1 $L/fullg_s1.log 900 -- $COMMON --money=20000 --buy="$FULL,galla" --signboard=1 --claims=25 --seed=1 &
$Q/run.sh d4_g2 $L/fullg_s2.log 900 -- $COMMON --money=20000 --buy="$FULL,galla" --signboard=1 --claims=25 --seed=2 &
wait
echo ALLDONE
