#!/bin/bash
SAVEIFS=$IFS
commentPattern="((#|\/\/))"
function set_IFS_no_spaces {
	IFS=$(echo -en "\n\b")
}
function reset_IFS {
	IFS=$SAVEIFS
}
if [ "$1" == "-debug" ]; then
	debug=true
	echo "Debug turned on!"
	shift
fi
function decho {
	if [ "${debug}" == "true" ]; then
		echo "$@"
	fi
}


if [ "$2" ]; then
	file="$1"
	decho "File set to: ${file}"
	variable="$2"
	decho "variable to search for set to: ${variable}"
	set_IFS_no_spaces
	if [ -f "${file}" ]; then
		decho "Grabbing any results that match the variable specified exactly"
		results=$(cat "${file}" | sed -E "s/[[:blank:]]*${commentPattern}.*//g" | sed -E "s/${commentPattern}.*//g" | grep -P "^((${variable}|${variable}[[:blank:]]))=")
		for b in ${results}; do
			decho "Result found: ${b}"
			exists=true
		done
	fi
	if [ "$exists" ]; then
		echo "true"
	else
		echo "false"
	fi
else
	echo "This script check ini file to see if a variable exists, returning true if it does, or false if it does not."
	echo "Usage: checkIniIfVariableExists.sh [FileName.ini] [variable]"
	echo "Note:  This will also work for blank variables."
fi
