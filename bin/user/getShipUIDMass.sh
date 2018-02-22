#!/bin/bash
scriptDir=~/scripts/
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
if [ "$1" ]; then
"$scriptDir"sendraw2.sh /ship_info_uid \'\"$1\"\' | grep -o 'RETURN\: \[SERVER, Mass: [0-9\.]*' | sed 's/^RETURN\: \[SERVER, Mass:.//g'
# RETURN: [SERVER, Mass: 0.1, 0]
else
echo "Usage: getShipUIDMass.sh \"[ship UID]\""
fi
IFS=$SAVEIFS