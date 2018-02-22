#!/bin/bash
scriptDir=~/scripts/
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# working on - needs testing

if [ "$1" ]; then
results=$("$scriptDir"sendraw2.sh /ship_info_uid \'\"$1\"\')

for b in $results; do


if ! [ "$onlineUID" ]; then
# Online only
# "$scriptDir"sendraw2.sh /ship_info_uid \'\"$1\"\' | grep -o 'RETURN\: \[SERVER, Sector: [0-9]* .. Sector\[.[0-9]*\].[0-9]*\,.[0-9]*\,.[0-9]*'| sed 's/^RETURN\: \[SERVER, Sector: [0-9]* .. Sector\[.[0-9]*\].//g' | sed 's/,//g'
onlineUID=$(echo $b | grep -o 'RETURN\: \[SERVER, Sector: [0-9]* .. Sector\[.[0-9]*\]..[0-9]*\, .[0-9]*\, .[0-9]*'| sed 's/^RETURN\: \[SERVER, Sector: [0-9]* .. Sector\[.[0-9]*\].//g' | sed 's/,//g')
fi

if ! [ "$offlineUID" ]; then
# Offline only - this next line by works but gives outdated information when the ship is loaded and the database hasn't been updated yet due to a force save.
# "$scriptDir"sendraw2.sh /ship_info_uid \'\"$*\"\' | grep -oE "RETURN\: \[SERVER, DatabaseEntry \[uid.([0-9A-Za-z_\-]|[[:blank:]])*, sectorPos...[0-9]*, .[0-9]*, .[0-9]*" | sed -r 's/^RETURN\: \[SERVER, DatabaseEntry \[uid.([0-9A-Za-z_\-]|[[:blank:]])*, sectorPos..//g' | sed 's/,//g'
offlineUID=$(echo "$b" | grep -oE "RETURN\: \[SERVER, DatabaseEntry \[uid.([0-9A-Za-z_\-]|[[:blank:]])*, sectorPos...[0-9]*, .[0-9]*, .[0-9]*" | sed -r 's/^RETURN\: \[SERVER, DatabaseEntry \[uid.([0-9A-Za-z_\-]|[[:blank:]])*, sectorPos..//g' | sed 's/,//g')
fi
done

if [ "$onlineUID" ]; then
	echo "$onlineUID"
elif [ "$offlineUID" ]; then
	echo "$offlineUID"
fi


else
echo "Usage: locateShipUID.sh \"[ship UID]\""
fi
IFS=$SAVEIFS