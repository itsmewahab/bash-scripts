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
sudo apt-get -y install default-jre

## Latest php5 version
sudo apt-get install -y build-essential python-software-properties
echo "\n" | sudo -S add-apt-repository ppa:ondrej/php5
sudo apt-get -y update
sudo apt-get -y upgrade

## Git and git config
sudo apt-get install -y git-core
git config --system color.ui "auto"
git config --system color.branch "auto"
git config --system color.diff "auto"
git config --system color.interactive "auto"
git config --system color.status "auto"
git config --system alias.st "status"
git config --system alias.br "branch"
git config --system alias.co "checkout"
git config --system alias.df "diff"
git config --system alias.lg "log -p"

exit 0
