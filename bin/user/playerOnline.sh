#!/bin/bash
# Usage playerOnline.sh [PlayerName]

scriptDir=~/scripts/

if [ "$1" == "-i" ]; then
	insensitive="true"
	shift
fi


if [ "$1" ]; then

	results="$("$scriptDir"users.sh)"

	for b in $results; do
		playerName=$(echo $b | tr -d '\r\n')
		if ! [ "$result" ]; then
			if [ "$insensitive" == "true" ]; then
				result="$(echo $playerName | grep -io "$1")"
				if ! [ "$playerName" == "$result" ]; then
					unset result
				fi
			else
				result="$(echo $playerName | grep -o "$1")"
				if ! [ "$playerName" == "$result" ]; then
					unset result
				fi
			fi
		fi
	done
	
	if [ "$result" ]; then
		echo "true"
	else
		echo "false"
	fi
	
else
	echo "Usage playerOnline.sh [PlayerName]"
fi