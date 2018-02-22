#!/bin/bash
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
else
	quiet="false"
fi

if [ "$1" == "-i" ]; then
	insensitive="i"
	shift
fi

if [ "$1" ]; then
	file="$1"
	pattern="$2"
	if ! [ "$pattern" ]; then
		pattern="^.*"
	fi
	set_IFS_no_spaces
	if [ -f "${file}" ]; then
		results=$(cat "${file}" | sed -E "s/[[:blank:]]*${commentPattern}.*//g" | sed -E "s/${commentPattern}.*//g" | grep -P${insensitive} "((${pattern}|${pattern}[[:blank:]]))=" | sed -E 's/[[:blank:]]*=.*$//g' )
		for b in ${results}; do
			echo "$b" | sed -E "s/^\"|^\'|\"$|\'$//g"
		done
	else
		if [ "${quiet}" == "false" ]; then
			echo "ERROR:  File does not exist!"
		fi
	fi

else
	echo "This script will get the variables from an ini file and can search using regex patterns."
	echo "Usage: getIniVariables.sh (-quiet) (-i) [File.ini] (REGEX_Pattern)"
	echo "Example 1:  getIniVariables.sh test.ini"
	echo "This will return all variables in the test.ini file."
	echo "Example 2: getIniVariables.sh test.ini ^GE-.*"
	echo "This will return all variables that start with 'GE-'."
	echo "Note:  This command will ignore any text that has a '#' or '//' escape sequence and remove any preceeding blank space."
	echo "Note 2: If run with the -quiet argument, the script will not give error messages, such as if a file does not exist."
fi
