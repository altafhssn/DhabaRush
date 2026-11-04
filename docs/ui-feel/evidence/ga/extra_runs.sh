#!/bin/bash
# GA extra runs (final prototype code, slots ga_x1..4). Each flag set is written out in full for a checker.
Q=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa
L=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/design_work/ga/logs
PKG="--ga-k=1.2 --ga-rush=1.5 --ga-cashline=4 --ga-cue-all --ga-dampmin=1"
NEWB="tandoor,galla,waiter,table,chai_lvl12,chai_speed,galla_up"
FULLB="waiter,waiter,tandoor,lassi,kadai,table,table,table,chai_lvl60,tandoor_lvl55,lassi_lvl52,kadai_lvl30"
COMMON="--fresh --skip-tutorial --no-notes --stats=60 --d4-every=1 --quit-at=905"
# 1 FULLG with the final code (seed 1)
$Q/run.sh ga_x1 $L/pkg_FULLG_s1.log 600 -- $COMMON --money=20000 --buy=$FULLB,galla --signboard=1 --claims=25 --window=840 --seed=1 $PKG &
# 2 the tutorial with every package flag on (suite flags of tut_en_s1)
$Q/run.sh ga_x2 $L/tut_pkg_s1.log 600 -- --fresh --auto --seed=1 --window=600 --stats=120 --quit-at=820 --d4-every=1 $PKG &
# 3 A7 stand-in: hold the tandoor for each whole rush (90 s) at 1.5x (newcomer, seed 1)
$Q/run.sh ga_x3 $L/hold_NEW_s1.log 600 -- $COMMON --money=1000 --buy=$NEWB --speed=2 --window=300 --seed=1 $PKG --ga-hold-rush=tandoor:90:1.5 &
# 4 the fix under the package: the newcomer with a 2nd tandoor cook (D3's cook test, seed 1)
$Q/run.sh ga_x4 $L/hire_NEW_s1.log 600 -- $COMMON --money=1000 --buy=$NEWB,tandoor_hire --speed=2 --window=300 --seed=1 $PKG &
wait
# 5 A7 stand-in on the full dhaba at the road cap: hold the kadai for each whole rush at 1.5x
$Q/run.sh ga_x1 $L/hold_FULLG_s1.log 600 -- $COMMON --money=20000 --buy=$FULLB,galla --signboard=1 --claims=25 --window=840 --seed=1 $PKG --ga-hold-rush=kadai:90:1.5
echo DONE extra
