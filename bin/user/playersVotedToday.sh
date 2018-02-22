#!/bin/bash
APIKey=ma5xyars9z4na2f10jw6zitgt49ft2bbs

tempFile=voteresults.temp

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# To get a list of voters
# "https://starmade-servers.com/api/?object=servers&element=voters&key="$APIKey"&month=current&format=json"

# To get a list of votes&element
# "https://starmade-servers.com/api/?object=servers&element=votes&key="$APIKey"&format=json"
# https://starmade-servers.com/api/?object=servers&element=votes&key=ma5xyars9z4na2f10jw6zitgt49ft2bbs&format=json

# Full URL (for manual downloading):  wget -O "vote-results.txt" "https://starmade-servers.com/api/?object=servers&element=votes&key=ma5xyars9z4na2f10jw6zitgt49ft2bbs&format=json"

wget -q -O "$tempFile" "https://starmade-servers.com/api/?object=servers&element=votes&key="$APIKey"&format=json"
results=$(cat "$tempFile")
# today="$(date +"%B") $(date +"%Oe" | sed s'/ //')"
today="$(date +"%B %-d")"

# echo "Date set to: "$today
for b in $results; do
		# echo "Checking line: "$b
		if ! [ "$hit" ]; then
			hit=$(echo $b | grep "$today")
		fi
		if [ "$hit" ]; then
			# echo "Hit found.. searching.."
			searchNick=$(echo $b | grep "\"nickname\"\:" | sed 's/.*\"nickname\"\:\"//g' | sed 's/\",//g')
			if [ "$searchNick" ]; then
				# players:="$searchNick"
				# echo $searchNick
				if [ "$players" ]; then
					players="$players $searchNick"
				else
					players="$searchNick"
				fi
				unset hit
			fi
		fi
done
echo "$players"
# for b in $players; do
# 	echo $b
# done

# less "$tempFile"
if [ -e "$tempFile" ]; then
	rm "$tempFile"
fi
IFS=$SAVEIFS