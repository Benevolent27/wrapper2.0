#!/bin/bash
scriptdir=~/scripts/
if [ "$1" ]; then
"$scriptdir"sendraw2.sh /player_info $1 | grep -o ' PERSONAL-TEST-SECTOR: ('.[0-9]*', '.[0-9]*', '.[0-9]* | sed 's/PERSONAL-TEST-SECTOR: (//g' | sed 's/,//g' | sed 's/^.//g'
else
echo 'Usage: playerBattleModeSector.sh [playername]'
fi
