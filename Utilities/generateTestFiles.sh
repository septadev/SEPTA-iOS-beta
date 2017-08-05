basedir="$(dirname "$0")/.."

orig="$basedir/iSEPTA/iSEPTA"
cd $orig
dest="../iSEPTATests"

find .  \(   -name '*.swift' \)  -type f