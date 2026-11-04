#!/bin/bash
# GA measurement runner. Usage: runs.sh TAG KIND "SETUPS" "SEEDS" [extra game flags...]
#   KIND b = today (slots ga_b1..4, untouched code + probe), p = package prototype (slots ga_p1..4)
#   SETUPS from: NEW MID FULL FULLG ; SEEDS e.g. "1 2 3 4"
# Logs: design_work/ga/logs/<TAG>_<SETUP>_s<SEED>.log. Runs 4 at a time (run.sh's machine-wide lock).
Q=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa
L=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/design_work/ga/logs
TAG="$1"; KIND="$2"; SETUPS="$3"; SEEDS="$4"; shift 4
NEWB="tandoor,galla,waiter,table,chai_lvl12,chai_speed,galla_up"
MIDB="waiter,waiter,tandoor,lassi,table,chai_lvl30,tandoor_lvl26,lassi_lvl12"
FULLB="waiter,waiter,tandoor,lassi,kadai,table,table,table,chai_lvl60,tandoor_lvl55,lassi_lvl52,kadai_lvl30"
COMMON="--fresh --skip-tutorial --no-notes --stats=60 --d4-every=1 --quit-at=905"
mkdir -p "$L"
i=0
for st in $SETUPS; do
  for s in $SEEDS; do
    if [ $i -ge 4 ]; then wait; i=0; fi
    i=$(( i + 1 ))
    case $st in
      NEW) A="--money=1000 --buy=$NEWB --speed=2 --window=300";;
      MID) A="--money=2000 --buy=$MIDB --window=840";;
      FULL) A="--money=20000 --buy=$FULLB --signboard=1 --claims=25 --window=840";;
      FULLG) A="--money=20000 --buy=$FULLB,galla --signboard=1 --claims=25 --window=840";;
    esac
    $Q/run.sh ga_${KIND}$i "$L/${TAG}_${st}_s$s.log" 600 -- $COMMON $A --seed=$s "$@" &
    sleep 0.3
  done
done
wait
echo "DONE $TAG"
