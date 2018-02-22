#!/bin/bash
if [ "$1" ]; then

# RETURN: [SERVER, [PL] LOGIN: [time=Fri Feb 10 23:44:00 EST 2017, ip=/24.17.211.135, starmadeName=
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")

	results=$(~/scripts/sendraw2.sh /player_info "$1")
	counter=1
	for b in $results; do
		if ! [ ${stop} ]; then
			result=$(echo $b | grep "^RETURN\: \[SERVER, \[PL\] LOGIN\:.*, starmadeName=" | sed 's/RETURN: \[SERVER, \[PL\] LOGIN:.*, starmadeName=//' | sed 's/\///' | sed 's/\], 0\]//' | sed ':a;N;$!ba;s/\n//g' | sed 's/\r//')
			if [ "$result" ]; then
				stop=stop
				echo ${result}
			fi
		fi
	done
	IFS=$SAVEIFS

else
	echo "This command looks up the last starmade name from a /player_search command for a given player."
	echo 'Usage: lastSMName.sh [PlayerName]'
fi
