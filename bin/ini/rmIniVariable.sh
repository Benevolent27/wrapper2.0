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
	decho "Writing '$*' to '${tempFileName}'."
	echo "$*" >> "${tempFileName}"
}

if [ "$1" == "-debug" ]; then
	debug="true"
	echo "Debug turned on."
	shift
fi

function decho {
	if [ "${debug}" == "true" ]; then
		echo "$*"
	fi
}


if [ "$2" ]; then
	fileName="$1"
	shift
	variable="$1"
	shift
	valueToTestFor="$*"
	set_IFS_no_spaces
	tempFileName="${fileName}.$(date +%s%N)"
	while [ -f "${tempFileName}" ]; do
		decho "Temp Filename, ${tempFileName}, already existed!  Setting new name.."
		tempFileName="${fileName}.$(date +%s%N)"
		sleep 0.1
	done
	decho "Using Temporary file: ${tempFileName}"

	if [ -f "${fileName}" ]; then
		results=$(cat "${fileName}")
		# Check all results to see if a match for the variable exists already.
		for b in ${results}; do
			# valueTest checks for the variable and gets the value of it if it exists
			valueTest="$(echo $b | sed -E "s/[[:blank:]]*${commentPattern}.*//g" | sed -E "s/${commentPattern}.*//g" | grep -P "^((${variable}|${variable}[[:blank:]]*))=")"
			if ! [ "$valueTest" ]; then
				# If it is not a match to the variable name, just write this line to the temporary file
				somethingElseWasWritten="true"
				writeToFile "$b"
			else
				# The variable was found, so no need to mention later that it was not found
				valueFound=true
				# grab the current value
				currentValue="$(echo "$valueTest" | sed -E 's/.*=[[:blank:]]*//g' | sed 's/.*=//g' | sed -E "s/^\"|^\'|\"$|\'$//g")"				
				if [ "${valueToTestFor}" ]; then
					# If the value to test for matchest the current value, remove it by simply not re-writing it
					if [ "${currentValue}" == "${valueToTestFor}" ]; then
						echo "Value for variable, '${variable}', matched '${valueToTestFor}'!  Removing it!"
						valueRemoved="true"
					# If the value existed and it did not match the value to test for, then do not delete it.
					else
						writeToFile "$b"
						#if [ "${currentValue}" ]; then
						#	echo "${variable} existed, but it's value, '${currentValue}', did not match the value you specified, '${valueToTestFor}', so it will NOT be removed!"
						#else
						#	echo "${variable} existed, but had no value.  Since this does not match the value you specified, '${valueToTestFor}', it will NOT be removed!"
						#fi
					fi
				else
					valueRemoved="true"
					if [ "${currentValue}" ]; then
						echo "Variable, '${variable}', found and removed.  The value was: ${currentValue}"
						unset currentValue
					else
						echo "Variable, '${variable}', found and removed.  It contained no value."
					fi
				fi
			fi
		done
	else
		echo "File did not exist!  Nothing to remove!  Check your spelling and try again!"
	fi
	# None of the lines contained the variable, so let's add it to the end of the file.
	if ! [ "${somethingElseWasWritten}" == "true" ]; then
		echo "Nothing was to be written to the temporary file, so creating an empty one.."
		touch "${tempFileName}"
	fi

	if ! [ "$valueFound" ]; then
		echo "File found, but no instance of that variable was found in the file.  Nothing to remove!"
		rm "${tempFileName}"
	else
		if [ -f "${tempFileName}" ]; then
			mv "${tempFileName}" "${fileName}"
		else
			echo "ERROR:  Could not write to a temporary file!  Aborting!  Please make sure you run this script from a directory you have write permissions in!"
		fi
	fi
	# Replace the original file with the temporary file, if it exists - the check to see if the temporary file exists is to avoid circumstances where the temporary file may not have been writeable
else
	echo "This script will remove an individual value from an ini file for you if it exists."
	echo "Usage: rmIniValue.sh [FileName] [variable] (value)"
	echo "Note:  Specifying a value is optional.  This will only remove the variable IF the value matches."
	echo "Example: rmIniValue.sh myIni.ini onetwo"
	echo "This will remove the line from 'myIni.ini' containing the variable 'onetwo' if it finds it"
	echo "Example 2: rmIniValue.sh myIni.ini myPass flibberdygibblet"
	echo "This will only remove the variable, 'myPass', from the file, 'myIni.ini', IF the value is 'flibberdygibblet'."
fi
