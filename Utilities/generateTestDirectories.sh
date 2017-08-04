basedir="$(dirname "$0")/.."

orig="$basedir/iSEPTA/iSEPTA"
cd $orig
dest="../iSEPTATests"

find . ! \(   -name '*.*' \)  -type d -exec mkdir -p -- $dest/{} \;

