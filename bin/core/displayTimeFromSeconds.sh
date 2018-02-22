#!/bin/bash
if [ "$1" == "-debug" ]; then
	debug="true"
	shift
fi
function decho {
	if [ "${debug}" == "true" ]; then
		echo "$@"
	fi
}
if [ "$1" ]; then
	T=$1
	decho "T: ${T}"
	D=$((T/60/60/24))
	decho "D: ${D}"
	H=$((T/60/60%24))
	decho "H: ${H}"
	M=$((T/60%60))
	decho "M: ${M}"
	S=$((T%60))
	decho "S: ${S}"
	[[ $D > 1 ]] && printf '%d days ' $D
	[[ $D = 1 ]] && printf '%d day ' $D
	[[ $H > 1 ]] && printf '%d hours ' $H
	[[ $H = 1 ]] && printf '%d hour ' $H
	[[ $M > 1 ]] && printf '%d minutes ' $M
	[[ $M = 1 ]] && printf '%d minute ' $M
	[[ $D > 0 || $H > 0 || $M > 0 ]] && [[ $S > 0 ]] && printf 'and '
	[[ $S > 1 ]] && printf '%d seconds' $S
	[[ $S = 1 ]] && printf '%d second' $S
	[[ $D = 0 && $H = 0 && $M = 0 && $S = 0 ]] && printf '%d seconds' $S
	printf '\n'
else
	echo "Usage:  displayTimeFromSeconds.sh [NumberOfSeconds]"
fi