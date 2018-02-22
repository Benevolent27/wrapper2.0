#!/bin/bash
scriptDir=~/scripts/

function breakCoords {
# IFS=" "
# set $initialCoords
X=$1
Y=$2
Z=$3
XF=$4
YF=$5
ZF=$6
}

if [ "$4" ]; then
initialCoords=$("$scriptDir"user/movePlayerAstronaut.sh "$1" "$2" "$3" "$4")
breakCoords $initialCoords
# echo "X "$X
# echo "Y "$Y
# echo "Z "$Z
# echo "XF "$XF
# echo "YF "$YF
# echo "ZF "$ZF
sleep 10
echo "Changing the spacial coords of the player "$1 $XF $YF $ZF
"$scriptDir"sendraw2.sh /teleport_to $1 $XF $YF $ZF
sleep 0.1
echo "Teleporting user back "$1 $X $Y $Z
"$scriptDir"sendraw2.sh /change_sector_for $1 $X $Y $Z

else
echo "Usage:  movePlayerTest.sh [Player Name] [X] [Y] [Z]"
fi