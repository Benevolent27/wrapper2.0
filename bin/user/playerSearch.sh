#!/bin/bash
if [ "${1}" == "-exact" ]; then
	exact="true"
	shift
fi
my_dir="`( cd \"$MY_PATH\" && pwd )`"
cd ~/starmade/StarMade/server-database/world1/
if [ "${exact}" == "true" ]; then
	for b in ENTITY_PLAYERSTATE_*.ent; do
		# echo "Processing: ${b}"
		result=$(echo ${b} | grep -i "^ENTITY_PLAYERSTATE_${1}\.ent" | sed 's/^ENTITY_PLAYERSTATE_//g' | sed 's/\.ent$//g')
		if [ "${result}" ]; then
			echo "${result}"
		fi
		unset result
	done
else
	ls -1 | grep -i "ENTITY_PLAYERSTATE_.*\.ent" | sed 's/ENTITY_PLAYERSTATE_//g' | sed 's/\.ent$//g' | agrep -iB "$1" | tail
fi
cd "${my_dir}"
