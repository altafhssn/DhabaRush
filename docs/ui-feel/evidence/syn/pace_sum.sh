#!/bin/bash
# One line per pacing output: all 16 dishes | end (NH 48) | binds per stage | floor binds | busiest >= 0.90 | sign buys
cd /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/design_work/syn/pace
for f in "$@"; do
  n=$(basename $f .txt)
  a=$(grep -m1 "renovation unlocks (all 16 dishes)" $f | awk '{print $NF}')
  e=$(grep -m1 "NH 48: all 16 dishes" $f | awk '{print $NF}')
  b=$(grep -m1 "binds per stage" $f | sed 's/.*binds per stage: //' | cut -c1-70)
  fb=$(grep -m1 "GARUSH floor binds" $f | sed 's/GARUSH floor binds: //')
  bz=$(grep -m1 "GARUSH all: busiest" $f | sed 's/.*>=0.90 //')
  sb=$(grep -o '"sign_buys": \[[^]]*\]' $f | grep -o '"stage": [0-9], "level": [0-9]' | awk '{printf "%s%s ", $2, $4}')
  echo "$n | $a $e | $b | floor $fb | busiest>=0.9 $bz | sign(stage,level) $sb"
done
