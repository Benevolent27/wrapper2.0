#!/bin/bash
scriptDir=~/scripts/

counter=1
if [ "$1" ]; then
	name="$1"
	args="$2"
	playerPersonalTestCoords="$(${scriptDir}user/playerPersonalTestSector.sh ${name})"
	
	for b in $playerPersonalTestCoords; do
		# echo "Checking $b and on counter $counter with args $args"
		if [ "$counter" == 1 ]; then
			if [ "$(echo ${args} | grep -i "X")" ] ; then
				mPTCNx="-${b}"
			else
				mPTCNx="${b}"
			fi
		fi

		if [ "$counter" == 2 ]; then
			if [ "$(echo ${args} | grep -i "Y")" ]; then
				mPTCNy="-${b}"
			else
				mPTCNy="${b}"
			fi
		fi

		if [ "$counter" == 3 ]; then
			if [ "$(echo ${args} | grep -i "Z")" ]; then
				mPTCNz="-${b}"
			else
				mPTCNz="${b}"
			fi
		fi
		let counter++
	done
	echo "${mPTCNx} ${mPTCNy} ${mPTCNz}"
else
echo "Usage makePersonalTestCoordsNegative.sh [username] [X,Y,Z]"
fi
