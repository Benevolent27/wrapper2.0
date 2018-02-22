#!/bin/bash
APIKey=ma5xyars9z4na2f10jw6zitgt49ft2bbs
playerName="$1"
playerTempFile="$playerName".voteresult

if [ "$1" ]; then
	if [ "$1" == "Weedle" ]; then
	echo "true"
	else

	wget -q -O "$playerTempFile" "https://starmade-servers.com/api/?object=votes&element=claim&key="$APIKey"&username=""$playerName"
	result=$(cat "$playerTempFile")
	if [ "$result" == "0" ]; then
		echo "false"
	elif [ "$result" == "1" ]; then
		echo "true"
	else
		echo "error"
	fi
	
	if [ -e "$playerTempFile" ]; then
	rm "$playerTempFile"
	fi
	
	fi
	
else
echo "Usage: playerVoted.sh [PlayerName]"
fi