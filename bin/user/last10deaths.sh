#!/bin/bash
scriptDir=~/scripts/
logsFolder=~/starmade/StarMade/logs

function set_IFS_no_spaces {
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
}
function reset_IFS {
	IFS=$SAVEIFS
}

my_dir="`( cd \"$MY_PATH\" && pwd )`"
cd "${logsFolder}"
set_IFS_no_spaces
if [ "$1" == "-long" ]; then
	long=true
	shift
fi
if [ "$1" ]; then
	if [ "$long" ]; then
		long="searchUsed"
	fi
	results=$(cat serverlog.*.log | grep -i "^\[.*\] \[DEATH\] ${1} .*'" | sort -ur ) # | tail -n 100)
else
	results=$(cat serverlog.*.log | grep "^\[.*\] \[DEATH\].*'" | sort -ur ) # | tail -n 100)
fi
if [ "$results" ]; then
	declare -a messages
	# tempCounter=1
	for b in ${results}; do
		# If there are less than 10 items in the array, messages, then do all the jazz
		# echo "tempCounter=${tempCounter}"
		if [ ${#messages[*]} -le 10 ]; then
			# echo "On the number: ${#messages[*]}"
			# echo "Long: $result"
			timeLong=$(echo $b grep -oE '^\[(([0-9\-]|[[:space:]]|(:)))*' | sed 's/^\[//g' | sed 's/\].*//g')
			if [ "$timeLong" ]; then
				# date=$(echo ${timeLong} | grep -o ".* " | sed 's/ //g')
				# year=$(echo $date | grep -o "^[0-9]*-" | sed 's/-//g')
				# restOfDate=$(echo $date | grep -o "\-[0-9]*\-[0-9]*" | sed 's/^-//g')
				# date=$(echo "${restOfDate}-${year}")
				# time=$(echo ${timeLong} | grep -o " .*" | sed 's/ //g')

				time=$("${scriptDir}/core/formatDate.sh" -ht "$timeLong")
				date=$("${scriptDir}/core/formatDate.sh" -hd "$timeLong")

			fi
		
			person=$(echo $b | grep -oE '\[DEATH] .* has been killed by' | sed 's/\[DEATH\]//g' | sed 's/ has been killed by//g' | sed 's/ //g')

			# new section - need to add to reporting
			
			if [ "$long" ]; then
				if ! [ "$personFactionNumber" ]; then
					personFactionNumber=$("${scriptDir}user/playerFaction.sh" $person)
				fi
			
				if ! [ "$personFactionName" ]; then
					# personFactionName=$("${scriptDir}faction/factionNumberToName.sh" ${personFactionNumber})
					personFactionName=$("${scriptDir}user/playerFaction.sh" -name $person)
				fi
				if ! [ "$personAlignment" ]; then
					personAlignment=$("${scriptDir}wrapper/align/factionAlignment.sh" ${personFactionNumber})
				fi
				person_with_faction_and_alignment="${person} (Faction: ${personFactionName}) (Alignment: ${personAlignment})"
			else
				person_with_faction_and_alignment="${person}"
			fi
			
			killer=$(echo $b | grep -o "'Killer: .* (" | sed "s/'Killer: //g" | sed 's/ (//g')
			if ! [ "$killer" ]; then
				# Gotta figure out why removing the ] fucks up the responsible faction..
				responsible=$(echo $b | grep -o "'Responsible: .*;" | sed "s/'Responsible: //g" | sed "s/';//g" ) # | sed 's/\[.*//g')
				
				responsibleFaction=$(echo $responsible | grep -o "\[.*]" | sed 's/^\[//g' | sed 's/\]$//g' | sed 's/\].*//g')
				responsibleEntity=$(echo $responsible | grep -o "^.*\[" | sed 's/\[.*$//g')
				if ! [ "$responsibleEntity" ]; then
					responsibleEntity=${responsible}
				fi
			fi
			if [ "$killer" ]; then
				if [ "${person}" == "${killer}" ]; then
					message="[${date}] [${time}]: ${person_with_faction_and_alignment} killed themselves."
				else
					message="[${date}] [${time}]: ${person_with_faction_and_alignment} was killed by ${killer}."
				fi
			elif [ "$responsible" ]; then
			# echo "Responsible: ${responsible}"
				if [ "$responsibleEntity" ]; then
					message="${person_with_faction_and_alignment} was killed by an entity, '${responsibleEntity}',"
					if [ "$responsibleFaction" ]; then
						message="${message} of the faction, '${responsibleFaction}'"
					fi
					message="[${date}] [${time}]: ${message}."
				fi
			fi
			# Needs a check here to only add the message if not a duplicate
			for b in ${messages[*]}; do
				if [ "$message" == "$b" ]; then
					duplicate=found
				fi
			done
			if ! [ "$duplicate" ]; then
				messages+=("$message")
				# echo "${#messages[*]}: $message"
				
				# This will have the newest death at the top - for reverse sorting use the "while" loop below 20 lines or so and comment out the next line.
				# echo "$message"
				
				# new section - need to add to reporting
				if ! [ "$long" == "searchUsed" ]; then
					unset personFactionNumber
					unset personFactionName
					unset personAlignment
					unset person
				fi
				
			fi
			unset duplicate
			# echo "$message"
			# echo $b
		fi
		# let tempCounter++
	done
	# This will have the newest death on the bottom - for sorting the newest death on top, read up for the appropriate comment and then comment this for loop out.
	reversalCounter=9
	while [ "${reversalCounter}" -ge 0 ]; do
		echo "${messages[${reversalCounter}]}"
		let reversalCounter--
	done
	# for b in ${messages[*]}; do
	#	echo "$b"
	# done
# else
#	echo "No results were found!"
fi
reset_IFS
cd $my_dir

# Example:   [2017-05-17 18:58:47] [DEATH] RedAlert_007 has been killed by 'Killer: RedAlert_007 (0.0/120.0 HP left)'; controllable: PlS[RedAlert_007 [RedAlert_007]*; id(5299)(9)f(10009)]
# Working:  echo "[2017-05-17 18:58:47] [DEATH] RedAlert_007 has been killed by 'Killer: RedAlert_007 (0.0/120.0 HP left)'; controllable: PlS[RedAlert_007 [RedAlert_007]*; id(5299)(9)f(10009)]" | grep -o "'Killer: .* (" | sed "s/'Killer: //g" | sed 's/ (//g'


# Example 2:  [2017-05-17 18:46:25] [DEATH] x_Samm_x has been killed by 'Responsible: Leviathan Mk6rl540[Resonance]'; controllable: Ship[Leviathan Mk6rl540](13397)
# Not working:  echo "[2017-05-17 18:46:25] [DEATH] x_Samm_x has been killed by 'Responsible: Leviathan Mk6rl540[Resonance]'; controllable: Ship[Leviathan Mk6rl540](13397)" | grep -o "'Responsible: .* (" | sed "s/'Responsible: //g" | sed 's/ (//g'


