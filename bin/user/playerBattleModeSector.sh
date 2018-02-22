#!/bin/bash
scriptdir=~/scripts/
if [ "$1" ]; then
echo "-"$("$scriptdir"sendraw2.sh /player_info $1 | grep -o ' PERSONAL-BATTLE_MODE-SECTOR: ('.[0-9]*', '.[0-9]*', '.[0-9]* | sed 's/PERSONAL-BATTLE_MODE-SECTOR: [(]//g' | sed 's/,//g' | sed 's/^.//g')
else
echo 'Usage: playerBattleModeSector.sh [playername]'
fi
