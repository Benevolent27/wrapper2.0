#!/bin/bash
scriptDir=~/scripts/
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
if [ "$1" ]; then
	player="$1"
	playerStation=$("$scriptDir"sendraw2.sh /player_info $player | grep -oE 'RETURN\: \[SERVER, \[PL\] CONTROLLING\: SpaceStation\[([0-9A-Za-z_\-]|[[:blank:]])*' | sed 's/RETURN\: \[SERVER, \[PL\] CONTROLLING\: SpaceStation\[//g')
	if [ "$playerStation" ]; then
		echo "$playerStation"
	fi
else
	echo "No Player name provided!  Usage: playerStation.sh [Player Name]"
fi
IFS=$SAVEIFS