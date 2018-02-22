#!/bin/bash

pathToStarMade=~/starmade/StarMade/
starmadeLogFolder="${pathToStarMade}logs/"
startUpType=tee # The options here are "normal", which will read from the log files directly, "namedPipe" which will read from a named pipe, and "tee" which will read from an "output.log" file from the main starmade start folder

scriptDir=~/scripts/
wrapper2Dir="${scriptDir}wrapper2.0/"

if [ "${1}" == "-debug" ]; then
	debug="true"
	shift
fi

function decho {
	if [ "${debug}" == "true" ]; then
		echo "$@"
	fi
}

logfile=()
if [ "${startUpType}" == "tee" ]; then
	logfile+=("${pathToStarMade}output.log")
elif [ "${startUpType}" == "namedPipe" ]; then
	# This will likely never be used since named pipes don't seem to work correctly, quickly stopping to output correctly when using tee to output to one
	logfile+=("${pathToStarMade}output.log")
	namedPipe="${pathToStarMade}consoleOutput.log"
else
	logfile+=("${starmadeLogFolder}logstarmade.0.log")
fi
serverLog="${starmadeLogFolder}serverlog.0.log"
decho "serverlog: ${serverLog}"
# Note:  Another way to do the pattern matching an exclusions in one call is with awk
# example:  echo "hi thre" | awk '(/hello/ || /hi/) && !/there/'
# This will only echo "hi thre" if it has either "hello" or "hi" in it and does NOT include "there"
# This could potentially work faster than using separate grep processes for the inclusion and exclusion
# awk could also probably handle running scripts based on the patterns matched in one go



function set_IFS_no_spaces {
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
}
function reset_IFS {
	IFS=$SAVEIFS
}

# Set the Internal Field Separator to only use return characters, rather than also spaces, since a pattern may very well have spaces in it
set_IFS_no_spaces

# Grab all the patterns from the pattern file - Error handling for if this file does not exist needs to be added later
results=$(cat "${wrapper2Dir}patterns.txt" | sed 's/#.*//g')
exclude_results=$(cat "${wrapper2Dir}exclude_patterns.txt" | sed 's/#.*//g')
# Set each line of the file to a variable, following the pattern in incrementing order:  pattern[number]
counter=1
for b in ${results}; do
	if [ "w${b}" == "w" ]; then
		decho "Blank line found, skipping.."
	else
		pattern[${counter}]="$b"
		# echo "pattern[${counter}]=$b"
		let counter++
	fi
done

counter2=1
for b in ${exclude_results}; do
	excludePattern[${counter2}]="$b"
	# echo "excludePattern[${counter2}]=$b"
	let counter2++
done
# Set the Internal Field Separator back to using spaces
reset_IFS

function getResult {
	# This will set the variable "$result" to be whatever the pattern[number] returns, and also turns "[" and "]" into "\]" and "\[", which is properly escaped.
	result="$(echo "${pattern[${counter}]}" | sed 's/\[/\\\[/g' | sed 's/\]/\\\]/g')"
}
function getExcludeResult {
	# Removing the ' and space replacements
	result2="$(echo "${excludePattern[${counter2}]}" | sed 's/\[/\\\[/g' | sed 's/\]/\\\]/g' | sed 's/(/\\\(/g' | sed 's/)/\\\)/g')"
	# echo "Result2:  $result2"
}

counter=1
# getResult
result="${pattern[${counter}]}"
# This will take all the variables created from the patterns file and then build a variable that contains all the the search parameters for grep, with escaping of [ and ] characters
while [ "$result" ] ; do
	if [ "${patternBuilt}" ]; then
		patternBuilt="${patternBuilt}|${result}"
	else
		patternBuilt=${result}
	fi
	let counter++
	# getResult
	result="${pattern[${counter}]}"
done
# echo "Pattern built:  ${patternBuilt}"

counter2=1
result2="${excludePattern[${counter2}]}"
# getExcludeResult
# This will take all the variables created from the patterns file and then build a variable that contains all the the search parameters for grep, with escaping of [ and ] characters
while [ "$result2" ] ; do
	if [ "${excludePatternBuilt}" ]; then
		excludePatternBuilt="${excludePatternBuilt}|${result2}"
	else
		excludePatternBuilt=${result2}
	fi
	let counter2++
	# echo "Built excludePatternBuilt so far: ${excludePatternBuilt}"
	result2="${excludePattern[${counter2}]}"
	# getExcludeResult
done
if [ "w${logfile[@]}" == "w" ]; then
	echo "No log files specified for filter.sh!  Please add log files to read from!"
else
	for b in "${logfile[@]}"; do
		# echo "Adding ${b} as a log file argument.."
		if [ "w${logFileArgument}" == "w" ]; then
			logFileArgument="-F ${b}"
		else
			logFileArgument="${logFileArgument} -F ${b}"
		fi
	done
	# echo "Done adding logs!"
	# stdbuf -i0 -o0 tail -n0 -q ${logFileArgument} 2>/dev/null | grep --line-buffered -E "${patternBuilt}" | grep --line-buffered -Ev "${excludePatternBuilt}"
	# Alternative suggested by Argh
	# { stdbuf -i0 -o0 tail -n0 -q -F "${starmadeLogFolder}${logfile}" & stdbuf -i0 -o0 tail -n0 -q -F "${starmadeLogFolder}${logfile2}" ; } 2>/dev/null | grep --line-buffered -E "${patternBuilt}" | grep --line-buffered -Ev "${excludePatternBuilt}"

	decho "Including pattern: ${patternBuilt}"
	decho "Excluding pattern: ${excludePatternBuilt}"
	# Since the console output does not contain all the needed info, we HAVE TO parse the server log.. so.. let's use the original + argh's suggestion
	# stdbuf -i0 -o0 tail -n0 -q -F "${serverLog}" 2>/dev/null | sed 's/^\[[^\[]*\][[:blank:]]*//g'

	# { stdbuf -i0 -o0 tail -n0 -q -F "${serverLog}" 2>/dev/null | sed 's/^\[[^\[]*\][[:blank:]]*//g' ; } | grep --line-buffered -E "${patternBuilt}" | grep --line-buffered -Ev "${excludePatternBuilt}"

	# extra brackets
	# { stdbuf -i0 -o0 tail -n0 -q ${logFileArgument} 2>/dev/null & { stdbuf -i0 -o0 tail -n0 -q -F "${serverLog}" 2>/dev/null | sed 's/^\[[^\[]*\][[:blank:]]*//g' ; } ; } | grep --line-buffered -E "${patternBuilt}" | grep --line-buffered -Ev "${excludePatternBuilt}"
function outputServerLog {
	stdbuf -i0 -o0 tail -n0 -q -F "${serverLog}" 2>/dev/null | stdbuf -i0 -o0 sed 's/^\[[^\[]*\][[:blank:]]*//g'
}
function outputLogs {
	stdbuf -i0 -o0 tail -n0 -q ${logFileArgument} 2>/dev/null
}
function outputAllLogs {
	{ outputServerLog & outputLogs ; }
}
	outputAllLogs | grep --line-buffered -E "${patternBuilt}" | grep --line-buffered -Ev "${excludePatternBuilt}"
fi
