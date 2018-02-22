#!/bin/bash
scriptdir=~/scripts/
if [ "$1" ]; then
"$scriptdir"sendraw2.sh /player_info $1 | grep -o ' SECTOR: ('.[0-9]*', '.[0-9]*', '.[0-9]* | sed 's/SECTOR: (//g' | sed 's/,//g' | sed 's/^.//g'
else
echo 'Usage: playerCoords.sh [playername]'
fi
