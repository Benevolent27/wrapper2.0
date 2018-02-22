#!/bin/bash
starmadeFolder=~/starmade/StarMade/
if [ "$1" ]; then
	test=$(cat "$starmadeFolder"admins.txt | sed 's/#.*//g' | grep -io "^${1}$")
	if [ "$test" ]; then
		echo "true"
	else
		echo "false"
	fi
else
	echo "Usage: isAdmin-faster.sh [username]"
	exit 1
fi
