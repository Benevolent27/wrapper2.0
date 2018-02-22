#!/bin/bash
# Simple Usage:  safe_change_sector_for.sh PlayerName [coord X] [coord Y] [coord Z]
# Full Usage:  safe_change_sector_for.sh -retry [number] -sender [admin name] PlayerName [coord X] [coord Y] [coord Z] [Spacial X] [Spacial Y] [Spacial Z]


# Needs to be tested - also needs to account for if a player goes offline to let the admin know and also to stop trying.

scriptDir=~/scripts/
wrapperDir=~/scripts/wrapper/
server_message_to="$scriptDir"server_message_to.sh
user_dir=~/scripts/wrapper/userfiles/
melvin_chat="$wrapperDir"melvin_chat.sh



	if [ "$1" == "-retry" -o "$1" == "-sender" ]; then
		if [ "$1" == "-retry" ]; then
			shift
			retry="$1"
			shift
		fi
		if [ "$1" == "-sender" ]; then
			shift
			sender="$1"
			shift
		fi
	fi
	if [ "$1" == "-retry" -o "$1" == "-sender" ]; then
		if [ "$1" == "-retry" ]; then
			shift
			retry="$1"
			shift
		fi
		if [ "$1" == "-sender" ]; then
			shift
			sender="$1"
			shift
		fi
	fi


