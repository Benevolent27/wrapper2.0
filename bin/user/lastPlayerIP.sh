#!/bin/bash
if [ "$1" ]; then

# RETURN: [SERVER, [PL] LOGIN: [time=Fri Feb 10 23:44:00 EST 2017, ip=/[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*,
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")

	results=$(~/scripts/sendraw2.sh /player_info "$1")
	counter=1
	for b in $results; do
		if ! [ ${stop} ]; then
			# result=$(echo $b | grep "^RETURN\: \[SERVER, \[PL\] LOGIN\:.*, ip=/[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*," | sed 's/RETURN: \[SERVER, \[PL\] LOGIN:.*, ip=//g' | sed 's/^\///g' | sed 's/, starmadeName=.*,.*]$//g' | sed ':a;N;$!ba;s/\n//g' | sed 's/\r//g')
			result=$(echo $b | grep "^RETURN\: \[SERVER, \[PL\] LOGIN\:.*, ip=/[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*," | sed 's/RETURN: \[SERVER, \[PL\] LOGIN:.*, ip=//g' | sed 's/^\///g' | sed 's/, starmadeName=.*\], .*$//g' | sed ':a;N;$!ba;s/\n//g' | sed 's/\r//g')
			# /24.17.211.135, starmadeName=Samwiz1], 0]
			if [ "$result" ]; then
				stop=stop
				echo ${result}
			fi
		fi
	done
	IFS=$SAVEIFS

else
	echo 'Usage: lastPlayerIP.sh [PlayerName]'
fi
