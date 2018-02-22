#!/bin/bash
scriptdir=~/scripts/
if [ "$1" ]; then
	# result="$("$scriptdir"sendraw2.sh /player_info $1 | grep -o ' CONTROLLING-POS: ('.[0-9]*\.[0-9]*', '.[0-9]*\.[0-9]*', '.[0-9]*\.[0-9]* | sed 's/CONTROLLING-POS: (//g' | sed 's/,//g' | sed 's/^.//g')"
	theCoords="$("${scriptdir}sendraw2.sh" /player_info $1 | grep -Po ' CONTROLLING-POS: \([0-9\-\.,E ]*\),' | sed 's/CONTROLLING-POS: (//g' | sed 's/),$//g' | sed 's/,//g' | sed 's/^\ //g')"
	
	theCoordsResults=()
	for b in ${theCoords}; do
		if [ "$(echo ${b} | grep "E")" ]; then
			theCoordsResults+=("0")
		else
			theCoordsResults+=("${b}")
		fi
		
	done
	# echo ${theCoords}
	echo ${theCoordsResults[*]}

	
	#| sed 's/^.//g')"
	
else
	echo 'Usage: playerCoords.sh [playername]'
fi
