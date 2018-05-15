basedir="$(dirname "$0")/.."
# Generate a test file for each swift file in the project
orig="$basedir/iSEPTA/iSEPTA"
cd $orig
dest="../iSEPTATests"

find . \(   -name '*.swift' \)  -type f \
      | xargs -I file \
      | perl -pe 's/\.swift/Tests.swift/g' \
      | xargs -I File touch "$dest/File"