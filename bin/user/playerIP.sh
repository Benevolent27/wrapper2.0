#!/bin/bash
if [ "$1" ]; then
echo $(~/scripts/sendraw2.sh /player_info "$1" | grep "RETURN\: \[SERVER, \[PL\] IP\:" | sed 's/RETURN: \[SERVER, \[PL\] IP: //' | sed 's/\///' | sed 's/\, 0\]//' | sed ':a;N;$!ba;s/\n//g' | sed 's/\r//' )
else
echo 'Usage: playerIP.sh [PlayerName]'
fi
