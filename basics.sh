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

sudo apt-get -y update
sudo apt-get -y upgrade

## Install Java. Always comes in handy
sudo apt-get -y install default-jre default-jdk icedtea-7-plugin

## Latest php5 version
sudo apt-get install -y build-essential python-software-properties
echo "\n" | sudo -S add-apt-repository ppa:ondrej/php5
sudo apt-get -y update
sudo apt-get -y upgrade

## Git and git config
sudo apt-get install -y git-core
git config --global color.ui "auto"
git config --global color.branch "auto"
git config --global color.diff "auto"
git config --global color.interactive "auto"
git config --global color.status "auto"
git config --global alias.st "status"
git config --global alias.br "branch"
git config --global alias.co "checkout"
git config --global alias.df "diff"
git config --global alias.lg "log -p"
git config --global branch.autosetuprebase always

exit 0
