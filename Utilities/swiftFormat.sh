#!/usr/bin/env bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR/.."
/usr/local/bin/swiftformat ./iSEPTA/
/usr/local/bin/swiftformat ./SeptaSchedule/ 
/usr/local/bin/swiftformat ./SeptaRest/ 

