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
	# playerShip=$("$scriptDir"sendraw2.sh /player_info $player | grep -oE 'RETURN\: \[SERVER, \[PL\] CONTROLLING\: [0-9A-Za-z_\-]\[([0-9A-Za-z_\-]|[[:blank:]])*' # | sed 's/RETURN\: \[SERVER, \[PL\] CONTROLLING\: [0-9A-Za-z_\-]\[//g')
	
	results=$("$scriptDir"sendraw2.sh /player_info $player | grep -oE '^RETURN\: \[SERVER, \[PL\] CONTROLLING\:.*' | sed "s/^RETURN\: \[SERVER, \[PL\] CONTROLLING\:.//g" | sed 's/, 0\]//g')
	result=

	# echo "Command sent.."
	for b in $results; do
	# echo "Checking result: "$b
		if ! [ "$result" ]; then
			# echo "Checking if ship.."
			result=$(echo $b | grep -E 'Ship\[([0-9A-Za-z_\-]|[[:blank:]])*\]\([0-9]*\)' | grep -oE 'Ship\[([0-9A-Za-z_\-]|[[:blank:]])*\]' )
			if ! [ "$result" ]; then
				# Space Station:  1000 1000 1000
				# example:  SpaceStation[ENTITY_SPACESTATION_Admin Central(628)]
				result=$(echo $b | grep -E '^SpaceStation\[ENTITY_SPACESTATION_([0-9A-Za-z_\-]|[[:blank:]])*\([0-9]*\)\]' | sed -e 's/[(][0-9]*[)]//g' )
				# result=$(echo $b | grep -E 'SpaceStation\[ENTITY_SPACESTATION_Admin Central\(628\)\]' )
				if ! [ "$result" ]; then
					# Asteroid:  10120 10242 10021
					# Result example:  ManagedAsteroid(23869)sec[23393](!)
					result=$(echo $b | grep -E "ManagedAsteroid\([0-9]*\)sec\[[0-9]*\]\(\!\)" | sed 's/sec\[[0-9]*\][(]\![)]//g')
					
					if ! [ "$result" ]; then
						# Planet:  10120 10242 10022
						#Result example: Planet(843)[s836]Planet Testing Testing One Two Three (r67)[10000000hp]
						# echo "Checking b: "$b
						result=$(echo $b | grep -E "^Planet\([0-9]*\)\[s[0-9]*\]" | sed 's/[(][0-9]*[)]//g' | sed 's/s[0-9]*\]Planet //g' | sed 's/ [(]r[0-9]*[)]\[[0-9]*hp//g' | grep -o Planet )
						# sed 's/\[\]//g' )
						# RETURN: [SERVER, [PL] CONTROLLING: Planet(341)[s309]none, 0]
						# RETURN: [SERVER, [PL] CONTROLLING: Planet(484)[s473]Planet  (r64)[10000000hp], 0]
						
						# old:  result=$(echo $b | grep -E "Planet\([0-9]*\)\[s[0-9]*\]Planet .* \(r[0-9]*\)\[[0-9]*hp\][0-9]*" | sed 's/[(][0-9]*[)]//g' | sed 's/s[0-9]*\]Planet //g' | sed 's/ [(]r[0-9]*[)]\[[0-9]*hp//g' )
						
					fi
				fi
		
			fi
	
	
		fi
	# (SpaceStation|Ship| ManagedAsteroid\([0-9]*\)sec\[[0-9]*\]\(\!\))\[([0-9A-Za-z_\-]|[[:blank:]])*' | sed -r 's/RETURN\: \[SERVER, \[PL\] CONTROLLING\: (SpaceStation|Ship| ManagedAsteroid)\[//g')
	
	done
	# working for spaces but not dashes..
	# playerShip=$("$scriptDir"sendraw2.sh /player_info $player | grep -oe 'RETURN\: \[SERVER, \[PL\] CONTROLLING\: Ship\[[0-9A-Za-z_\-|[:blank:]]*' | sed 's/RETURN\: \[SERVER, \[PL\] CONTROLLING\: Ship\[//g')
	# playerShip=$("$scriptDir"sendraw2.sh /player_info $player | grep -oe 'RETURN\: \[SERVER, \[PL\] CONTROLLING\: Ship\[[0-9A-Za-Z_]*' | sed 's/RETURN\: \[SERVER, \[PL\] CONTROLLING\: Ship\[//g')
	# ([0-9A-Za-z_\-]|[[:blank:]])

	if [ "$result" ]; then
		if [ "$output" == "full" ]; then
			echo "$result"
		elif [ "$output" == "type" ]; then
			echo $(echo "$result" | sed -e 's/\[.*\]//g' ) | sed 's/^Managed//g' | sed 's/[(][0-9]*[)]//g'
		fi
	fi
else
	echo "No Player name provided!  Usage: playerShip.sh [Player Name]"
fi
IFS=$SAVEIFS