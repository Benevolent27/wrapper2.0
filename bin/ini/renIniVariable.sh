#!/bin/bash
scriptDir=~/scripts/
SAVEIFS=$IFS
commentPattern="((#|\/\/))"
function set_IFS_no_spaces {
	IFS=$(echo -en "\n\b")
}
function reset_IFS {
	IFS=$SAVEIFS
}
function writeToFile {
	# echo "Writing to file.."
	echo "$*" >> "${tempFileName}"
}

if [ "$3" ]; then
	fileName="$1"
	shift
	variable="$1"
	shift
	newVariable="$1"
	set_IFS_no_spaces
	tempFileName="${fileName}.$(date +%s%N)"
	while [ -f "${tempFileName}" ]; do
		tempFileName="${fileName}.$(date +%s%N)"
	done
	if [ -f "${fileName}" ]; then
		if ! [ "$variable" == "$newVariable" ]; then
			
			checkForOldVariable="$("${scriptDir}core/ini/checkIniIfVariableExists.sh" "${fileName}" ${variable})"
			checkForNewVariable="$("${scriptDir}core/ini/checkIniIfVariableExists.sh" "${fileName}" ${newVariable})"
			if [ "${checkForOldVariable}" ]; then
				if [ "${checkForNewVariable}" == "true" ]; then
					echo "Variable, '${newVariable}', already exists! Removing all instances from '${fileName}' before continuing.."
					"${scriptDir}core/ini/rmIniVariable.sh" "${fileName}" "${newVariable}"
				fi
				results=$(cat "${fileName}")
				# Check all results to see if a match for the variable exists.
				for b in ${results}; do
					# valueTest checks for the variable and gets the value of it if it exists
					# echo "Temp: \$b = $b"
					valueTest="$(echo "$b" | sed -E "s/[[:blank:]]*${commentPattern}.*//g" | sed -E "s/${commentPattern}.*//g" | grep -P "^((${variable}|${variable}[[:blank:]]*))=")"
					# echo "valueTest: ${valueTest}"
					if ! [ "$valueTest" ]; then
						# If it is not a match to the variable name, just write this line to the temporary file
						writeToFile "$b"
					else
						# The variable was already found by the check script, but this is a redundant check.
						valueFound=true
						# grab the current value
						currentValue="$(echo "$valueTest" | sed -E 's/.*=[[:blank:]]*//g' | sed 's/.*=//g' )"				
						comments="$(echo "$b" | grep -Po "[[:blank:]]*${commentPattern}.*")"
						echo "Variable, '${variable}' was renamed to '${newVariable}'."
						writeToFile "${newVariable}=${currentValue}${comments}"
					fi
				done
			else
					echo "File found, but no instance of the variable, '${variable}', was found in the file!  Cannot rename a variable that does not exist!"

			fi
			if [ "${valueFound}" == "true" ]; then
				# This is a redundant check before replacing the original file.  Since the variable was found, let's replace the original file with the temporary file.
				if [ -f "${tempFileName}" ]; then
					mv "${tempFileName}" "${fileName}"
				else
					# We check to see if the file exists, just in case this script is run from a directory where there is no write permission for the current user.
					echo "ERROR:  Could not write to a temporary file!  Aborting!  Please make sure you run this script from a directory you have write permissions in!"
				fi
			else
				echo "ERROR:  Somehow one check showed the variable existed, but then the variable was not found.  This should never happen!  Aborting!"
				
				if [ -f "$tempFileName" ]; then
					rm "$tempFileName"
				fi
			fi
		else
			echo "ERROR:  Cannot rename a variable to the same name.  Please check your spelling and try again."
		fi
	else
		echo "File did not exist!  No variables to rename!  Check your spelling and try again!"
	fi
	reset_IFS
else
	echo "This script will rename an individual variable to a new name from an ini file for you, if it exists."
	echo "Usage: renIniValue.sh [FileName] [variable] [newVariableName]"
	echo "Example: renIniValue.sh myIni.ini one two"
	echo "This will rename the variable 'one' to 'two', preserving any comments and also the location within the file."
	echo "Note:  This will check the file to see if another variable exists with the new variable name and remove it, so use with care!"
fi
