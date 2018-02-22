#!/bin/bash
commandOperand="!"
spamGuardProtectionSeconds=3

# To add stuff
# from serverlog.0.log:  [2017-11-06 02:39:51] [SPAWN] Benevolent27 spawned new ship: "OverHeatTest"



scriptDir=~/scripts/
melvin_chat="${scriptDir}wrapper/melvin_chat.sh"
melvin_chat_public="${scriptDir}wrapper/melvin_public_chat.sh"
public_chat="${scriptDir}chat.sh"
server_info_to="${scriptDir}server_info_to.sh"
run="true"
wrapper2Dir="${scriptDir}wrapper2.0/"
binDir="${wrapper2Dir}bin/"
modsFolder="${wrapper2Dir}mods/"
tempDir="${wrapper2Dir}temp/"


addIniVariable="${wrapper2Dir}bin/ini/addIniVariable.sh"
checkIniIfVariableExists="${wrapper2Dir}bin/ini/checkIniIfVariableExists.sh"
getIniValue="${wrapper2Dir}bin/ini/getIniValue.sh"
getIniVariables="${wrapper2Dir}bin/ini/getIniVariables.sh"
renIniVariable="${wrapper2Dir}bin/ini/renIniVariable.sh"
rmIniVariable="${wrapper2Dir}bin/ini/rmIniVariable.sh"
setIniVariable="${wrapper2Dir}bin/ini/setIniVariable.sh"


SAVEIFS=$IFS
# This is the directory the person is in when the script is ran
my_dir="`( cd \"$MY_PATH\" && pwd )`"

# This is the directory this script is actually in
myDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd && echo x)"
myDIR="${myDIR%x}"
myDIR="$(echo "${myDIR}"  | tr -d '\n')/"

function add_commas {
	echo "$(printf "%'.f\n" $1)"
}

function set_IFS_no_spaces {
	IFS=$(echo -en "\n\b")
}
function reset_IFS {
	IFS=$SAVEIFS
}
function finish {
	echo "Running exit commands.."
	cd $my_dir
	reset_IFS
}
trap finish EXIT

# Structure
# First I need to go through the /mods/ folder and assign scripts to use into arrays.  Then when each type of scenario is all filled out, it will run all scripts with the arguments that wrapper can gather.
if [ "$1" == "-debug" ]; then
	debug="true"
	echo "Debug turned on!"
	shift
fi

if [ "$1" == "-simulation" ]; then
	simulation="true"
	echo "Simulation only turned on!"
	shift
fi

function decho {
	if [ "${debug}" == "true" ]; then
		echo "$@"
	fi
}

totalScripts=0
mods=()

# runPlayerMessage "${player}" "${receiverType}" "${receiver}" "${message}"
# runPlayerDisconnect "${player}"
# runPlayerSpawn "${player}"
# runGravityChange "${player}" "${entityType}" "${entityInfo}"
# runPlayerDeath [Player] [???]
# runNewShip [Player] [Ship Name]
# runWrapperCommand [Command] [arguments]


function runPlayerFaction {
	for b in "${playerFactionScripts[@]}"; do
		"${binDir}playerFactionLoader.sh" "${b}" "$@" &
	done &
}


function runPlayerMessage {
	for b in "${playerMessageScripts[@]}"; do
		# runPlayerMessage "${player}" "${receiverType}" "${receiver}" "${message}"
		decho "Running playerMessageScript: ${b}"

		"${binDir}playerMessageLoader.sh" "${b}" "$@" &
		# "${b}" $@ &
	done &
}

function runPlayerDisconnect {
	for b in "${playerDisconnectScripts[@]}"; do
		decho "Running playerDisconnectScript: ${b}"
		# "${b}" $@ &
		"${binDir}playerDisconnectLoader.sh" "${b}" "$@" &
	done &
}
function runPlayerConnect {
	for b in "${playerConnectScripts[@]}"; do
		decho "Running playerVonnectScript: ${b}"
		# "${b}" $@ &
		"${binDir}playerConnectLoader.sh" "${b}" "$@" &
	done &
}

function runPlayerSpawn {
	for b in "${playerSpawnScripts[@]}"; do
		decho "Running playerSpawnScript: ${b}"
		"${binDir}playerSpawnLoader.sh" "${b}" "$@" &
		# "${b}" $@ &
	done &
}

function runGravityChange {
	for b in "${gravityChangeScripts[@]}"; do
		decho "Running gravityChangeScript: ${b}"
		"${b}" $@ &
	done &
}

function runPlayerDeath {
	for b in "${playerDeathScripts[@]}"; do
		# echo "%%%%%%%%%%%%%%%% Running playerDeathScript: ${b}"
		# "${b}" $@ &
		# Instead of running the script directly, I need to run the deathloader, which will prefill all the variables pertaining to the death for the scripting
		# "${scriptDir}log.sh" "DEBUGGING PARSER 2: $@"
		"${binDir}playerDeathLoader.sh" "${b}" "$@" &
	done &
}

function runEntityDeath {
	for c in "${entityDeathScripts[@]}"; do
		# echo "%%%%%%%%%%%%%%%% Running entityDeathScript: ${c}"
		# "${b}" $@ &
		# Instead of running the script directly, I need to run the deathloader, which will prefill all the variables pertaining to the death for the scripting
		"${binDir}entityDeathLoader.sh" "${c}" "$@" &
	done &
}


function runNewShip {
	for b in "${newShipScripts[@]}"; do
		# echo "Running newShipScript, ${b}, with arguments, '$@'."
		# "${b}" "$@" &
		# set_IFS_no_spaces
		"${binDir}newShipLoader.sh" "${b}" "$@" &
		# reset_IFS
		# runNewShip "${name}" "${shipName}" "${toSector}" "${bluePrintName}" "${bluePrintPrice}"
	done &
}

function runNewBase {
	for b in "${newBaseScripts[@]}"; do
		# echo "Running newBaseScript, ${b}, with arguments, '$@'."
		# "${b}" "$@" &
		# set_IFS_no_spaces
		"${binDir}newBaseLoader.sh" "${b}" "$@" &
		# reset_IFS
		# runNewShip "${name}" "${shipName}" "${toSector}" "${bluePrintName}" "${bluePrintPrice}"
	done &
}


function runWrapperCommand {
	# runWrapperCommand "${sender}" "${theCommand}" "${arguments}"
	player="${1}"
	wrapperCommand="$(echo "${2}" | tr '[:upper:]' '[:lower:]')"
	shift
	shift
	shift
	shift
	arguments="${@}"

	decho "Attempting to run wrapper command: ${wrapperCommand}"
	shift
	for b in "${wrapperCommands[@]}"; do
		commandToCompare=$(echo "${b}" | sed 's_.*/__g' | sed 's/\.sh$//g' | tr '[:upper:]' '[:lower:]')
		decho "Comparing ${wrapperCommand} to ${commandOperand}${commandToCompare}"
		if [ "${wrapperCommand}" == "${commandOperand}${commandToCompare}" ]; then
			decho "Running wrapper command: ${b} ${player} ${arguments}"
			# "${b}" "${player}" "${wrapperCommand}" ${arguments} &

			# "${b}" "${player}" ${arguments} &
			"${wrapper2Dir}bin/commandLoader.sh" "${b}" "${player}" ${arguments} &
			returnCode=1
		fi
		unset commandToCompare
	done
	unset wrapperCommand
	if [ "w${returnCode}" == "w" ]; then
		returnCode=0
	fi

	return "${returnCode}"
}
# Set up the temporary files, including the command helper text file.
echo "Setting up temporary files.."
if ! [ -d "${wrapper2Dir}temp" ]; then
	mkdir "${wrapper2Dir}temp"