#	if [ "$1" == "-retry" ]; then
#		shift
#		retry="$1"
#		shift
#	fi
#	if [ "$1" == "-sender" ]; then
#		shift
#		sender="$1"
#		shift
#	fi
if [ "$1" -a "$1" != "help" -a "$1" != "-help" -a "$1" != "--help" ]; then
	name="$1"
	shift
	X=$1
	Y=$2
	Z=$3
	shift
	shift
	shift
	SX=$1
	SY=$2
	SZ=$3
	# Temp
	# echo "Attempting to teleport player, "$name" to coordinates, "$X" "$Y" "$Z" with spacial coordinates, "$SX" "$SY" "$SZ"!"
	# sleep 5
	playerInEntity=$("$scriptDir"/user/playerEntity.sh -type $name)
	if ! [ $playerInEntity ]; then
		"$scriptDir"sendraw2.sh /change_sector_for $name $X $Y $Z  > /dev/null
		if [ "$SZ" ]; then
			"$scriptDir"sendraw2.sh /teleport_to $name $SX $SY $SZ  > /dev/null
		fi
		if [ "$sender" ]; then
			"$melvin_chat" $name $sender" has teleported you to coordinates, "$X" "$Y" "$Z"!"
			if ! [ "$SZ" ]; then
				"$melvin_chat" $sender $name" has been teleported to coordinates, "$X" "$Y" "$Z"!"
			else
				"$melvin_chat" $sender $name" has been teleported to coordinates, "$X" "$Y" "$Z", and spacial coordinates, "$SX" "$SY" "$SZ"!"
			fi
		else
			"$melvin_chat" $name "You have been teleported to coordinates, "$X" "$Y" "$Z"!"
			if ! [ "$SZ" ]; then
				echo $name" has been teleported to coordinates, "$X" "$Y" "$Z"!"
			else
				echo $name" has been teleported to coordinates, "$X" "$Y" "$Z", and spacial coordinates, "$SX" "$SY" "$SZ"!"
			fi
		fi
	else
		if ! [ "$retry" ]; then
			if [ "$sender" ]; then
				"$melvin_chat" $sender "Failed to change_sector_for "$name"!  They were in an entity ("$playerInEntity")!"
				"$melvin_chat" $name $sender" attempted to have me teleport you somewhere, but you were in an entity ("$playerInEntity")!  Please exit the build block or core and have "$sender" try again!"
			else
				echo "Failed to change_sector_for "$name"!  They were in an entity ("$playerInEntity")!"
			fi


		else
			if [ "$sender" ]; then
				"$melvin_chat" $sender "Failed to change_sector_for "$name"!  They were in an entity ("$playerInEntity")! Retrying up to "$retry" times..And nagging the player to exit their entity ("$playerInEntity").  I will let you know the result when done!"
			else
				echo "Failed to change_sector_for "$name"!  They were in an entity ("$playerInEntity")! Retrying up to "$retry" times..And nagging the player to exit their entity ("$playerInEntity").  I will let you know the result when done!"
			fi
			counter=1
			while [ "$counter" -le "$retry" -a "$playerInEntity" ]; do
				"$melvin_chat" $name "An admin is attempting to teleport you somewhere safely.  Please exit the core or build block you are in.. Retry "$counter" of "$retry
				sleep 10
				playerInEntity=$("$scriptDir"/user/playerEntity.sh -type $name)
				let counter++
			done
			let counter--
			if [ "$playerInEntity" ]; then
				"$melvin_chat" $name "Ok, I am just going to give up here.. I will let the admin know you did not comply.  Mkaythxbai"
				if [ "$sender" ]; then
					"$melvin_chat" $sender "Ok, I give up on trying to change_sector_for "$name" to coords, "$X" "$Y" "$Z".  I tried a total of "$counter" times.  You will have to take it from here buddy."
				else
					echo "Ok, I give up on trying to change_sector_for "$name" to coords, "$X" "$Y" "$Z".  I tried a total of "$counter" times.  You will have to take it from here buddy."
				fi
			else
				"$scriptDir"sendraw2.sh /change_sector_for $name $X $Y $Z > /dev/null
				"$melvin_chat" $name "Phew.. Finally.. I only had to tell you "$counter" times.. But hey!  You have arrived at "$X" "$Y" "$Z"!  Congratulations!"
				if [ "$SZ" ]; then
					"$scriptDir"sendraw2.sh /teleport_to $name $SX $SY $SZ > /dev/null
					if [ "$sender" ]; then
						"$melvin_chat" $sender "Phew!  I finally managed to get player, "$name", to coordinates, "$X" "$Y" "$Z" and spacial coordinates, "$SX" "$SY" "$SZ". It only took "$counter" nags!"
					else
						echo "Phew!  I finally managed to get player, "$name", to coordinates, "$X" "$Y" "$Z" and spacial coordinates, "$SX" "$SY" "$SZ". It only took "$counter" nags!"
					fi
				else
					if [ "$sender" ]; then
						"$melvin_chat" $sender "Phew!  I finally managed to get player, "$name", to coordinates, "$X" "$Y" "$Z". It only took "$counter" nags!"
					else
						echo "Phew!  I finally managed to get player, "$name", to coordinates, "$X" "$Y" "$Z". It only took "$counter" nags!"
					fi
				fi
			fi
		fi
		#	echo "Attempted to change_sector_for player, "$name" but the player was in an entity.  No -retry specified, so giving up!"
		# fi
	fi
	
else
	if [ "$sender" ]; then
		"$melvin_chat" $sender "This command is used to safely teleport/change_sector_for a player.  It will ONLY teleport the player if they are NOT in a build block or ship core."
		"$melvin_chat" $sender "You can also specify for the script to nag the player to exit their build block or ship core every 10 seconds up to a certain amount of retries."
		"$melvin_chat" $sender " "
		"$melvin_chat" $sender "Simple Usage:  !safe_change_sector_for PlayerName [coord X] [coord Y] [coord Z]"
		"$melvin_chat" $sender "Full Usage:  !safe_change_sector_for -retry [number] PlayerName [coord X] [coord Y] [coord Z] [Spacial X] [Spacial Y] [Spacial Z]"
		"$melvin_chat" $sender " "
		"$melvin_chat" $sender "Note that if you do not specify a -retry number, it will give up on the first try."
	else
		echo "Simple Usage:  safe_change_sector_for.sh PlayerName [coord X] [coord Y] [coord Z]"
		echo "Full Usage:  safe_change_sector_for.sh -retry [number] -sender [admin name] PlayerName [coord X] [coord Y] [coord Z] [Spacial X] [Spacial Y] [Spacial Z]"
	fi
fi