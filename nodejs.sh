#!/bin/bash

############################################################################
#
# Author: Nil Portugués Calderó <contact@nilportugues.com>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
############################################################################

if [ "$UID" -ne "0" ]
then
  echo "" 
  echo "You must be sudoer or root. To run this script enter:"
  echo ""
  echo "sudo chmod +x $0; sudo ./$0"
  echo ""
  exit 1
fi

## Install NodeJS
echo "\n" | sudo add-apt-repository ppa:chris-lea/node.js  
sudo apt-get update  
sudo apt-get upgrade
sudo apt-get install nodejs

## Install GruntJS
npm install -g grunt grunt-cli

exit 0
