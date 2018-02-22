#!/bin/bash
scriptDir=~/scripts/

if ! [ "$1" ]; then
	echo "No player name provided!  Usage:  ./movePlayerAstronaut.sh [player name]"
	exit
fi

if ! [ "$4" ]; then
	echo "No coordinates given!  Usage:  ./movePlayerAstronaut.sh [player name]"
	exit
fi
questCoords="$2 $3 $4"


player=$("$scriptDir"sendraw2.sh /player_list | grep -oi $1 | tail -1)
if ! [ "$player" ]; then
	echo "Player is either not online or does not exist!  Exiting!"
	exit
fi

stripCoords=$("$scriptDir"user/playerBattleModeSector.sh $1)

# Returns if the player is in a ship, example:
# working example:  sendraw2 /player_info Benevolent27 | grep -oe 'RETURN\: \[SERVER, \[PL\] CONTROLLING\: Ship\[[0-9A-Za-Z_]*' | sed 's/RETURN\: \[SERVER, \[PL\] CONTROLLING\: Ship\[//g'
# shipName=$("$scriptDir"sendraw2.sh /player_info $player | grep -oe 'RETURN\: \[SERVER, \[PL\] CONTROLLING\: Ship\[[0-9A-Za-Z_]*' | sed 's/RETURN\: \[SERVER, \[PL\] CONTROLLING\: Ship\[//g')
shipName=$("$scriptDir"user/playerShip.sh "$player")
# echo "If in a ship it is called the following: "$shipName
# shipName="Benevolent27_1472257313102"

# Grab the player's coords:  
# playerCoords="$(~/scripts/user/playerCoords.sh Benevolent27)"
initialPlayerCoords="$("$scriptDir"user/playerCoords.sh $player)"
initialSpacialPlayerCoords="$("$scriptDir"user/playerCoordsSector.sh $player)"

#  Teleports a player to the sector with a copy of their ship - leaving the original behind if they were found to be in a ship, otherwise it just teleports them to the right coords.
# sendraw2 /change_sector_for_copy Benevolent27 2000 2008 2000 
if [ "$shipName" ]; then
	# echo "Player was in a ship!"
	garbage=$("$scriptDir"sendraw2.sh /change_sector_for_copy $player $stripCoords)
	tempCoords=$initialPlayerCoords
	while [ "$tempCoords" != "$stripCoords" ]; do
		tempCoords="$(~/scripts/user/playerCoords.sh $player)"
		# echo "Waiting for player to arrive at strip coords and checking to ensure the player is still online"
		if ! [ "$tempCoords" ]; then
			# echo "Player appears to have gone offline!  Terminating script!"
			exit
		fi
		sleep 1
	done
	# Removes only the COPY of the ship, but not the original that was left behind.  The variable being recalled CANNOT be exactly the ship name, so the script removes the last character from the name when removing it. Benevolent27_147245294546
	# sendraw2 /despawn_sector "Benevolent27_1472257313102" all true 2000 2008 2000
	# echo "Removing entity player is in, "$shipName" at coordinates, "$stripCoords
	 # sleep 0.5
	 # shortShipName=${shipName:0:24}
	 # shortShipName=${shortShipName%?}
	# echo "temp - Removing ship: "$shortShipName"|"
     # garbage=$("$scriptDir"sendraw2.sh /despawn_sector ${shipName:0:24} all true $stripCoords)
	 # "$scriptDir"sendraw2.sh /despawn_sector $shortShipName all true $stripCoords
	"$scriptDir"user/clear_sector_ships.sh -q $stripCoords
	# sleep 0.1
	 # garbage=$("$scriptDir"sendraw2.sh /despawn_sector $shortShipName all false $stripCoords)
	# echo "Sleeping for five seconds and then moving on.."
	sleep 5
	
	# This would then teleport the player to their final destination as an astronaut
	# sendraw2 /change_sector_for Benevolent27 2000 2000 2000
fi
# echo "Teleporting player, "$player" to final coordinates: "$questCoords
garbage=$("$scriptDir"sendraw2.sh /change_sector_for $player $questCoords)
echo "$initialPlayerCoords" "$initialSpacialPlayerCoords"