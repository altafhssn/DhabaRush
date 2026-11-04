#!/bin/bash
# Put a save fixture into a QA slot's user dir (the slot's own HOME; never the real save).
# Usage: putsave.sh SLOT FIXTURE.json
Q=${DR_WORK:-$HOME/DhabaRushQA}/qa
D="$Q/slots/$1/home/Library/Application Support/DhabaRushQA"
mkdir -p "$D" && cp "$2" "$D/save3.json" && echo "save -> $D/save3.json"
