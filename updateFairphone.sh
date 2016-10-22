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

echo "Connect phone with usb debugging on!"
echo "Press <enter> to continue"
read

# Get newest bootimage download
link=$(lynx --dump $1 'https://fairphone.zendesk.com/hc/en-us/articles/213290023-Fairphone-OS-downloads-for-Fairphone-2'|awk '/http/{print $2}'|grep '.zip'|head -n1)
fileName=$(echo $link|rev|cut -d/ -f1|rev)
version=$(echo $fileName|cut -d- -f3)

linkImage=$(lynx --dump $1 'https://fp2.retsifp.de/beta/'|awk '/http/{print $2}'|grep "$version/"|head -n1)
linkImage=$(lynx --dump $1 "$linkImage"|awk '/http/{print $2}'|grep '.img'|grep '-eng-'|head -n1)

echo "-= Downloading root image =-"
wget $linkImage

fileName=$(echo $linkImage|rev|cut -d/ -f1|rev)
androiddir=$(locate platform-tools|head -n1)

echo "-= Reboot phone =-"
sudo $androiddir/adb reboot bootloader
sleep 30

echo "-= Push boot.img =-"
sudo $androiddir/fastboot flash boot $fileName
sleep 10

echo "-= Reboot phone =-"
sudo $androiddir/fastboot reboot

echo "-= Removing file =-"
sudo rm -f $fileName
