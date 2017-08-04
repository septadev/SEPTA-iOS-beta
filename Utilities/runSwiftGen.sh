#!/bin/bash

#  Uses the swift gen utility:  https://github.com/SwiftGen/SwiftGen
#  run this script the working directory at the top of the project
# will generate helpful classes for working with storyboards and assets



swiftgen images -t swift3 "iSEPTA/iSEPTA/Assets/Assets.xcassets" > iSEPTA/iSEPTA/Assets/Asset.swift

swiftgen storyboards -t swift3 "iSEPTA/iSEPTA" > iSEPTA/iSEPTA/Main/Storyboards.swift
perl -pi -e 's/^import Septa//g' iSEPTA/iSEPTA/Main/Storyboards.swift
perl -pi -e 's|^//.*\n||g' iSEPTA/iSEPTA/Main/Storyboards.swift
perl -pi -e 's|Septa\.||g' iSEPTA/iSEPTA/Main/Storyboards.swift


