#!/bin/bash
# Run Blender with a machine-wide limit of one Blender at a time (RAM). Usage: blender.sh <blender args...>
. ${DR_WORK:-$HOME/DhabaRushQA}/qa/sem.sh
sem_acquire blender 1
/Applications/Blender.app/Contents/MacOS/Blender "$@"
RC=$?; sem_release; exit $RC
