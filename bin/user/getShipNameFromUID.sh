#!/bin/bash
# Usage getShipNameFromUID.sh
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

if [ "$1" == "-debug" ]; then
	echo "Debug turned on."
	debug="true"
	shift
fi
function decho {
	if [ "${debug}" == "true" ]; then
		echo "$@"
	fi
}


if [ "$1" ]; then

	set_IFS_no_spaces
	# Run the /ship_info_name command on the server with quotes around the $1 input
	results=$("$scriptDir"sendraw2.sh -q2 /ship_info_uid "$1")
	# Run through all the lines of output from the /ship_info_name command and run pattern matches on each new line.
	for b in $results ; do
		# Attempt to match the loaded ship info, if it has been returned.  This is more current than the database info
		decho "Processing result: ${b}"
		if ! [ "$onlineResult" ]; then
			onlineResult=$(echo $b | grep -oE '^RETURN\: \[SERVER\, Name\: ([0-9A-Za-z_\-]|[[:blank:]])*' | sed 's/^RETURN\: \[SERVER, Name\: //g')
		fi
		if ! [ "$offlineResult" ]; then
		# Fixed to account for admin spawned ships - was broken before, had to add in < and > to the spawned in section
			# offlineResult=$(echo "$b" | grep -oE "RETURN\: \[SERVER, DatabaseEntry \[uid.([0-9A-Za-z_\-]|[[:blank:]])*, sectorPos...[0-9]*, .[0-9]*, .[0-9]*...type.., seed.., lastModifier.([0-9A-Za-z_\-]|[[:blank:]])*, spawner.([0-9A-Za-z_\-\<\>]|[[:blank:]])*, realName.([0-9A-Za-z_\-]|[[:blank:]])*" | sed -r 's/^RETURN\: \[SERVER, DatabaseEntry \[uid.([0-9A-Za-z_\-]|[[:blank:]])*, sectorPos...[0-9]*, .[0-9]*, .[0-9]*...type.., seed.., lastModifier.([0-9A-Za-z_\-]|[[:blank:]])*, spawner.([0-9A-Za-z_\-\<\>]|[[:blank:]])*, realName.//g')
			offlineResult="$(echo "$b" | grep -oP "realName=([0-9A-Za-z_-]|[[:blank:]])*," | sed 's/^realName=//g' | sed 's/,$//g')"
		fi
	done

	# Next section is disabled because working on it above - delete when above is done.
	# Only works if the ship is loaded!
	# shipUID=$("$scriptDir"sendraw2.sh -q2 /ship_info_name "$1" | grep -oE 'RETURN\: \[SERVER\, UID\: ([0-9A-Za-z_\-]|[[:blank:]])*' | sed 's/RETURN\: \[SERVER, UID\: //g')

	# Only works if the ship is UNLOADED!
	# shipUID=$("$scriptDir"sendraw2.sh -q2 /ship_info_name "$1" | grep -oE 'RETURN\: \[SERVER\, DatabaseEntry \[uid.([0-9A-Za-z_\-]|[[:blank:]])*' 
	# | sed 's/RETURN\: \[SERVER, UID\: //g')
	# RETURN: [SERVER, DatabaseEntry [uid=

	# Prefer to return the onlin result rather than the offline result, since the offline may be out of date since the last force_update
	if [ "$onlineResult" ]; then
		echo "$onlineResult"
	elif [ "$offlineResult" ]; then
		echo "$offlineResult"
	fi





# sendraw2 /ship_info_uid \'\"ENTITY_SHIP_Backup-Shredder-Mark6_1472539897785rl42\"\'


# last version - ONLY WORKS WHEN SHIP IS LOADED - thus is useless
# "$scriptDir"sendraw2.sh /ship_info_uid \'\"$1\"\' | grep -oE 'RETURN\: \[SERVER, Name: ([0-9A-Za-z_\-]|[[:blank:]])*' | sed 's/^RETURN\: \[SERVER, Name:.//g'

# Works for all ships but ships spawned in by an admin which has <admin> in the "spawner" section
# "$scriptDir"sendraw2.sh /ship_info_uid \'\"$1\"\' | grep -oE "RETURN\: \[SERVER, DatabaseEntry \[uid.([0-9A-Za-z_\-]|[[:blank:]])*, sectorPos..[0-9]*,.[0-9]*,.[0-9]*...type.., seed.., lastModifier.([0-9A-Za-z_\-]|[[:blank:]])*, spawner.([0-9A-Za-z_\-\]|[[:blank:]])*, realName.([0-9A-Za-z_\-]|[[:blank:]])*" | sed -r 's/^RETURN\: \[SERVER, DatabaseEntry \[uid.([0-9A-Za-z_\-]|[[:blank:]])*, sectorPos..[0-9]*,.[0-9]*,.[0-9]*...type.., seed.., lastModifier.([0-9A-Za-z_\-]|[[:blank:]])*, spawner.([0-9A-Za-z_\-]|[[:blank:]])*, realName.//g'

# problem ship UID:   ENTITY_SHIP_Backup-Shredder-Mark6_1472539897785rl42
# Normal ship UID:  ENTITY_SHIP_The Space





# RETURN: [SERVER, DatabaseEntry [uid=ENTITY_SHIP__Yet-Another-Ship_ Also has Spaces, sectorPos=(5000, 5000, 5000), type=5, seed=0, lastModifier=ENTITY_PLAYERSTATE_Benevolent27, spawner=ENTITY_PLAYERSTATE_Benevolent27, realName=_Yet-Another-Ship_ Also has Spaces, touched=true, faction=0, pos=(-900.9733, 1131.5131, -3962.1719), minPos=(-2, -2, -2), maxPos=(2, 2, 2), creatorID=0], 0]
else
	echo "Usage: getShipNameFromUID.sh \"[ship UID]\""
fi
#RETURN: [SERVER, DatabaseEntry [uid=ENTITY_SHIP_Backup-Shredder-Mark6_1472539897785rl42, sectorPos=(4000, 4000, 4000), type=5, seed=0, lastModifier=ENTITY_PLAYERSTATE_Benevolent27, spawner=<admin>, realName=Backup-Shredder-Mark6 derp, touched=true, faction=10000, pos=(-966.87866, 1043.4196, -3688.7898), minPos=(-2, -2, -10), maxPos=(2, 2, 1), creatorID=0], 0]