fi
# Set up the command helper (this is what gives people suggestions if they mistype a command by a few characters)
if [ -f "${tempDir}commandList.txt" ]; then
	echo "Old commandList.txt file found, removing.."
	rm "${tempDir}commandList.txt"
fi
if [ -f "${wrapper2Dir}bin/defaultCommandList.txt" ]; then
	cp "${wrapper2Dir}bin/defaultCommandList.txt" "${tempDir}commandList.txt"
	# We should now have the default commands all listed here, so when loading mod commands, we'll just add the commands to the list
fi

echo "Loading settings.."
announceSpawnsToMainChat=$("${getIniValue}" -quiet "${myDIR}config.ini" announceSpawnsToMainChat | tr '[:upper:]' '[:lower:]')
announceShipBlueprintValueOnSpawn=$("${getIniValue}" -quiet "${myDIR}config.ini" announceShipBlueprintValueOnSpawn | tr '[:upper:]' '[:lower:]')
logFactionJoinsAndLeaves=$("${getIniValue}" -quiet "${myDIR}config.ini" logFactionJoinsAndLeaves | tr '[:upper:]' '[:lower:]')
announceFactionJoinsAndLeaves=$("${getIniValue}" -quiet "${myDIR}config.ini" announceFactionJoinsAndLeaves | tr '[:upper:]' '[:lower:]')

# This is for the command spam guard, files are created and then removed after 3 seconds whenever a player runs a command
for files in "${tempDir}"*.spamGuard; do
	echo "Removing old spamguard file: ${files}"
	rm "${files}"
done

if [ -d "${modsFolder}" ]; then
	echo "Searching for available mods..  This may take a moment.."
	totalModFoldersFound=0
	for d in ${modsFolder}*/; do
		decho "Mod Folder Found: ${d}"
		modFolders+=("${d}")
		let totalModFoldersFound++
	done

	playerFactionScripts=()
	totalPlayerFactionScripts=0

	playerMessageScripts=()
	totalPlayerMessageScripts=0

	playerConnectScripts=()
	totalPlayerConnectScripts=0

	playerDisconnectScripts=()
	totalPlayerDisconnectScripts=0

	playerSpawnScripts=()
	totalPlayerSpawnScripts=0

	gravityChangeScripts=()
	totalGravityChangeScripts=0

	playerDeathScripts=()
	totalPlayerDeathScripts=0

	entityDeathScripts=()
	totalEntityDeathScripts=0

	newShipScripts=()
	totalNewShipScripts=0

	newBaseScripts=()
	totalNewBaseScripts=0

	totalWrapperCommandsAddedToCommandHelper=0
	totalWrapperCommandsAddedToCommandHelperDuplicate=0
	totalWrapperCommandsAddedToCommandHelperSkipped=0


	wrapperCommands=()
	totalWrapperCommands=0
	totalWrapperCommandsSkipped=0



	for b in "${modFolders[@]}"; do
		decho " "
		decho "Processing Mod Folder for events: ${b}"
		# PLAYERFACTION
		if [ -f "${b}playerFaction.sh" ]; then
			decho "Adding playerFaction script: ${b}playerFaction.sh"
			playerFactionScripts+=("${b}playerFaction.sh")
			let totalPlayerFactionScripts++
		fi
		# PLAYERMESSAGE
		if [ -f "${b}playerMessage.sh" ]; then
			decho "Adding playerMessage script: ${b}playerMessage.sh"
			playerMessageScripts+=("${b}playerMessage.sh")
			let totalPlayerMessageScripts++
		fi
		# PLAYERCONNECT
		if [ -f "${b}playerConnect.sh" ]; then
			decho "Adding playerConnect script: ${b}playerConnect.sh"
			playerConnectScripts+=("${b}playerConnect.sh")
			let totalPlayerConnectScripts++
		fi
		# PLAYERDISCONNECT
		if [ -f "${b}playerDisconnect.sh" ]; then
			decho "Adding playerDisconnect script: ${b}playerDisconnect.sh"
			playerDisconnectScripts+=("${b}playerDisconnect.sh")
			let totalPlayerDisconnectScripts++
		fi
		# PLAYERSPAWN
		if [ -f "${b}playerSpawn.sh" ]; then
			decho "Adding playerSpawn script: ${b}playerSpawn.sh"
			playerSpawnScripts+=("${b}playerSpawn.sh")
			let totalPlayerSpawnScripts++
		fi
		# GRAVITYCHANGE
		if [ -f "${b}gravityChange.sh" ]; then
			decho "Adding gravityChange script: ${b}gravityChange.sh"
			gravityChangeScripts+=("${b}gravityChange.sh")
			let totalGravityChangeScripts++
		fi
		# PLAYERDEATH
		if [ -f "${b}playerDeath.sh" ]; then
			decho "Adding playerDeath script: ${b}playerDeath.sh"
			playerDeathScripts+=("${b}playerDeath.sh")
			let totalPlayerDeathScripts++
		fi

		# ENTITYDEATH
		if [ -f "${b}entityDeath.sh" ]; then
			decho "Adding entityDeath.sh script: ${b}entityDeath.sh"
			entityDeathScripts+=("${b}entityDeath.sh")
			let totalEntityDeathScripts++
		fi

		## SERVER -- This is too broad of a message and needs to broken down into sub-messages.
		# NEWSHIP
		if [ -f "${b}newShip.sh" ]; then
			decho "Adding newShip script: ${b}newShip.sh"
			newShipScripts+=("${b}newShip.sh")
			let totalNewShipScripts++
		fi

		# NEWSHIP
		if [ -f "${b}newBase.sh" ]; then
			decho "Adding newBase script: ${b}newBase.sh"
			newBaseScripts+=("${b}newBase.sh")
			let totalNewBaseScripts++
		fi

		# Wrapper commands
		decho "Processing any wrapper commands.."
		if [ -d "${b}commands/" ]; then
			decho "Commands folder found within mod folder.. Searching for commands.."
			# commandFolderTemp="${b}commands/"
			set_IFS_no_spaces
			for c in "${b}commands/"*.sh; do
				if ! [ "${c}" == "${b}commands/*.sh" ]; then


					# Get the ini file for the command, so we can check to see if the command is disabled or supposed to be added to the command helper.
					commandIni="$(echo "${c}" | sed 's/\.sh$//g').ini"
					decho "commandIni: ${commandIni}"
					# First check to see if the command is disabled.  By default if no .ini file is found, it is enabled.

					commandDisabled="$("${getIniValue}" -quiet "${commandIni}" commandDisabled)"
					decho "commandDisabled: ${commandDisabled}"



					# grab the command based on the script file and set it to lowercase so we can compare.
					commandLowercase=$(echo "${c}" | sed 's_.*/__g' | sed 's/\.sh$//g' | tr '[:upper:]' '[:lower:]')


					if [ "${commandDisabled}" == "true" ]; then
						echo "########## SKIPPING adding mod command, '${commandLowercase}', because it was disabled in it's ini file (commandDisabled=true): ${commandIni}"
						let totalWrapperCommandsSkipped++

						# If the command was disabled, then it would could not be added to the command helper, so it should be included in this stat as well
						let totalWrapperCommandsAddedToCommandHelperSkipped++
					else
						# The wrapper command was not diabled in it's ini file, or it's ini file did not exist, so let's add it to the list of commands.
						echo "Command found and added to wrapperCommands: ${c}"
						wrapperCommands+=("${c}")
						let totalWrapperCommands++

						# Check to ensure the command's ini file does not disable it from being included in the command helper list.  If the ini file does not exist or this value is set to anything other than "false," it will be added.
						addToCommandHelper="$("${getIniValue}" -quiet "${commandIni}" addToCommandHelper)"
						decho "addToCommandHelper: ${addToCommandHelper}"

						if [ "${addToCommandHelper}" == "false" ]; then
							echo "########## SKIPPING adding command, '${commandLowercase}', to command helper list because it was disabled in it's ini file (addToCommandHelper=false): ${commandIni}"
							let totalWrapperCommandsAddedToCommandHelperSkipped++
						else
							# Add the command to the command helper list, but only if it doesn't already exist.

							# We load the commandList.txt over and over because it will include any new commands added by this script.  It would probably be better to simply add to the variable each time to do the compare, but meh I'm being lazy and who cares.
							existingCommands=$(cat "${tempDir}commandList.txt")

							# Cycle through all the existing commands in the commandList.txt to compare to the potential mod addition
							for d in ${existingCommands}; do
								commandToCompare=$(echo "${d}" | tr '[:upper:]' '[:lower:]')
								if [ "${commandLowercase}" == "${commandToCompare}" ]; then
									# A match was found, so set commandFound to be true so that it does not add the command to the list again.
									commandFound="true"
								fi

							done
							# Only add the command to the list if it was NOT found
							if ! [ "${commandFound}" == "true" ]; then
								echo "Adding command to ${tempDir}commandList.txt: ${commandLowercase}"
								echo "${commandLowercase}" >> "${tempDir}commandList.txt"
								let totalWrapperCommandsAddedToCommandHelper++
							else
								decho "############ Command, ${commandLowercase}, was already in the list!  Skipping!"
								let totalWrapperCommandsAddedToCommandHelperDuplicate++
							fi


							unset existingCommands
							unset commandFound
						fi

						unset addToCommandHelper
					fi
					unset commandDisabled
					unset commandLowercase
					unset commandIni


				else
					decho "No commands found.  Skipping!"
				fi
			done
			# unset commandFolderTemp
			reset_IFS
		else
			decho "No commands folder found for mod.  Skipping!"
		fi
	done
	echo " "
	echo " ################"
	echo " #    TOTALS    #"
	echo " ################"
	echo " "
	echo "Total Mod Folders Processed: ${totalModFoldersFound}"
	echo " "
	echo "Total playerFaction scripts added: ${totalPlayerFactionScripts}"
	echo "Total playerMessage scripts added: ${totalPlayerMessageScripts}"
	echo "Total playerConnect scripts added: ${totalPlayerConnectScripts}"
	echo "Total playerDisconnect scripts added: ${totalPlayerDisconnectScripts}"
	echo "Total playerSpawn scripts added: ${totalPlayerSpawnScripts}"
	echo "Total gravityChange scripts added: ${totalGravityChangeScripts}"
	echo "Total playerDeath scripts added: ${totalPlayerDeathScripts}"
	echo "Total entityDeath scripts added: ${totalEntityDeathScripts}"
	echo "Total newShip scripts added: ${totalNewShipScripts}"
	echo "Total newBase scripts added: ${totalNewBaseScripts}"
	echo " "
	echo "Total Mod Commands added: ${totalWrapperCommands}"
	echo "Total Mod Commands skipped: ${totalWrapperCommandsSkipped}"
	echo "Total Mod Command duplicates: ${totalWrapperCommandsAddedToCommandHelperDuplicate}"
	echo " "
	echo "Total Mod Commands added to Command Helper: ${totalWrapperCommandsAddedToCommandHelper}"
	echo "Mod Commands not added to Command Helper due to config options: ${totalWrapperCommandsAddedToCommandHelperSkipped}"
	echo " "


	unset totalWrapperCommandsAddedToCommandHelper
	unset totalWrapperCommandsAddedToCommandHelperDuplicate
	unset totalWrapperCommandsAddedToCommandHelperSkipped

	unset totalWrapperCommandsSkipped
	unset totalModFoldersFound
	unset totalPlayerMessageScripts
	unset totalPlayerDisconnectScripts
	unset totalPlayerSpawnScripts
	unset totalGravityChangeScripts
	unset totalPlayerDeathScripts
	unset totalNewShipScripts
	unset totalWrapperCommands

	echo "Mods loaded, starting filter.."


	if [ "${simulation}" == "true" ]; then
		echo "Starting Simulation:"
		runPlayerMessage Player "And this is the message"
		runPlayerDisconnect Player
		runPlayerSpawn Player
		runGravityChange Not Sure What To Do Here
		runPlayerDeath Player
		runNewShip Player "New Ship Name"
		runWrapperCommand blah And these are the arguments.
		sleep 5
		exit
	fi


