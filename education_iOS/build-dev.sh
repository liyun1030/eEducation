##!/bin/sh
#ArchivePath=AgoraEducationDev.xcarchive
#IPAName="IPADEV"
#
#xcodebuild clean -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration DevRelease
#xcodebuild archive -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation"  -configuration DevRelease -archivePath ${ArchivePath} -quiet || exit
#xcodebuild -exportArchive -exportOptionsPlist exportPlist.plist -archivePath ${ArchivePath} -exportPath ${IPAName} -quiet || exit
#cp ${IPAName}/AgoraEducation.ipa AgoraEducationDev.ipa
echo "===>0"
echo $0
echo "===>1"
echo $1
echo "===>2"
echo $2
echo "===>3"
echo $3

#curl -X POST \
#https://upload.pgyer.com/apiv1/app/upload \
#-H 'content-type: multipart/form-data' \
#-F "uKey=$1" \
#-F "_api_key=$2" \
#-F  "file=@AgoraEducationDev.ipa"
