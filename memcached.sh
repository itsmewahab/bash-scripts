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

sudo apt-get install -y python-software-properties
echo "\n" | sudo -S add-apt-repository ppa:ondrej/php5
sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get -y install memcached libmemcache-dev libmemcached-dev zlib1g-dev libssl-dev
