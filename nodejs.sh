#!/bin/bash

if [ "$UID" -ne "0" ]
then
  echo "" 
  echo "You must be sudoer or root. To run this script enter:"
  echo ""
  echo "sudo chmod +x $0; sudo ./$0"
  echo ""
  exit 1
fi

echo "\n" | sudo add-apt-repository ppa:chris-lea/node.js  
sudo apt-get update  
sudo apt-get upgrade

sudo apt-get install nodejs

exit 0