else
	echo "No mods folder found!  Creating empty folder.."
	mkdir "${modsFolder}"
fi

# Parser
function show_arguments {
	echo "1: ${1}"
	echo "2: ${2}"
	echo "3: ${3}"
	echo "4: ${4}"

	echo "5: ${5}"
	echo "6: ${6}"
	echo "7: ${7}"
	echo "8: ${8}"
	echo "9: ${9}"
	echo "10: ${10}"
}



###  WRAPPER STARTS HERE ###
# set_IFS_no_spaces # This is an attempt to preserve spaces in the line given by the filter script to parse, for example a ship name may have more than one space in it
set -f
while read -r b; do
	# This will read through the log files line by line and parse each one
	# echo "###################################Parsing: ${b}"
	set -- ${b}

	#################
	#      ALL MESSAGES      #
	#################
	if [ "${1}" == "[CHANNELROUTER]" ]; then
		shift 5
		echo "Left over from [CHANNELROUTER]: $*"
		sender=$(echo "${1}" | grep -Po "\[CHAT\]\[sender=[A-Za-z0-9_-]*" | sed 's/^\[CHAT\]\[sender=//g')
		message=$(echo "${@}" | grep -Po "\[message=.*]$" | sed -E 's/(^\[message=|\]$)//g')
		receiverType=$(echo "${@}" | grep -Po "\[receiverType=[A-Za-z0-9_-]*" | sed 's/^\[receiverType=//g')
		echo "receiverType: ${receiverType}"
		receiver=$(echo "${@}" | grep -Po "\[receiver=[A-Za-z0-9_-]*" | sed 's/^\[receiver=//g')
		echo "receiver: ${receiver}"


	###############
	#     COMMANDS       #
	###############
		if [[ "${message}" == "${commandOperand}"* ]]; then
			# This is to help avoid abuse of the commands.  Spamguard will only allow commands to be run every certain amount of seconds.
			spamGuardFile="${tempDir}${sender}.spamGuard"
			if [ -f "${spamGuardFile}" ]; then
				"${melvin_chat}" "${sender}" "Please do not spam wrapper commands!" &
				"${scriptDir}log.sh" "SPAM DETECTED:  Player, ${sender}, was spamming wrapper commands." &
			else
				# set -- ${message}
				theCommand="$(echo "${message}" | sed 's/ .*$//g')"
				arguments="$(echo "${message}" | sed "s/^${theCommand}//g")"

				echo "Running: ${scriptDir}wrapper/wprocessor2.sh" "${sender}" "${theCommand}" "${arguments}"

				# I need to decide whether a mod will be able to replace base functions OR run in addition OR make it configurable

				## Run Mod Scripts
				touch "${spamGuardFile}"
				{ sleep ${spamGuardProtectionSeconds} ; rm "${spamGuardFile}"; } &
				runWrapperCommand "${sender}" "${theCommand}" "${arguments}"
				returnCode="$?"
				echo "returnCode: ${returnCode}"
				# IF the returncode is 0, then it means no wrapper 2.0 command was found.  Right now I have it then try wrapper1.0 with the command, and then wrapper 1.0 handles the error handling if the command was invalid, but this will change once every command has been ported over to wrapper 2.0 format.


				# "$scriptDir"core/instanceScript.sh -name "wrapper_${sender}" "${scriptDir}wrapper/wprocessor2.sh" "${sender}" "${theCommand}" "${arguments}" &

				# Using wrapper 1.0 as a catch-all is temporary till I port every command over to wrapper2.0 format.  This may take a while though.  Eventually all this script will do is handle mis-typed commands and give suggestions.
				if [ "${returnCode}" == "0" ]; then
					"${scriptDir}wrapper/wprocessor2.sh" "${sender}" "${theCommand}" "${arguments}" &
				fi
				unset returnCode
				# date, time, name, command, arguments

				unset theCommand
			fi


		else

	##########################
	#     NON-COMMAND MESSAGING      #
	##########################
			# This is for every other kind of message besides a command.
			echo "Message received from ${sender}: ${message}"

			## Run Mod Scripts
			runPlayerMessage "${sender}" "${receiverType}" "${receiver}" "${message}"
		fi

	###############
	#   DISCONNECTS     #
	###############

	elif [ "${1}" == "[SERVER][DISCONNECT]" ]; then
		shift 3
		player="$1"
		echo "DISCONNECTED: ${player}"

		## Run Mod Scripts
		runPlayerDisconnect "${player}"


	##############
	#         SPAWNS       #
	##############

	# There are multiple [SERVER][SPAWN] type messages, so I filter here for the exact right one
	elif [ "${1}" == "[SERVER][SPAWN]" ]; then
		shift
		if [[ "${1}" == PlS\[* ]]; then
			player=$(echo "${1}" | sed 's/^PlS\[//g')
			echo "Player spawned: ${player}"
			if [ "${player}" ]; then
			#if [ "${player}" == "Benevolent27" -o "${player}" == "DestroyerOfWorlds" ]; then

				"${melvin_chat}" "${player}" "Welcome to LvD.  To see a list of commands available to you on our wrapper, type !help in any chat window."
			#fi
				if [ "${announceSpawnsToMainChat}" == "true" ]; then
					"${scriptDir}chat.sh" "${player} has spawned."
				fi

				## Run Mod Scripts
				runPlayerSpawn "${player}"

			fi
		fi
	# This seems to have multiple uses, but right now I have it set up to capture when a player connects but has not spawned yet

	########################
	#   NEW SHIP OR BASE CREATION  #
	########################

	elif [ "${1}" == "[SPAWN]" ]; then
		# echo "######## TEMP: New Entity Spawn detected.. ${b}"
		name="$2"
		# shift 5
		# shipName="$@"
		# echo "##############"
		shipName="$(echo "${b}" | grep -Po 'spawned new ship: "[0-9a-zA-Z _-]*' | sed 's/^spawned new ship: "//g')"
		if [ "w${shipName}" == "w" ]; then
			baseName="$(echo "${b}" | grep -Po 'spawned new station: "[0-9a-zA-Z _-]*' | sed 's/^spawned new station: "//g')"
			if [ "${baseName}" ]; then
				echo "BaseName: ${baseName}"
				# echo "##############"
				runNewBase "${name}" "${baseName}"
			fi
		else
			echo "Ship Name: ${shipName}"
			# echo "##############"
			runNewShip "${name}" "${shipName}"
		fi


		# [2017-11-07 00:15:46] [SPAWN] Benevolent27 spawned new ship: "wonky    spaced   ship"

	elif [[ "${1}" == \[BLUEPRINT\]* ]]; then
		# echo "######### TEMP: Blueprint spawn detected.."
		if [ "${1}" == "[BLUEPRINT][BUY]" ]; then
			# Regular blueprint spawning:
			# [2017-11-06 02:53:31] [BLUEPRINT][BUY] Benevolent27 bought blueprint from metaItem: "5x5x5-Beam-MissileHeatseekers" as "whateverDuderl13"; Price: 131950; to sector: (2, 2, 2) (loadTime: 2ms, spawnTime: 2ms)
			shift
			name="$1"
			echo "lastBluePrintNameBuy: ${lastBluePrintNameBuy}"
			echo "lastBlueprintBuyTime: ${lastBlueprintBuyTime}"


			if [ "w${lastBlueprintBuyTime}" == "w" ]; then
				# If this value isn't set yet, then the wrapper was just started.  No duplicates could have been found.  Setting it to 1 will ensure the first occurance is never treated as a duplicate.
				lastBlueprintBuyTime=1
			fi
			currentTime=$(date '+%s')
			# I compare the blueprint time because blueprint spawns show up in both the console output AND the server log, and since players cannot spawn a ship in more than once every 5 seconds, this will allow one of the duplicates to be ignored
			# todo: A better method would be to instead store values into an ini file and then have them removed after 5 seconds, and then check to see if a match for the blueprint spawn exists.. but I'm being lazy here
			# Or even better than that would be to separate out the pattern matching for the console output and server log output so there's no dupicates to begin with
			blueprintBuyTimeOffset=$((currentTime - lastBlueprintBuyTime))
			if [ "${blueprintBuyTimeOffset}" -gt 5 -o "${lastBluePrintNameBuy}" != "${name}" ]; then
				echo "######### TEMP: blueprint buy detected: $b"
				# metaItem: "-Stick Camera"
				# as "Whatever Man"

				# eval set -- $*
				# tempCounter=1
				#while [ "$1" ]; do
				#	echo "1: ${1}"
				#	let tempCounter++
				#	shift
				# done
				bluePrintName=$(echo "$b" | grep -oP 'metaItem: "[a-zA-Z0-9 _-]*' | sed 's/^metaItem: "//g')
				shipName=$(echo "$b" | grep -oP 'as "[a-zA-Z0-9 _-]*' | sed 's/^as "//g')
				bluePrintPrice=$(echo "$b" | grep -o "Price: [0-9]*" | sed 's/^Price: //g')
				toSector=$(echo "$b" | grep -o "to sector: [\(][0-9-]*, [0-9-]*, [0-9-]*" | sed 's/^to sector: (//g' | sed 's/,//g')
				echo "#########  New Ship Spawn From Blueprint ##########"
				echo "Player: ${name}"
				echo "Ship Spawned: ${shipName}"
				echo "Blueprint: ${bluePrintName}"
				echo "Ship price: ${bluePrintPrice}"
				echo "To Sector: ${toSector}"

				echo "########################"
				runNewShip "${name}" "${shipName}" "${toSector}" "${bluePrintName}" "${bluePrintPrice}"
				if [ "${announceShipBlueprintValueOnSpawn}" == "true" ]; then
					"${melvin_chat}" "${name}" "Congrats on the new ship, '${shipName}'! Just FYI, it is worth $(add_commas ${bluePrintPrice}) credits!" &
				fi
			unset blueprintBuyTimeOffset
			unset currentTime
			fi
			lastBluePrintNameBuy="${name}"
			lastBlueprintBuyTime="$(date '+%s')"
		elif [ "${1}" == "[BLUEPRINT][LOAD]" ]; then

			if [ "w${lastBlueprintLoadTime}" == "w" ]; then
				# If this value isn't set yet, then the wrapper was just started.  No duplicates could have been found.  Setting it to 1 will ensure the first occurance is never treated as a duplicate.
				lastBlueprintLoadTime=1
			fi
			currentTime=$(date '+%s')
			# I compare the blueprint time because blueprint spawns show up in both the console output AND the server log, and since players cannot spawn a ship in more than once every 5 seconds, this will allow one of the duplicates to be ignored
			# todo: A better method would be to instead store values into an ini file and then have them removed after 5 seconds, and then check to see if a match for the blueprint spawn exists.. but I'm being lazy here
			# Or even better than that would be to separate out the pattern matching for the console output and server log output so there's no dupicates to begin with
			blueprintLoadTimeOffset=$((currentTime - lastBlueprintLoadTime))

			# echo "An admin loaded a blueprint using the LOAD_AS_FACTION or SPAWN_MOBS command"

			bluePrintLoader="$2"
			shipName=$(echo "$b" | grep -oP 'as "[a-zA-Z0-9 _-]*' | sed 's/^as "//g')
			# This check is done to filter out duplicate log messages, since we are parsing both the main starmade log/console ouput and server log, but the message appears in both logs the same.  We use the loader and ship name OR the time, because it is possible that the same loader can load the same ship name, but at a different time.
			# Todo:  It would be better to have a separate include and exclude pattern for main starmade log/console from the server log, to eliminate duplicates in the first place
			if [ "${lastBluePrintLoader}" != "${bluePrintLoader}" -o "${shipName}" != "${lastBlueprintNameLoaded}" -o "${blueprintLoadTimeOffset}" -gt 5 ]; then
				# echo "Blueprint Load: $b"
				bluePrintName=$(echo "$b" | grep -oP 'loaded [a-zA-Z0-9 _-]* as "' | sed 's/^loaded "//g' | sed 's/ as "$//g')
				toSector=$(echo "$b" | grep -o "in [\(][0-9-]*, [0-9-]*, [0-9-]*" | sed 's/^in (//g' | sed 's/,//g')
				asFaction=$(echo "$b" | grep -o "as faction [0-9-]*$" | sed 's/^as faction //g')

				echo "#########  New Ship Spawn From Load (possibly /spawn_mobs command) ##########"
				echo "bluePrintLoader: ${bluePrintLoader}"
				echo "Ship Spawned: ${shipName}"
				echo "Blueprint: ${bluePrintName}"
				echo "To Sector: ${toSector}"
				echo "asFaction: ${asFaction}"
				echo "#########"


				unset bluePrintName
				unset toSector
				unset asFaction
			# else
				# echo "%%%%%%% SKIPPED: ${b}"
				# echo "lastBluePrintLoader: ${lastBluePrintLoader}"
				# echo "bluePrintLoader: ${bluePrintLoader}"
				# echo " "

				# echo "lastBlueprintNameLoaded: ${lastBlueprintNameLoaded}"
				# echo "shipName: ${shipName}"
				# echo " "

				# echo "lastBlueprintLoadTime: ${lastBlueprintLoadTime}"
				# echo " "
			fi
			lastBlueprintNameLoaded="${shipName}"
			lastBluePrintLoader="${bluePrintLoader}"
			lastBlueprintLoadTime="$(date '+%s')"
			unset bluePrintLoader
			unset shipName

		fi

	# Blueprint loading:

	# Using "Mass Spawn Ships":
	# [2017-11-06 02:56:40] [ADMINCOMMAND] Benevolent27 used: 'SPAWN_MOBS' with args [balsa_glider, -2, 1]
	# [2017-11-06 02:56:40] [BLUEPRINT][LOAD] <system> loaded balsa_glider as "MOB_balsa_glider_1509955000630_0" in (2, 2, 2) as faction -2


	# Admin loading:
	# [2017-11-06 02:51:25] [ADMINCOMMAND] Benevolent27 used: 'LOAD_AS_FACTION' with args [5x5x5-Beam-MissileHeatseekers, 5x5x5-Beam-MissileHeatseekers_1509954684818, 10000]
	# [2017-11-06 02:51:25] [BLUEPRINT][LOAD] <admin> loaded 5x5x5-Beam-MissileHeatseekers as "5x5x5-Beam-MissileHeatseekers_1509954684818rl13" in (2, 2, 2) as faction 10000
	# [2017-11-06 02:52:03] [ADMINCOMMAND] Benevolent27 used: 'LOAD_AS_FACTION' with args [5x5x5-Beam-MissileHeatseekers, blahblah, 10000]
	# [2017-11-06 02:52:03] [BLUEPRINT][LOAD] <admin> loaded 5x5x5-Beam-MissileHeatseekers as "blahblahrl13" in (2, 2, 2) as faction 10000




	##############
	#  CONNECTIONS   #
	##############

	elif [ "${1}" == "[SERVER][PLAYERMESSAGE]" ]; then

		# This is a roundabout way to do things.  There may be other requests for player messages.  Really I should probably be tapping into one of the other spawn messages.
		shift
		player=$(echo "${5}" | sed 's/^PlS\[//g')
		echo "PlayerMessage thing found: ${player}"
		echo "All: $@"
		if [ "${1} ${2} ${3} ${4}" == "received message request from" ]; then
			if [ "${player}" ]; then
			#if [ "${player}" == "Benevolent27" -o "${player}" == "DestroyerOfWorlds" ]; then
				"${server_info_to}" "${player}" "Welcome to LvD!"
				runPlayerConnect "${player}"
			#fi
			fi
		fi

	#################
	#  GRAVITY CHANGES    #   - DISABLING TILL OTHER PARTS OF THE WRAPPER ARE WORKING
	#################

	# I am disabling the gravity change hook for now, to re-enable it, just remove the word "disabled" from below.
	elif [ "${1}" == "[CHARACTER][GRAVITY]disabled" ]; then
		shift
		player=$(echo "${1}" | sed 's/^PlayerCharacter\[.ENTITY_PLAYERCHARACTER_//g' | grep -Po "^[A-Za-z0-9_-]*")
		shift
		entityInfo=$(echo "${@}" | grep -Po "source: [A-Za-z]*\[[A-Za-z0-9_ -]*")
		entityType=$(echo "${entityInfo}" | grep -Po '[A-Za-z]*')
		if [ "${entityType}" == "Ship" ]; then
			shipName=$(echo "${b}" | grep -Po "source: Ship\[[A-Za-z0-9_\ -]*" | sed 's/source: Ship\[//g')
			if [ "${player}" -a "${shipName}" ]; then
				echo "Gravity changed for player, ${player}, to entity: ${shipName}"
			elif [ "${player}" ]; then
				echo "Gravity changed for player, ${player}, but no valid entity found."
			fi
			unset shipName
		elif [ "${entityType}" == "SpaceStation" ]; then
		# [2017-09-05 18:40:07] [CHARACTER][GRAVITY] PlayerCharacter[(ENTITY_PLAYERCHARACTER_ONE)(5819)] Server(0) starting gravity change DONE: source: SpaceStation[ENTITY_SPACESTATION_UNIMATRIX ZERO(18607)] origin: (501.25394, 1087.4614, 554.5392)
			stationName=$(echo "${b}" | grep -Po "source: Ship\[[A-Za-z0-9_\ -]*" | sed 's/source: Ship\[//g')

			unset stationName
		fi

		## Run Mod Scripts
		runGravityChange "${player}" "${entityType}" "${entityInfo}"


	##############
	#         DEATHS        #
	##############

	# this one comes from the serverlog.0.log file

	# deathTypes that might be set:
	# star
	# blackhole
	# asteroid
	# planetsegment
	# shipyarddesign
	# suicide
	# entity
	# personInShip
	# person
	# mystery

	elif [ "${1}" == "[DEATH]" ]; then
 		# "${scriptDir}log.sh" "# PROCESSING DEATH TEXT: $@"
		# timeLong=$(echo $b grep -oE '^\[(([0-9\-]|[[:space:]]|(:)))*' | sed 's/^\[//g' | sed 's/\].*//g')
		# time=$("${scriptDir}/core/formatDate.sh" -ht "$timeLong")
		# date=$("${scriptDir}/core/formatDate.sh" -hd "$timeLong")
		person=$(echo $b | grep -oE '\[DEATH\] .* has been killed by' | sed 's/\[DEATH\]//g' | sed 's/ has been killed by//g' | sed 's/ //g')

		# echo "############################# person: ${person}"
		# "${scriptDir}log.sh" "Death Detected: ${person}"
		# If no person's name was found, don't do anything.
		theDate="$(date '+%m-%d-%y')"
		theTime="$(date '+%T')"
		if [ "${person}" ]; then
			message="[${theDate}] [${theTime}]: ${person}"
			# echo "Setting message: ${message}"
			# There are TWO very different ways that both the entity and player name might show up in a death message

			# We gotta see if "responsible" is a "sun" or other sort of entity first before even trying to see if it's a player or ship
			# responsible=$(echo $b | grep -o "'Responsible: .*;" | sed "s/'Responsible: //g" | sed "s/';//g" ) # | sed 's/\[.*//g')
			responsible=$(echo "$b" | grep -o "'Responsible: .*;" | sed "s/'Responsible: //g" | sed "s/';//g" ) # | sed 's/\[.*//g')
			# echo "----------Responsible: -->${responsible}<--"

			# Shipyard:  D_1508536985403 (design)
			shipyardTest=$(echo "${responsible}" | grep -o "\(design\)")

			if [ "${responsible}" == "Sun" ]; then
				deathType="star"
			elif [ "${responsible}" == "Black Hole" ]; then
				deathType="blackhole"
			elif [ "${responsible}" == "Floating Rock <can be harvested>" ]; then
				deathType="asteroid"
			elif [ "${responsible}" == "PlanetSegment(Planet);" ]; then
				deathType="planetsegment"
			elif [ "${shipyardTest}" == "(design)" ]; then
				deathType="shipyarddesign"

			else

				killer=$(echo "$b" | grep -o "'Killer: .* (" | sed "s/'Killer: //g" | sed 's/ (//g')
				# echo "killer: ${killer}"
				# If no killer found by first check, then check for the entity name and person's name via the "responsible entity"
				if [ "w${killer}" == "w" ]; then
					# Gotta figure out why removing the ] fucks up the responsible faction..
					# echo "No Killer found.. Running secondary check.."
					killer=$(echo "${responsible}" | grep -o "<.*>" | sed -E 's/[<>]//g')
					# echo "killer: ${killer}"
					if [ "${person}" == "${killer}" ]; then
						# This probably should be broadened to include suiciding via their own ship
						message="${message} killed themselves."
						deathType="suicide"
					elif [ "${responsible}" ]; then
						if [ "${killer}" ]; then
							message="${message} was killed by ${killer}"
							deathType="person"
						else
							# If no killer was found with the first or second check, then we have to assume an entity will be found, but we'll double check anyhow.
							deathType="entity"
						fi

						# Trying to remove the potential name info prevents this from working.  I need a workaround
						# responsibleEntity=$(echo "${responsible}" | sed -E 's/([^\[]*$)//g' | sed -E 's/((\[$)|(\<.*))//g')

						# This will only work IF there are [ brackets ], such as a faction name in there, so I need to branch out here as well
						responsibleEntity=$(echo "${responsible}" | sed -E 's/([^\[]*$)//g' | sed 's/\[$//g' | sed 's/<.*//g')
						if [ "w${responsibleEntity}" == "w" ]; then
							# echo "Secondary pattern failed, trying tertiary!"
							responsibleEntity=$(echo "${responsible}" | sed -E 's/\[.*//g' | sed 's/<.*//g')
						fi

						# Ths needs to work for entities that have no controlling person.. hmm
						# [2017-10-20 16:29:44] [DEATH] Benevolent327 has been killed by 'Responsible: Benevolent327_1508531362205'; controllable: Ship[Benevolent327_1508531362205](25109)

						# echo 'Destroyer_Drone_Less_Missiles-V2_5-Compliant_15085rl00[The Rebuilders]' | sed -E 's/([^\[]*$)//g' | sed 's/\[$//g'
						# Destroyer_Drone_Less_Missiles-V2_5-Compliant_15085rl00



						# echo "responsibleEntity: ${responsibleEntity}"
						if [ "${responsibleEntity}" ]; then
							# I need to use sed to get rid of the first set of [ brackets ] but then I need to grep -o the second pair I think.. hmm.. Otherwise it will always list the ship name as the faction name.
							# responsibleFaction=$(echo "${responsible}" | sed -E 's/((^.*\[)|(\]$))//g' | grep -o '\[.*\]' | sed -E 's/[\[\]]//g')
							# responsibleFaction=$(echo "$responsible" | sed -E 's/((^.*\[)|(\]$))//g')
							responsibleFaction=$(echo "$responsible" | grep -o '[\[].*' | sed 's/[\[\]]//g')

							# echo "responsibleFaction: ${responsibleFaction}"
							if [ "${responsibleFaction}" ]; then
								message="${message} of the faction, '${responsibleFaction}'"
							fi
							message="${message}, via the entity, '${responsibleEntity}'"
							if [ "${killer}" ]; then
								# We know an entity was found and also a person, so se the death type to being killed by a person in a ship
								deathType="personInShip"
							else
								# Since there was no killer, but there was a responsible entity, set to entity only
								deathType="entity"
							fi

						# Here we double check to ensure the deathType is reset if no responsible entity was found
						elif [ "w${killer}" == "w" ]; then
							echo "${person} died, but no responsible entity nor killer was found!  This should never happen!"
							"${scriptDir}log.sh" "ERROR: ${person} died, but no responsible entity nor killer was found!  This should never happen!"
							deathType="mystery"
						fi
					else
						echo "${person} died, but no responsible entity nor killer was found!  This should never happen!"
						"${scriptDir}log.sh" "ERROR: ${person} died, but no responsible entity nor killer was found!  This should never happen!"
						deathType="mystery"
					fi


					# "${scriptDir}log.sh" "killerCheck: ${killer}"
				# We have a 'killer' type death, so we need to look for the entity now if not a suicide.
				else
					if [ "${person}" == "${killer}" ]; then
						# This probably should be broadened to include suiciding via their own ship
						message="[${theDate}] [${theTime}]: ${person} killed themselves."
						deathType="suicide"
					else
						responsibleEntity=$(echo ${b} | grep -o "controllable: Ship\[.*" | sed -E 's/(\].*)|(^controllable: Ship\[)//g')
						if [ "${responsibleEntity}" ]; then
							# Since we know the killer's name and also the entity, set to having been perpetrated by a person in an entity
							message="[${theDate}] [${theTime}]: ${person} was killed by ${killer}, in entity ${responsibleEntity}"
							deathType="personInShip"

							# Let's look up the responsible faction, if there is one.
							responsibleFaction=$(echo "$responsible" | sed -E 's/((^.*\[)|(\]$))//g')

							if [ "${responsibleFaction}" ]; then
								message="${message}, of the faction, '${responsibleFaction}'"
							fi
						else
							message="[${theDate}] [${theTime}]: ${person} was killed by ${killer}."
							deathType="person"
						fi

					fi
				fi
			fi

			# Need to fix sun damage
			# [DEATH] Benevolent327 has been killed by 'Responsible: Sun'; controllable: Sector[21240](8, 8, 8)


			# todo: When a death is caused by different weapons of the same entity, it will oftentimes spam a bunch of death messages in the logs - this prevents most duplicates from getting through, but really there needs to be a 5 second counter or something applied per name to make it more accurate
			if [ "${lastMessage}" == "${message}" ]; then
				# "${scriptDir}log.sh" "Duplicate Death: ${message}"
				echo "SKIPPING DUPLICATE DEATH MESSAGE" > /dev/null #: ${message}"
				# echo "##### SKIPPED INFOS ######"
				# echo "# theDate: ${theDate}  theTime: ${theTime}  deathType: ${deathType}"
				# echo "# responsibleEntity: ${responsibleEntity}"
				# echo "# killer: ${killer}  responsibleFaction: ${responsibleFaction}"
				# echo "#### END SKIPPED INFOS #####"

			else
				# "${scriptDir}log.sh" "# PROCESSING DEATH TEXT: $@"

				echo "${message}"
				echo " "
				echo "##### INFOS ######"
				# echo "# Everything: ${b}"
				echo "# theDate: ${theDate}  theTime: ${theTime}  deathType: ${deathType}"
				echo "# responsibleEntity: ${responsibleEntity}"
				echo "# killer: ${killer}  responsibleFaction: ${responsibleFaction}"
				echo "#### END INFOS #####"
				echo " "
				if [ "${deathType}" == "suicide" ]; then
					"${scriptDir}wrapper/melvin_public_chat.sh" "Haw haw, ${person} totally just killed themselves."

					## Run Mod Scripts
					runPlayerDeath "${person}" "${deathType}"
				elif [ "${deathType}" == "person" ]; then
					"${scriptDir}wrapper/melvin_public_chat.sh" "Whaaat!  ${killer} just WHACKED ${person}!  :D"

					## Run Mod Scripts
					runPlayerDeath "${person}" "${deathType}" "${killer}"
				elif [ "${deathType}" == "personInShip" ]; then
					if [ "${responsibleFaction}" ]; then
						ofTheFaction=", of the faction '${responsibleFaction}',"
					fi
					"${scriptDir}wrapper/melvin_public_chat.sh" "${killer}${ofTheFaction} just WHACKED ${person} while piloting the entity, '${responsibleEntity}'!  :D"
					unset ofTheFaction
					runPlayerDeath "${person}" "${deathType}" "${killer}" "${responsibleEntity}"
				elif [ "${deathType}" == "entity" ]; then
					if [ "w${responsibleFaction}" == "w" ]; then
						## Run Mod Scripts
						runPlayerDeath "${person}" "${deathType}" "${responsibleEntity}"
						"${scriptDir}wrapper/melvin_public_chat.sh" "${person} was PWNED by an entity, '${responsibleEntity}'!"
					else
						"${scriptDir}wrapper/melvin_public_chat.sh" "${person} was PWNED by an entity, '${responsibleEntity}', from the faction, ${responsibleFaction}!  Muwhaha!"

						## Run Mod Scripts
						"${scriptDir}log.sh" "DEBUGGING PARSER: ${responsibleEntity}"
						runPlayerDeath "${person}" "${deathType}" "${responsibleEntity}" "${responsibleFaction}"
					fi
				elif [ "${deathType}" == "blackhole" ]; then
					"${scriptDir}wrapper/melvin_public_chat.sh" "${person} was spaghettified!  :D"
					runPlayerDeath "${person}" "${deathType}" "${responsible}"
				elif [ "${deathType}" == "star" ]; then
					"${scriptDir}wrapper/melvin_public_chat.sh" "${person} was burned alive by a star!  Praise the sun!"
					runPlayerDeath "${person}" "${deathType}" "${responsible}"
				elif [ "${deathType}" == "asteroid" ]; then
					"${scriptDir}wrapper/melvin_public_chat.sh" "${person} just got ROCKED by an asteroid!"
					runPlayerDeath "${person}" "${deathType}" "${responsible}"
				elif [ "${deathType}" == "planetsegment" ]; then
					"${scriptDir}wrapper/melvin_public_chat.sh" "${person} couldn't handle planet life.  Goodbye world!"
					runPlayerDeath "${person}" "${deathType}" "${responsible}"


				elif [ "${deathType}" == "planetsegment2" ]; then
					"${scriptDir}wrapper/melvin_public_chat.sh" "${person} just got their skin melted off by molten lava!  D:"
					runPlayerDeath "${person}" "${deathType}" "${responsible}"
				elif [ "${deathType}" == "shipyarddesign" ]; then
					"${scriptDir}wrapper/melvin_public_chat.sh" "${person} just lived the impossible dream!  Death by design!  :DDDDD"
					runPlayerDeath "${person}" "${deathType}" "${responsible}"
				else
					# This should never happen, but knowing StarMade it will.  I think if a player suicides before spawning in, this will happen.  So this needs to be fixed.
					"${scriptDir}wrapper/melvin_public_chat.sh" "${person} seems to have died from mysterious circumstances.."

					## Run Mod Scripts - This will likely be broken and this will need to be fixed.
					runPlayerDeath "${person}" "${deathType}" "${responsibleEntity}" "${responsibleFaction}"
				fi
			fi
			lastMessage="${message}"
			# Here is where I need to run any sort of death scripts


			unset deathType
			unset message
			unset killer
		fi
		unset person
		unset theDate
		unset theTime



	###################################
	#         SHIP OR SPACE STATION DESTRUCTION        #
	###################################

	# entityDeath.sh

	elif [ "${1}" == "[SEGMENTCONTROLLER]" ]; then

		if [[ ${@} == *HAS\ BEEN\ DESTROYED... ]]; then
			# result=$(echo "${b}" | sed 's/(.*//g')
			entityType=$(echo "${b}" | grep -oP "ENTITY [a-zA-Z]*" | sed 's/^ENTITY //g')
			entityUID=$(echo "${b}" | grep -oP "ENTITY ${entityType}\[[A-Za-z0-9 _-]*" | sed "s/^ENTITY ${entityType}\[//g")
			echo "########### ENTITY DESTRUCTION OCCURRED"
			echo "ENTITY DESTROYED: ${entityUID}"
			echo "ENTITY TYPE: ${entityType}"
			echo "###########"
			runEntityDeath "${entityType}" "${entityUID}"
		fi


	# [2017-11-06 21:14:50] [SEGMENTCONTROLLER] ENTITY SpaceStation[ENTITY_SPACESTATION_baseTest(2554)] HAS BEEN DESTROYED...
	#[2017-11-06 18:26:55] [SEGMENTCONTROLLER] ENTITY Ship[DeadShip5](341) HAS BEEN DESTROYED...

	##############
	#         FACTION       #
	##############

# logFactionJoinsAndLeaves
# announceFactionJoinsAndLeaves



	# Joining a faction
	elif [ "${1}" == "[FACTION]" ]; then
		# [2017-11-30 05:21:32] [FACTION] Added to members DestroyerOfWorlds perm(0) of Faction [id=10002, name=NewFaction, description=Faction name, size: 2; FP: 119] on Server(0)
		shift
		if [ "${1}" == "Added" ]; then
			# A player was added to a faction
			shift
			shift
			shift
			name="${1}"
			action="playerJoin"
			factionID="$(echo "${@}" | grep -Po "Faction \[id=[0-9]*" | sed 's/^Faction \[id=//g')"
			factionName="$(echo "${@}" | grep -Po ", name=[0-9A-Za-z _-]*" | sed 's/^, name=//g')"
			runPlayerFaction "${name}" "${action}" "${factionID}" "${factionName}"
			if [ "${logFactionJoinsAndLeaves}" == "true" ]; then
				"${scriptDir}log.sh" "Player, ${name}, joined faction ${factionName} (ID: ${factionID})." &
			fi
			if [ "${announceFactionJoinsAndLeaves}" == "true" ]; then
				"${public_chat}" "${name} has joined the faction, '${factionName}'."
			fi
		fi

	# Leaving a faction
	elif [ "${1}" == "[FACTIONMANAGER]" ]; then
		# [2017-11-30 04:21:58] [FACTIONMANAGER] removing member: Benevolent27 from Faction [id=10001, name=NewFaction, description=Faction name, size: 1; FP: 100]; on Server(0)
		shift
		if [ "${1}" == "removing" ]; then
			# A player was added to a faction
			shift
			shift
			name="${1}"
			action="playerLeave"
			factionID="$(echo "${@}" | grep -Po "Faction \[id=[0-9]*" | sed 's/^Faction \[id=//g')"
			factionName="$(echo "${@}" | grep -Po ", name=[0-9A-Za-z _-]*" | sed 's/^, name=//g')"
			runPlayerFaction "${name}" "${action}" "${factionID}" "${factionName}"
			if [ "${logFactionJoinsAndLeaves}" == "true" ]; then
				"${scriptDir}log.sh" "Player, ${name}, left faction ${factionName} (ID: ${factionID})." &
			fi
			if [ "${announceFactionJoinsAndLeaves}" == "true" ]; then
				"${public_chat}" "${name} has left the faction, '${factionName}'."
			fi


		fi


	################
	#        SHUTDOWN       #
	################


		# [2017-12-05 17:10:05] [SHUTDOWN] Shutting down server
		# [2017-12-05 17:10:05] [SHUTDOWN] shutting down element collection thread
		# [2017-12-05 17:10:05] [SHUTDOWN] shutting down pathfinding threads
		# [2017-12-05 17:10:05] [SHUTDOWN] shutting down universe
		# [2017-12-05 17:10:05] [SHUTDOWN] shutting down segment request thread
		# [2017-12-05 17:10:05] [SHUTDOWN] shutting down simulation
		# [2017-12-05 17:10:05] [SHUTDOWN] shutting down active checker
		# [2017-12-05 17:10:05] [SHUTDOWN] shutting sysin listener
		# [2017-12-05 17:10:05] [SHUTDOWN] shutting down mob thread
		# [2017-12-05 17:10:05] [SHUTDOWN] shutting down game map provider
		# [2017-12-05 17:10:05] [SHUTDOWN] server stop listening
		# [2017-12-05 17:10:05] [SHUTDOWN] disconnecting all clients
		# [2017-12-05 17:10:05] [SHUTDOWN] writing current universe STARTED
		# [2017-12-05 17:10:05] [DISCONNECT] Client 'RegisteredClient: Inquisitor (15) [NaStral]connected: true' IP(/73.206.223.45:50113) HAS BEEN DISCONNECTED . PROBE: false; ProcessorID: 10521
		# [2017-12-05 17:10:53] [SHUTDOWN] database closed successfully
		# [2017-12-05 17:10:53] [SHUTDOWN] writing current universe FINISHED

	################
	#        STARTING          #
	################
		# [2017-12-05 17:11:14] STARMADE SERVER VERSION: 0.199.654; Build(20170826_140955)
		# [2017-12-05 17:11:14] STARMADE SERVER STARTED: Tue Dec 05 17:11:14 EST 2017


	##############
	#         SERVER        #
	##############

	elif [ "${1}" == "[SERVER]" ]; then
		# I may be removing this section.	This next line is just to make the script function.
		silent="$@"
		# echo "---Server response detected. ${b}"
		# shift
		# echo "1: ${1}"
		#  if [ "${1}" == "Object" ]; then
		# 	shift
			# ship=$(echo "${b}" | grep -Po "^Ship\[[A-Za-z0-9\ _-]*" | sed 's/^Ship\[//g')

			# Sitting down and standing up:
			# ---Server response detected. [2017-10-20 18:22:35] [SERVER] PlS[Joshatron [Joshatron]; id(2209)(10)f(10004)] sitting down (16, 17, 16) (15, 17, 16)
			# 1: PlS[Joshatron
			# ---Server response detected. [2017-10-20 18:22:37] [SERVER] PlS[Joshatron [Joshatron]; id(2209)(10)f(10004)]standing up


	# This was the old way of seeing when a ship was created, but it relies on the main log, not the serverlog.0.log and does not have the player name associated with the ship
	##################
	#   OLD SECTION - SCHEDULED FOR REMOVAL --- NEW SHIP CREATION  #
	##################

			# shipNewTest=$(echo "$@" | grep "didn't have a db entry yet. Creating entry!")

			# This is flawed because right now there is no player name attached to the creation of the ship, so it's not really very useful unfortunately.  Though commands can be used to grab the location of the ship, this is not preferred since it introduces slowdowns to the wrapper that should be avoidable.  Also, if trying to grab the creator, a force_save must be done before the database is updated... very annoying.
			# if [ "${shipNewTest}" ]; then
			#	ship=$(echo "${b}" | grep -Po "Ship\[[A-Za-z0-9\ _\-]*" | sed 's/^Ship\[//g')
			#	echo "New ship created: ${ship}"

				## Run Mod Scripts
			#	runNewShip "${ship}"
			#fi

			# [SERVER] Object Ship[Benevolent27_1504644685389](18167) didn't have a db entry yet. Creating entry!
		#fi
	# elif [[ "${1}" == \[SERVER\] Object Ship\[.* ]]; then
	# PlayerCharacter[(ENTITY_PLAYERCHARACTER_Benevolent27)(16933)] Server(0) starting gravity change DONE: source: Ship[Benevolent27_1504515707246](16802) origin: (92.771065, 32.98219, -160.00371)
	# else
		# echo "${b}"

	fi
done < <( stdbuf -i0 -o0 "${scriptDir}wrapper2.0/filter.sh" )
