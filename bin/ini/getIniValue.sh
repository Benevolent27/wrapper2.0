#!/bin/bash

# Errorcodes:
# 2 - Target file does not exist


# This script and other scripts need to account for the partial comments from the starmade config's which look someting like <--? />
SAVEIFS=$IFS

commentPattern="((#|\/\/))"

function set_IFS_no_spaces {
	IFS=$(echo -en "\n\b")
}
function reset_IFS {
	IFS=$SAVEIFS
}
if [ "$1" == "-quiet" ]; then
	quiet="true"
	shift
fi

if [ "$1" == "-full" ]; then
	full="true"
	shift
fi
if [ "$2" ]; then
	file="$1"
	variable="$2"
	set_IFS_no_spaces
	if [ -f "${file}" ]; then
		if [ "w${full}" == "w" ]; then
			results=$(cat "${file}" | sed -E "s/[[:blank:]]*${commentPattern}.*//g" | sed -E "s/${commentPattern}.*//g" | grep -P "^((${variable}|${variable}[[:blank:]]))=")
		else
			results=$(cat "${file}" | grep -P "^((${variable}|${variable}[[:blank:]]))=")
		fi
		for b in ${results}; do
			echo "$b" | sed -E 's/^.*=[[:blank:]]*//g' | sed 's/^.*=//g' | sed -E "s/^\"|^\'|\"$|\'$//g" | sed -e 's/[\r\n]//g'
		done
	else
		if ! [ "${quiet}" == "true" ]; then
			echo "ERROR:  File does not exist!"
		fi
		exit 2
	fi

else
	echo "This script will get an individual value from an ini file for you."
	echo "Usage: getValue.sh (-quiet) (-full) [File] [VariableName]"
	echo "This will return the value of a variable in the ini named MyName.  If '-full' is specified, then it also returns the comment."
	echo "Note:  This command will ignore any text that has a '#' or '//' in front of it and also remove any blank space before the comment character(s)"
	echo "If the '-quiet' argument is used, then no error text is given if a file does not exist, but an exit code is still used."
fi
