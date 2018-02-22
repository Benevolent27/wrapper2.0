#!/bin/bash
scriptDir=~/scripts/

if [ "$1" ]; then
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
	result=$("$scriptDir"sendraw2.sh /ship_info_name $1 | grep '^RETURN: \[SERVER, \[INFO\] '$1' found in loaded')

	#RETURN: [SERVER, [INFO] Bama found in loaded
	
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