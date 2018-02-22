#!/bin/bash
starmadeFolder=~/starmade/StarMade/
if [ "$1" ]; then
	test=$(cat "$starmadeFolder"admins.txt | grep -io "^$1")
	test2=$(cat "$starmadeFolder"admins.txt | grep -i "^$1")
	if [ "$test" ]; then
		if [ "$test" == "$test2" ]; then
			echo "true"
		else
			echo "false"
		fi
	else
		echo "false"
	fi
else
	echo "Usage: isadmin.sh [username]"
	exit
fi
