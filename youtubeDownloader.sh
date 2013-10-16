#!/bin/bash

if [ "$UID" -ne "0" ]
then
  echo; echo "You must be root to run this script. Try sudo ./$0"; echo
  exit 1
fi

echo "\n" | sudo add-apt-repository ppa:nilarimogard/webupd8
sudo apt-get update
sudo apt-get -y install youtube-dl

exit 0
