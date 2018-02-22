#!/bin/bash
results=$(~/scripts/sendraw2.sh -q2 /sql_query 'SELECT * TYPE FROM PUBLIC.PLAYERS')
echo "done!"
