#!/bin/bash
scriptDir=~/scripts/
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
if [ "$1" ]; then
	player="$1"
	playerShip=$("$scriptDir"sendraw2.sh /player_info $player | grep -oE 'RETURN\: \[SERVER, \[PL\] CONTROLLING\: Ship\[([0-9A-Za-z_\-]|[[:blank:]])*' | sed 's/RETURN\: \[SERVER, \[PL\] CONTROLLING\: Ship\[//g')
	# working for spaces but not dashes..
	# playerShip=$("$scriptDir"sendraw2.sh /player_info $player | grep -oe 'RETURN\: \[SERVER, \[PL\] CONTROLLING\: Ship\[[0-9A-Za-z_\-|[:blank:]]*' | sed 's/RETURN\: \[SERVER, \[PL\] CONTROLLING\: Ship\[//g')
	# playerShip=$("$scriptDir"sendraw2.sh /player_info $player | grep -oe 'RETURN\: \[SERVER, \[PL\] CONTROLLING\: Ship\[[0-9A-Za-Z_]*' | sed 's/RETURN\: \[SERVER, \[PL\] CONTROLLING\: Ship\[//g')
	# ([0-9A-Za-z_\-]|[[:blank:]])

	if [ "$playerShip" ]; then
		echo "$playerShip"
	fi
else
	echo "No Player name provided!  Usage: playerShip.sh [Player Name]"
fi
IFS=$SAVEIFS