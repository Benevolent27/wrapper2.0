#!/bin/bash
scriptDir=~/scripts/
SAVEIFS=$IFS
function set_IFS_no_spaces {
	IFS=$(echo -en "\n\b")
}
function reset_IFS {
	IFS=$SAVEIFS
}

if [ "$1" ]; then
	nameToCheck="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
	set_IFS_no_spaces
	users=$("${scriptDir}users.sh" | grep -i "$1" | grep -oP "[0-9A-Za-z_\-]*") # sed ':a;N;$!ba;s/\n/ /g')
	# echo "$users"
	for b in ${users}; do
		resultToCheck=$(echo $b | tr '[:upper:]' '[:lower:]')
		# echo "Checking $b by setting to lowercase $resultToCheck"
		if [ "${resultToCheck}" == "${nameToCheck}" ]; then
			echo "${b}"
		fi
		unset resultToCheck
	done
	reset_IFS
else
	echo "  This script is used to grab the name of an online player, correcting for case mismatches."
	echo "  Usage: getPlayerName.sh [playerName]"
	echo " "
	echo "  Example:  getPlayerName.sh benevolent27"
	echo "  This will return \"Benevolent27\"."
fi