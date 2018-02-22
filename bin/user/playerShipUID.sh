#!/bin/bash
scriptDir=~/scripts/
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
if [ "$1" ]; then
	player="$1"
	playerShip=$("$scriptDir"user/playerShip.sh "$player")
	# echo "Ship Found: "$playerShip
	if [ "$playerShip" ]; then
		# echo "Looking up ship UID.."
		playerShipUID=$("$scriptDir"user/getShipUIDFromName.sh "$playerShip")
	fi
	# playerShipUID=$("$scriptDir"sendraw2.sh /ship_info_name \'\"$playerShip\"\' | grep -oE 'RETURN\: \[SERVER\, UID\: ([0-9A-Za-z_\-]|[[:blank:]])*' | sed 's/RETURN\: \[SERVER, UID\: //g')
	# echo "Ship UID found: "$playerShipUID

	if [ "$playerShipUID" ]; then
		echo "$playerShipUID"
	fi
else
	echo "No Player name provided!  Usage: playerShip.sh [Player Name]"
fi
IFS=$SAVEIFS
# sendraw2 /ship_info_name Insurance | grep -oe 'RETURN\: \[SERVER\, UID\: ([0-9A-Za-z_\-]|[[:blank:]])*' | sed 's/RETURN\: \[SERVER, UID\: //g'
