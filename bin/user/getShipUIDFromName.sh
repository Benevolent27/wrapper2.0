#!/bin/bash
scriptDir=~/scripts/

# To work on:  The offline match needs to be finished

# By default, when running a for loop, bash sees any spaces in the output as a separator.  We don't want this behavior since there are spaces in the output from the server console.  So we need to change it to only see new lines as separators.  This will also prevent bash from separating out the name of the ship in the variable, so if there is more than one space in a ship name, the variable won't truncate it.  First I'll backup the current IFS to reload later in the script.
SAVEIFS=$IFS
# Change the IFS (Internal Field Separator) to only apply to new lines
IFS=$(echo -en "\n\b")
# IFS='%'
if [ "$1" ]; then


	# Run the /ship_info_name command on the server with quotes around the $1 input
	results=$("$scriptDir"sendraw2.sh -q2 /ship_info_name "$1")
	# Run through all the lines of output from the /ship_info_name command and run pattern matches on each new line.
	for b in $results ;
	do
		# Attempt to match the loaded ship info, if it has been returned.  This is more current than the database info
		if ! [ "$onlineResult" ]; then
			onlineResult=$(echo $b | grep -oE '^RETURN\: \[SERVER\, UID\: ([0-9A-Za-z_\-]|[[:blank:]])*' | sed 's/RETURN\: \[SERVER, UID\: //g')
		fi
		if ! [ "$offlineResult" ]; then
			offlineResult=$(echo "$b" | grep -oE "^RETURN\: \[SERVER, DatabaseEntry \[uid.([0-9A-Za-z_\-]|[[:blank:]])*" | sed 's/^RETURN\: \[SERVER, DatabaseEntry \[uid.//g')
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
else
	echo "No ship name provided!  Usage: getShipUIDFromName.sh [Ship Name]"
fi
# Restore the original IFS (Internal Field Separator) for the bash shell
IFS=$SAVEIFS

# The rest of this script is all comments, this will be deleted once the script is done.

# Sample outputs:
# IF OFFLINE:

# RETURN: [SERVER, [INFO] Two  Spaces not found in loaded objects. Checking Database..., 0]
# RETURN: [SERVER, DatabaseEntry [uid=ENTITY_SHIP_Two  Spaces, sectorPos=(4000, 4000, 4000), type=5, seed=0, lastModifier=ENTITY_PLAYERSTATE_Benevolent27, spawner=ENTITY_PLAYERSTATE_Benevolent27, realName=Two  Spaces, touched=true, faction=0, pos=(132.89677, 110.635025, 47.974007), minPos=(-2, -2, -2), maxPos=(2, 2, 2), creatorID=0], 0]
# RETURN: [SERVER, END; Admin command execution ended, 0]

# IF ONLINE (this is what the script currently uses):
# RETURN: [SERVER, [INFO] Two  Spaces found in loaded objects, 0]
# RETURN: [SERVER, Attached: [], 0]
# RETURN: [SERVER, DockedUIDs: , 0]
# RETURN: [SERVER, Blocks: 10, 0]
# RETURN: [SERVER, Mass: 1.0000001, 0]
# RETURN: [SERVER, LastModified: ENTITY_PLAYERSTATE_Benevolent27, 0]
# RETURN: [SERVER, Creator: ENTITY_PLAYERSTATE_Benevolent27, 0]
# RETURN: [SERVER, Sector: 568 -> Sector[568](4000, 4000, 4000), 0]
# RETURN: [SERVER, Name: Two  Spaces, 0]
# RETURN: [SERVER, UID: ENTITY_SHIP_Two  Spaces, 0]
# RETURN: [SERVER, MinBB(chunks): (-2, -2, -2), 0]
# RETURN: [SERVER, MaxBB(chunks): (2, 2, 2), 0]
# RETURN: [SERVER, Local-Pos: (132.89677, 110.635025, 47.974007), 0]
# RETURN: [SERVER, Orientation: (-0.3403374, 0.7137452, -0.5841936, 0.18291016), 0]
# RETURN: [SERVER, Ship, 0]
# RETURN: [SERVER, END; Admin command execution ended, 0]