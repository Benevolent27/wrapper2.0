#!/bin/bash
# Usage:  playerFactionRank.sh [UserName] (Faction Number - if no faction number is provided, it will take an extra step to look it up)
# Ranks can be 0-4.  0 is lowest, 4 is founder.
scriptDir=~/scripts/


if [ "$1" ]; then
	name="$1"
	if ! [ "$2" ]; then
		getFactionNumber=$("$scriptDir"user/playerFaction.sh ${name})
	else
		getFactionNumber="$2"
	fi
	if [ "$getFactionNumber" ]; then
		getRoleNumber=$("$scriptDir"sendraw2.sh /faction_list_members ${getFactionNumber} | grep -o "playerUID\=${name}\, roleID\=[0-9]*" | sed "s/playerUID\=${name}\, roleID\=//g" )
		if [ "$getRoleNumber" ]; then
			echo "$getRoleNumber"
		else
			echo "error:  "$getRoleNumber
		fi
	else
		echo "NoFaction"
	fi
	
else
	echo "Usage:  playerFactionRank.sh [UserName] (Faction Number - if no faction number is provided, it will take an extra step to look it up)"
fi

# example output:  RETURN: [SERVER, [ADMIN COMMAND] [SUCCESS] The Rebuilders: {Benevolent27=>Fac
# nPermission [playerUID=Benevolent27, roleID=4], BUILD_DestroyerOfWorlds=>Fact
# Permission [playerUID=BUILD_DestroyerOfWorlds, roleID=4], Melvin=>FactionPerm
# ion [playerUID=Melvin, roleID=4], NaStral=>FactionPermission [playerUID=NaStr
# roleID=4], Thrace_Vega=>FactionPermission [playerUID=Thrace_Vega, roleID=4]}
#]