#!/bin/bash
SAVEIFS=$IFS
commentPattern="((#|\/\/))"
function set_IFS_no_spaces {
	IFS=$(echo -en "\n\b")
}
function reset_IFS {
	IFS=$SAVEIFS
}
function writeToFile {
	echo "Writing to file: ${tempFileName}"
	echo "$*" >> "${tempFileName}"
}
if [ "$1" == "-debug" ]; then
	debug="-debug"
	echo "Debug turned on for setIniVariable.sh!"
	shift
fi
function decho {
	if [ "${debug}" ]; then
		echo "$@"
	fi
}


if [ "$2" ]; then
	fileName="$1"
	shift
	variable="$1"
	shift
	valueToSet="$*"
	set_IFS_no_spaces
	tempFileName="${fileName}.$(date +%s%N)"
	while [ -f "${tempFileName}" ]; do
		tempFileName="${fileName}.$(date +%s%N)"
	done
	decho "tempFileName: ${tempFileName}"
	if [ -f "${fileName}" ]; then
		results=$(cat "${fileName}")
		# Check all results to see if a match for the variable exists already.
		for b in ${results}; do
			# valueTest checks for the variable and gets the value of it if it exists
			valueTest="$(echo $b | sed -E "s/[[:blank:]]*${commentPattern}.*//g" | sed -E "s/${commentPattern}.*//g" | grep -P "^((${variable}|${variable}[[:blank:]]))=")"
			if ! [ "$valueTest" ]; then
				# If it is not a match, just write this line to the temporary file
				writeToFile "$b"
			else
				# This is so that it does not get added to the end of the line, since it was found
				valueSet="true"
				# This preserves any comments that were on the line.
				comments="$(echo "$b" | grep -Po "[[:blank:]]*${commentPattern}.*")"
				# Instead of writing the line, add the desired value instead, preserving any comments.
				writeToFile "${variable}=${valueToSet}${comments}"
				# This is just here to give assurance to the person using the command that it worked correctly and in case they actually need that old value.
				oldValue="$(echo "$valueTest" | sed -E 's/.*=[[:blank:]]*//g' | sed 's/.*=//g')"
				if [ "$oldValue" ]; then
					echo "Value existed for variable, '${variable}'.  Changing '${oldValue}' to '${valueToSet}'"
					unset oldValue
				else
					echo "${variable} existed, but had no value.  Set variable to '${valueToSet}'"
				fi
				unset comments
			fi
		done
	else
		valueSet="true"
		echo "File did not exist!  Creating it and adding the following line:  ${variable}=${valueToSet}"
		writeToFile "${variable}=${valueToSet}"
	fi
	# None of the lines contained the variable, so let's add it to the end of the file.
	if ! [ "$valueSet" ]; then
		echo "File found and variable did not already exist.  Adding the following line to the end of file, '${fileName}': ${variable}=${valueToSet}"
		writeToFile "${variable}=${valueToSet}"
	fi
	# Replace the original file with the temporary file, if it exists - the check to see if the temporary file exists is to avoid circumstances where the temporary file may not have been writeable
	if [ -f "${tempFileName}" ]; then
		echo "Replacing file with temporary file"
		mv "${tempFileName}" "${fileName}"
	else
		echo "ERROR:  Could not write to a temporary file!  Aborting!  Please make sure you run this script from a directory you have write permissions in!"
	fi
else
	echo "This script will set an individual value to an ini file for you."
	echo "Usage: setIniValue.sh [FileName] [variable] [value]"
	echo "Note:  This command will preserve comments if some already existed and can be used to add a comment when changing or adding the value."
	echo "Example: setIniValue.sh myIni.ini onetwo \"buckle my shoe, three four # close the door\""
fi
