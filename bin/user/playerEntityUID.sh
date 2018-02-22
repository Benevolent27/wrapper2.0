#!/bin/bash
# Example outputs:
# If in a ship:  Ship[Two  Spaces]
# If in an asteroid:  ManagedAsteroid(1274)
# If in an planet:  Planet[Testing Two  Spaces - dashes _ underscores]
# If in an base:  SpaceStation[ENTITY_SPACESTATION_Admin Central]





scriptDir=~/scripts/
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

if [ "$1" == "-type" ]; then
	output=type
	shift
else
	output=full
fi


if [ "$1" ]; then
	player="$1"
	playerEntity=$("$scriptDir"user/playerEntity.sh $player)
	# echo "Grabbing entity info: "$playerEntity
	if [ "$(echo $playerEntity | grep '^Ship' )" ]; then
		# echo "Ship found: "$playerEntity
		
		# Broke on ship result:  RETURN: [SERVER, [PL] CONTROLLING: Ship[-Harvester_Of_Souls-_1477677927690](13258), 0]'
		
		# this was broken for some reason, so the method of getting the ship name was changed to simply remove the formatting from around it.
		# result="$(echo "$playerEntity" | grep -oE '^Ship\[([0-9A-Za-z_\-\.]|[[:blank:]])*' | sed 's/^Ship\[//g')"
		result="$(echo "$playerEntity" | sed 's/^Ship\[//g' | sed 's/]$//g' )"
		
		if [ "$result" ]; then
			result="$("$scriptDir"user/getShipUIDFromName.sh "$result")"
		fi
		
		# IF NEEDING TO REMOVE THE TOP SOLUTION - WHICH SHOULD NOT BE NECESSARY - HERE IS THE PREMADE SCRIPT:  This is not preferred, because this makes extra calls out to the server and is slower.  It would be better to ensure this script can handle things.
		# result="$(${scriptDir}user/playerShipUID.sh $name)"
		
	elif [ "$(echo $playerEntity | grep '^ManagedAsteroid')" ]; then
		# result="$(echo "$playerEntity" | grep -oE '^ManagedAsteroid\[([0-9A-Za-z_\-\.]|[[:blank:]])*' | sed 's/^ManagedAsteroid\[//g')"
		
		# echo "Asteroid result found: "$playerEntity
		playerCoords="$("$scriptDir"user/playerCoords.sh $player)"
		# echo "Player Coords grabbed: "$playerCoords
		
		# echo "Player Spacial Coords grabbed: "$playerSpacialCoords
		
		IFS=$SAVEIFS
		asteroidResults=$("$scriptDir"sector/listAsteroidsInSector.sh -coords $playerCoords)
		playerSpacialCoords="$("$scriptDir"user/playerCoordsSector.sh $player)"
		
		counter=1
		for b in $asteroidResults; do
			
			if ! [ "$finalResult" ]; then
				if [ "$counter" == "1" ]; then
					resultAsteroid="$b"
					# echo "Plate set to: "$resultAsteroid
				elif [ "$counter" -ge 2 -a "$counter" -le 4 ]; then
					if [ "$resultAsteroidCoords" ]; then
						resultAsteroidCoords="$resultAsteroidCoords $b"
					else
						resultAsteroidCoords="$b"
					fi
					# echo "PlateCoords set: "$resultAsteroidCoords
				fi
				if [ "$counter" == "4" ]; then
					# Comparing the spacial coordinates of the plate to the player, because when a player is in a build block on a planet plate, it will match the exact location provided for the plate.
					if [ "$playerSpacialCoords" == "$resultAsteroidCoords" ]; then
						# echo "RESULT FOUND RESULT FOUND: "$finalResult
						finalResult="$resultAsteroid"
					else
						# echo "Damn, nothing found in that set, continuing to the next.."
						counter="0"
						unset resultAsteroidCoords
						unset resultAsteroid
					fi
				fi
				let counter++
			fi
			
		done
		
		
		# result="$(echo "$playerEntity" | grep -oE '^Planet\[([0-9A-Za-z_\-\.]|[[:blank:]])*' | sed 's/^Planet\[//g')"
		if [ "$finalResult" ]; then
			echo "$finalResult"
		else
			echo "asteroidError"
		fi
		
		
	elif [ "$(echo $playerEntity | grep '^Planet')" ]; then
		# echo "Planet result found: "$playerEntity
		playerCoords="$("$scriptDir"user/playerCoords.sh $player)"
		# echo "Player Coords grabbed: "$playerCoords
		playerSpacialCoords="$("$scriptDir"user/playerCoordsSector.sh $player)"
		# echo "Player Spacial Coords grabbed: "$playerSpacialCoords
		
		IFS=$SAVEIFS
		planetResults=$("$scriptDir"sector/listPlanetsInSector.sh -coords $playerCoords)
		
		counter=1
		for b in $planetResults; do
			
			if ! [ "$finalResult" ]; then
				if [ "$counter" == "1" ]; then
					resultPlate="$b"
					# echo "Plate set to: "$resultPlate
				elif [ "$counter" -ge 2 -a "$counter" -le 4 ]; then
					if [ "$resultPlateCoords" ]; then
						resultPlateCoords="$resultPlateCoords $b"
					else
						resultPlateCoords="$b"
					fi
					# echo "PlateCoords set: "$resultPlateCoords
				fi
				if [ "$counter" == "4" ]; then
					# Comparing the spacial coordinates of the plate to the player, because when a player is in a build block on a planet plate, it will match the exact location provided for the plate.
					if [ "$playerSpacialCoords" == "$resultPlateCoords" ]; then
						# echo "RESULT FOUND RESULT FOUND: "$finalResult
						finalResult="$resultPlate"
					else
						# echo "Damn, nothing found in that set, continuing to the next.."
						counter="0"
						unset resultPlateCoords
						unset resultPlate
					fi
				fi
				let counter++
			fi
			
		done
		
		
		# result="$(echo "$playerEntity" | grep -oE '^Planet\[([0-9A-Za-z_\-\.]|[[:blank:]])*' | sed 's/^Planet\[//g')"
		if [ "$finalResult" ]; then
			echo "$finalResult"
		fi
		
	elif [ "$(echo $playerEntity | grep '^SpaceStation\[')" ]; then
		result="$(echo "$playerEntity" | grep -oE '^SpaceStation\[([0-9A-Za-z_\-\.]|[[:blank:]])*' | sed 's/^SpaceStation\[//g')"
	fi
	if [ "$result" ]; then
		echo "$result"
	fi
	# example:  SpaceStation[ENTITY_SPACESTATION_Admin Central(628)]
	# Result example:  ManagedAsteroid(23869)sec[23393](!)
	# Result example: Planet(843)[s836]Planet Testing Testing One Two Three (r67)[10000000hp]
else
	echo "No Player name provided!  Usage: playerShip.sh [Player Name]"
fi
IFS=$SAVEIFS