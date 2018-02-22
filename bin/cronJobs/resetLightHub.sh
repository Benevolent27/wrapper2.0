#!/bin/bash
scriptDir="/home/starmade/scripts/"
cd "${scriptDir}wrapper2.0/bin/cronJobs/"
# "${scriptDir}log.sh" "resetDarkAndLightHub.sh - Beginning reset for Infernal Armaments and Vanquishers Emporium.."
# "${scriptDir}sector/importSectorThenMoveBasesFromTempToEndSector.sh" "62 11 -45" "15000 116 100" Infernal_Armaments.smsec
# 0 0 0
"${scriptDir}sector/importSectorThenMoveBasesFromTempToEndSector.sh" "49 -19 133" "15000 124 100" Vanquishers_Emporium.smsec
# ~/scripts/sector/importSectorThenMoveBasesFromTempToEndSector.sh "888 888 888" "15000 124 100" Vanquishers_Emporium.smsec
"${scriptDir}log.sh" "resetDarkAndLightHub.sh - Finished reseting Infernal Armaments and Vanquishers Emporium!"
