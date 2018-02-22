#!/bin/bash
scriptDir=~/scripts/
melvin_chat="$scriptDir"wrapper/melvin_chat.sh

# This can be changed in the future to instead of truncating the numbers to remove decimals, it can do a direct compare of the values with decimals
# Example:   echo 0.5 '>' 1 | bc -l

# These are the spacial coordinates the "hell" area is in on the server, which is the lava pit in the claws.
# Xs1=-148
# Xs2=-145
# Ys1=-6
# Ys2=-4
# Zs1=154
# Zs2=157

# build the coords
if [ "$1" == "-spacial" ]; then
	# echo "-spacial flag set.."
	playerCoordsSector=$(echo $@ | awk '{ print ($2 " " $3 " " $4) }')
	# echo "playerCoordsSector set to: $playerCoordsSector"
	shift
	shift
	shift	
fi

everything="$@"
counter=0
Xs1=$(echo $everything | awk '{ print ($2) }')
Xs1=${Xs1%.*}
Ys1=$(echo $everything | awk '{ print ($3) }')
Ys1=${Ys1%.*}
Zs1=$(echo $everything | awk '{ print ($4) }')
Zs1=${Zs1%.*}

Xs2=$(echo $everything | awk '{ print ($5) }')
Xs2=${Xs2%.*}
Ys2=$(echo $everything | awk '{ print ($6) }')
Ys2=${Ys2%.*}
Zs2=$(echo $everything | awk '{ print ($7) }')
Zs2=${Zs2%.*}

# 1 is small, 2 is bigger
if [ "$Xs1" -gt "$Xs2" ]; then
	xTemp="$Xs1"
	Xs1="$Xs2"
	Xs2="$xTemp"
	unset xTemp
fi
if [ "$Ys1" -gt "$Ys2" ]; then
	yTemp="$Ys1"
	Ys1="$Ys2"
	Ys2="$yTemp"
	unset yTemp
fi
if [ "$Zs1" -gt "$Zs2" ]; then
	zTemp="$Zs1"
	Zs1="$Zs2"
	Zs2="$zTemp"
	unset zTemp
fi


if [ "$Zs2" ]; then
	if ! [ "$playerCoordsSector" ]; then
		name="$1"
		playerCoordsSector="$("$scriptDir"user/playerCoordsSector.sh $name)"
	fi
	playerCoordsSectorX=$(echo $playerCoordsSector | awk '{ print ($1) }')
	playerCoordsSectorX=${playerCoordsSectorX%.*}
	playerCoordsSectorY=$(echo $playerCoordsSector | awk '{ print ($2) }')
	playerCoordsSectorY=${playerCoordsSectorY%.*}
	playerCoordsSectorZ=$(echo $playerCoordsSector | awk '{ print ($3) }')
	playerCoordsSectorZ=${playerCoordsSectorZ%.*}
	
	# echo "Xs: "$playerCoordsSectorX
	# echo "Ys: "$playerCoordsSectorY
	# echo "Zs: "$playerCoordsSectorZ
	
	# echo "Comparing $playerCoordsSectorX with $Xs2 and $Xs1"
	if [ "$playerCoordsSectorX" -le $Xs2 ] && [ $playerCoordsSectorX -ge $Xs1 ]; then
		xCheck=true
	fi
	if [ "$playerCoordsSectorY" -le $Ys2 ] && [ $playerCoordsSectorY -ge $Ys1 ]; then
		yCheck=true
	fi
	if [ "$playerCoordsSectorZ" -le $Zs2 ] && [ $playerCoordsSectorZ -ge $Zs1 ]; then
		zCheck=true
	fi
	if [ "$xCheck" -a "$yCheck" -a "$zCheck" ]; then
		# echo "Player is in the right place."
		echo "true"
	else
		# echo "Player is not in the right place."
		echo "false"
	fi
else
	echo "Usage: isPlayerBetweenSpacialCoords.sh [PlayerName] X Y Z X2 Y2 Z2"
	echo "Usage2: isPlayerBetweenSpacialCoords.sh -spacial PlayerX PlayerY PlayerZ X Y Z X2 Y2 Z2"
fi