#!/bin/bash
# This script part will be autogenerated when the wrapper starts.  It loads the appropriate variables for the mod script to use.  This is to allow the script to be "installed" to any folder.
scriptDir=~/scripts/
wrapperDir="${scriptDir}wrapper2.0/"

addIniVariable="${wrapperDir}bin/ini/addIniVariable.sh"
checkIniIfVariableExists="${wrapperDir}bin/ini/checkIniIfVariableExists.sh"
getIniValue="${wrapperDir}bin/ini/getIniValue.sh"
getIniVariables="${wrapperDir}bin/ini/getIniVariables.sh"
renIniVariable="${wrapperDir}bin/ini/renIniVariable.sh"
rmIniVariable="${wrapperDir}bin/ini/rmIniVariable.sh"
setIniVariable="${wrapperDir}bin/ini/setIniVariable.sh"

modsDir="${wrapperDir}mods/"
command="${1}"
modFolder="$(echo "${command}" | sed -E 's/[0-9A-Za-z \._-]*$//g')/"
echo "ModFolder set: ${modFolder}"
userFolder="${modFolder}userFiles/"
echo "userFolder: ${userFolder}"
commandsFolder="${modFolder}commands/"
echo "commandsFolder: ${commandsFolder}"

wrapperBinFolder="${wrapperDir}bin/"
echo "wrapperBinFolder: ${wrapperBinFolder}"


binFolder="${modFolder}bin/"
echo "binFolder: ${binFolder}"

shift
everythingElse="${@}"
echo "everythingElse: ${everythingElse}"
name="${1}"

function runScript {
	# This runs the script in-line so that it inherits the variables set above
	echo "Running: ${command} ${everythingElse}"
	. "${command}" "${@}"
}

# First check to see if the script is an admin-only script or not, and only run it if the person is an admin if so.
commandIni="$(echo "${command}" | sed 's/\.sh$//g').ini"
echo "commandIni: ${commandIni}"

isScriptOnlyAdmin="$("${getIniValue}" -quiet "${commandIni}" adminOnly | tr '[:upper:]' '[:lower:]')"
echo "isScriptOnlyAdmin: ${isScriptOnlyAdmin}"

if [ "${isScriptOnlyAdmin}" == "true" ]; then
	isPlayerAdmin=$("${wrapperBinFolder}user/isAdmin.sh" "${name}")
	if [ "${isPlayerAdmin}" == "true" ]; then
		runScript "$@"
	else
		# To do - set up error messaging handling for admin only commands.
		echo "Script set to admin-only and player was not an admin! Doing nothing!  Though really there should be an error message given."
	fi
else
	runScript "$@"
fi
