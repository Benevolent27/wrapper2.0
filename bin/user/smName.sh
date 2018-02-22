#!/bin/bash
if [ "$1" ]; then
echo $(~/scripts/sendraw2.sh /player_info "$1" | grep SM-NAME | sed 's/RETURN: \[SERVER, \[PL\] SM-NAME: //' | sed 's/\, 0\]//' | sed ':a;N;$!ba;s/\n//g' | sed 's/\r//' )
# RETURN: [SERVER, [PL] SM-NAME: Benevolent27, 0]
else
echo 'Usage: smName.sh [PlayerName]'
fi
