#!/bin/bash
# GB pacing what-ifs (read-only use of tools/sim/pacing_v3.py). Usage: pace.sh NAME [pacing args]
W=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/design_work/gb
N="$1"; shift
cd /Users/almeer/Documents/HighwayDhaba && /Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B tools/sim/pacing_v3.py --promo --minutes 100 "$@" > "$W/pace/$N.txt" 2>&1
echo "$N: $(grep -h 'renovation unlocks (all 16' $W/pace/$N.txt | awk '{print $NF}') / $(grep -h 'NH 48: all 16' $W/pace/$N.txt | awk '{print $NF}') | $(grep -h 'binds per stage' $W/pace/$N.txt | sed 's/^ *//')"
