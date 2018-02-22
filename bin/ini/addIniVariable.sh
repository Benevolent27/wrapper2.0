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
	echo "$*" >> "${tempFileName}"
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

	if [ -f "${fileName}" ]; then
		results=$(cat "${fileName}")
		# Check all results to see if a match for the variable exists already.
		counter=1
		for b in ${results}; do
			# valueTest checks for the variable and gets the value of it if it exists
			valueTest="$(echo $b | sed -E "s/[[:blank:]]*${commentPattern}.*//g" | sed -E "s/${commentPattern}.*//g" | grep -P "((${variable}|${variable}[[:blank:]]))=")"
			# Since we are not removing any values, we only need to add the value.  We're checking the file though so that the value is added below the first duplicate variable it finds, to keep things organized.
			if [ "$valueTest" -a "w${valueSet}" == "w" ]; then
				# This is set so the new varaible is not added again to the end of the line, but rather to set it below the existing line.
				valueSet="true"
				# Instead of writing the line, add the desired value instead, preserving any comments.
				writeToFile "${variable}=${valueToSet}"
				echo "Value existed for variable, '${variable}'.  Adding new duplicate above on line, ${counter}."
			fi
			let counter++
			writeToFile "$b"
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
		mv "${tempFileName}" "${fileName}"
	else
		echo "ERROR:  Could not write to a temporary file!  Aborting!  Please make sure you run this script from a directory you have write permissions in!"
	fi
else
	echo "This script will add an individual value to an ini file for you.  This can be used to add more than one value with the same name."
	echo "Usage: addIniValue.sh [FileName] [variable] [value]"
	echo "Note:  This command will not change any existing values."
	echo "Example: addIniValue.sh myIni.ini onetwo \"buckle my shoe, three four # close the door\""
fi
