#!/bin/bash

#  Uses the swift gen utility:  https://github.com/SwiftGen/SwiftGen
#  run this script the working directory at the top of the project
# will generate helpful classes for working with storyboards and assets


PROJ="/Users/mbroski/Code/Septa/Septa2/iSEPTA/iSEPTA"
/usr/local/bin/swiftgen images -t swift3 "$PROJ/Assets/Assets.xcassets" > "$PROJ/Assets/Asset.swift"

SB="$PROJ/Main/Storyboards.swift"
/usr/local/bin/swiftgen storyboards -t swift3 "$PROJ" > "$SB"
perl -pi -e 's/^import Septa//g' "$SB"
perl -pi -e 's|^//.*\n||g' "$SB"
perl -pi -e 's|Septa\.||g' "$SB"


