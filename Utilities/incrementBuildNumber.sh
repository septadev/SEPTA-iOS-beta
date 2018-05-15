InfoPlist=iSEPTA/iSEPTA/Info/iSEPTA-Release-Info.plist
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$InfoPlist")  
buildNumber=$(($buildNumber + 1))  
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$InfoPlist"