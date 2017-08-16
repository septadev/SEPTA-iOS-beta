#!/usr/bin/env bash

log="./../Utilities/format.log"
pwd > $log
/usr/local/bin/swiftformat . >> "$log"
/usr/local/bin/swiftformat ./../SeptaSchedule/ >> "$log"
echo "run complete $(date)" >> "$log"
