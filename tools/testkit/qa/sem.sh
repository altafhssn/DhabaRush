# Counting semaphore for heavy processes (sourced). sem_acquire CLASS N ; release happens on EXIT.
# Locks are dirs $Q/locks/CLASS.<i> holding the owner's pid; a dead owner's lock is reclaimed.
SEMDIR="${DR_WORK:-$HOME/DhabaRushQA}/qa/locks"
SEM_HELD=""
sem_release() { [ -n "$SEM_HELD" ] && rm -rf "$SEM_HELD"; SEM_HELD=""; }
sem_acquire() {
  local cls="$1" n="$2" i d p waited=0
  mkdir -p "$SEMDIR"
  while :; do
    for ((i=1;i<=n;i++)); do
      d="$SEMDIR/$cls.$i"
      if mkdir "$d" 2>/dev/null; then echo $$ > "$d/pid"; SEM_HELD="$d"; trap sem_release EXIT; return 0; fi
      p=$(cat "$d/pid" 2>/dev/null)
      if [ -n "$p" ]; then kill -0 "$p" 2>/dev/null || rm -rf "$d"
      elif [ -n "$(find "$d" -maxdepth 0 -mmin +1 2>/dev/null)" ]; then rm -rf "$d"; fi
    done
    sleep 0.5; waited=$((waited+1))
    [ $((waited % 240)) -eq 0 ] && echo "[sem] still waiting for a $cls slot ($((waited/2)) s)" >&2
  done
}
