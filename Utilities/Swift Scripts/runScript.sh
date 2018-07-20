swift "$1"

if [ $? -eq 0 ]; then
    swiftformat "$1"
else
    echo FAIL
fi
