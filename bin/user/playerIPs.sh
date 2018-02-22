#!/bin/bash
# Usage:  playerFactionRank.sh [UserName] (Faction Number - if no faction number is provided, it will take an extra step to look it up)
# Ranks can be 0-4.  0 is lowest, 4 is founder.
scriptDir=~/scripts/

SAVEIFS=$IFS
function set_IFS_no_spaces {
	IFS=$(echo -en "\n\b")
}
function reset_IFS {
	IFS=$SAVEIFS
}
function finish {
	reset_IFS
}
trap finish EXIT

if [ "$1" ]; then
	name="$1"
	set_IFS_no_spaces
	getIPs=$("$scriptDir"sendraw2.sh /player_info ${name})
	for b in ${getIPs}; do
		result=$(echo "${b}" | grep -Po "ip=/[0-9\.]*" | sed 's_ip=/__g')
		if [ "${result}" ]; then
			if [ "${allResults}" ]; then
				allResults=$(echo -e "${allResults}\n${result}")
			else
				allResults=$(echo -e "${result}")
			fi
		fi
		unset result
	done
	if [ "${allResults}" ]; then
		echo "${allResults}" | sort -u
	fi
else
	echo "Usage:  playerIPs.sh [UserName]"
fi

