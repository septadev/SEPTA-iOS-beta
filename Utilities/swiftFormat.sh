#!/usr/bin/env bash

log="./../Utilities/format.log"
pwd > $log
/usr/local/bin/swiftformat . >> "$log"
/usr/local/bin/swiftformat ./../SeptaSchedule/ >> "$log"
/usr/local/bin/swiftformat ./../SeptaRest/ >> "$log"
echo "run complete $(date)" >> "$log"
