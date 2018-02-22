#!/bin/bash
scriptDir=~/scripts/

if [ "$1" ]; then
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
	result=$("$scriptDir"sendraw2.sh /ship_info_uid $1 | grep '^RETURN: \[SERVER, Loaded\: true')

	# results=$("$scriptDir"sendraw2.sh /ship_info_uid $1)
	# for b in $results ; do
	# 	if ! [ "$result" ]; then
	# 		result=$(echo $b | grep '^RETURN: \[SERVER, Loaded\: true')
	# 	fi
	# done
	if [ "$result" ]; then
		echo true
	else
		echo false
	fi
	IFS=$SAVEIFS
else
echo "Usage: getShipUIDMass.sh [shipname]"
fi