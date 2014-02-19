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

###########################################################
# INSTALLATION
###########################################################

## Add the repo for mongoDB
sudo echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" >> /etc/apt/sources.list.d/10gen.list

## Add the Auth keys
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10

## Install
sudo apt-get -y update
sudo apt-get -y install mongodb-10gen

exit 0
