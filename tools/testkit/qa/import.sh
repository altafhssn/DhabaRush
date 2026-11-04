#!/bin/bash
# Re-import a slot after new assets / class_names (never on the real project). Usage: import.sh SLOT
Q="$(cd "$(dirname "$0")" && pwd)"
. "$Q/sem.sh"
cd "$Q/slots/$1" || exit 2
sem_acquire godot "${GODOT_SLOTS:-4}"
HOME="$Q/slots/$1/home" perl -e 'alarm shift; exec @ARGV' 600 /Applications/Godot.app/Contents/MacOS/Godot --headless --path proj --import > import.log 2>&1
RC=$?; sem_release
echo "import rc=$RC (log $Q/slots/$1/import.log)"; grep -c "ERROR" import.log || true
