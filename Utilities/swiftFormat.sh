#!/usr/bin/env bash

log="/Users/mbroski/Code/Septa/Septa2/Utilities/format.log"
/usr/local/bin/swiftformat /Users/mbroski/Code/Septa/Septa2/iSEPTA > "$log"
/usr/local/bin/swiftformat /Users/mbroski/Code/Septa/Septa2/SeptaSchedule >> "$log"
echo "run complete $(date)" >> "$log"
