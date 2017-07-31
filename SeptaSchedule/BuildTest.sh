#!/bin/bash

xcodebuild -scheme SeptaSchedule -destination 'platform=iOS Simulator,id=433B61B8-9402-4DE8-B5FA-9A5C5917D8B7' test | xcpretty