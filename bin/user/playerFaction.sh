#!/bin/bash
# Example outputs:
# This script is meant to be run inline if grabbing more than one piece of information.
# It can return the faction number, name, description, size, and faction points.
# To run the script 'inline', an example run is: . playerFaction.sh [PlayerName]
# If no type of info is specified, then the faction number is returned since this is used most often.


# NEEDS FIXING  - This script will NOT work correctly if the faction they belong to has a description that is more than one line long.  The REGEX needs to be updated to account for this!
# example:
# RETURN: [SERVER, [PL] FACTION: Faction [id=10047, name=Outer Darkness, description=In peace, there is stagnation.
# But in war, there is honor.
# In violence, there is retribution.
# Through conflict, we grow stronger., size: 7; FP: 238947], 0]

# Example 2 - the "description has "a faction" on one line and  ", size: 7; FP: 238947], 0]" on another and then a space on the third line:
# RETURN: [SERVER, [PL] FACTION: Faction [id=10256, name=Weedle, description=a faction
# , size: 7; FP: 238947], 0]
# , size: 1; FP: 100], 0]
# RETURN: [SERVER, [PL] CREDITS: 50000, 0]


# Needs doing - a "-rank" option needs to be added here.



scriptDir=~/scripts/
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

if [ "$1" == "-number" ]; then
	output=number
	shift
elif [ "$1" == "-name" ]; then
	output=name
	shift
elif [ "$1" == "-description" ]; then
	output=description
	shift
elif [ "$1" == "-size" ]; then
	output=size
	shift
elif [ "$1" == "-points" ]; then
	output=points
	shift
else
	output=default
fi


if [ "$1" ]; then
	# player="$1"
	# playerFactionplayer
	# playerFactionNumber
	# playerFactionName
	# playerFactionDescription
	# playerFactionSize
	# playerFactionPoints
	# playerFactionFull
	
	# When the script is run inline it can reuse the same information for a player rather than do another call for the info.  This will speed things up considerably if the script is being used to return multiple points of info about a player's faction.
	# Check to see if all the variables already exist
	if ! [ "$playerFactionplayer" == "$1" -a "$playerFactionFull" ]; then
		playerFactionplayer="$1"
		# echo "Grabbing Faction info.."
		playerFactionFull=$("$scriptDir"sendraw2.sh /player_info $playerFactionplayer | grep -E '^RETURN\: \[SERVER, \[PL\] FACTION\: Faction \[id=[0-9]*')
		# echo "Result: $playerFactionFull"
	fi

	
	# result=$("$scriptDir"sendraw2.sh /player_info $player | grep -oE '^RETURN\: \[SERVER, \[PL\] FACTION\: Faction \[id=.*' | sed "s/^RETURN\: \[SERVER, \[PL\] FACTION\: Faction \[id=//g" | sed 's/, name=[0-9A-Za-z_\-\.], description=[0-9A-Za-z_\-\.], size: [0-9]*; FP: [0-9]*, 0]$//g')
	
	# ([0-9A-Za-z_\-]|[[:blank:]])
	
	if [ "$output" == "number" -o "$output" == "default" ]; then
		# done
		playerFactionNumber=$(echo "$playerFactionFull" | grep -oE '^RETURN\: \[SERVER, \[PL\] FACTION\: Faction \[id=((-|))[0-9]*' | sed "s/^RETURN\: \[SERVER, \[PL\] FACTION\: Faction \[id=//g")
		if [ "$playerFactionNumber" ]; then
			echo "$playerFactionNumber"
		fi
	elif [ "$output" == "name" ]; then
		# done
		playerFactionName=$(echo "$playerFactionFull" | grep -oE '^RETURN\: \[SERVER, \[PL\] FACTION\: Faction \[id=[0-9]*, name=([0-9A-Za-z_\-]|[[:blank:]])*' | sed "s/^RETURN\: \[SERVER, \[PL\] FACTION\: Faction \[id=[0-9]*, name=//g")
		if [ "$playerFactionName" ]; then
			echo "$playerFactionName"
		fi
	elif [ "$output" == "description" ]; then
		playerFactionDescription=$(echo "$playerFactionFull" | grep -oE 'description=([0-9A-Za-z_\-\.]|[[:blank:]])*' | sed "s/description=//g")
		if [ "$playerFactionDescription" ]; then
			echo "$playerFactionDescription"
		fi
	elif [ "$output" == "size" ]; then
		playerFactionSize=$(echo "$playerFactionFull" | grep -o 'size: [0-9]*' | sed "s/size:\ //g")
		if [ "$playerFactionSize" ]; then
			echo "$playerFactionSize"
		fi
	elif [ "$output" == "points" ]; then
		playerFactionPoints=$(echo "$playerFactionFull" | grep -o 'FP: [0-9]*' | sed "s/FP:\ //g")
		if [ "$playerFactionPoints" ]; then
			echo "$playerFactionPoints"
		fi
	fi

else
	echo "No Player name provided!  Usage: playerFhip.sh (-number/-name/-description/-size/-points) [Player Name]"
fi
IFS=$SAVEIFS