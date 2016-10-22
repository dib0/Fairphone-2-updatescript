#!/bin/sh

function error_exit {
    local parent_lineno="$1"
    local message="$2"
    local code="${3:-1}"
    if [[ -n "$message" ]] ; then
	echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
    else
	echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
    fi

    exit "${code}"
}
trap 'error_exit ${LINENO}' ERR

echo "Connect phone in recovery mode with sideload option on!"
echo "Press <enter> to continue"
read

# Get newest firmware download
link=$(lynx --dump $1 'https://fairphone.zendesk.com/hc/en-us/articles/213290023-Fairphone-OS-downloads-for-Fairphone-2'|awk '/http/{print $2}'|grep '.zip'|head -n1)

echo "-= Downloading update =-"
wget $link

fileName=$(echo $link|rev|cut -d/ -f1|rev)
androiddir=$(locate platform-tools|head -n1)

echo "-= Sideloading update =-"
sudo $androiddir/adb sideload $fileName

echo "-= Removing update =-"
sudo rm -f $fileName

echo "-= Done! Reboot the phone =-"
