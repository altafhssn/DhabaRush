#!/bin/bash
# The real save must never change. Usage: savecheck.sh
EXP=0df78beb11133c66873437f0b54b2108
F="/Users/almeer/Library/Application Support/Godot/app_userdata/Dhaba Rush/save3.json"
GOT=$(md5 -q "$F")
if [ "$GOT" = "$EXP" ]; then echo "SAVE OK"; else echo "SAVE CHANGED: $GOT (expected $EXP)"; exit 1; fi
