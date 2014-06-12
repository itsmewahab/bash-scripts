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

########################################################################
# INSTALLATION, includes libstemmer because it's the edge repo :D
########################################################################

echo 'Installing DAILY build of SphinxSearch...'

VERSION_NAME=`cat /etc/lsb-release | grep CODENAME | awk -F '=' '{print $2}'`

if [ $(cat /etc/apt/sources.list | grep "deb http://ppa.launchpad.net/builds/sphinxsearch" | wc -w) = "0" ];
then
  echo "deb http://ppa.launchpad.net/builds/sphinxsearch-daily/ubuntu $VERSION_NAME main" >> /etc/apt/sources.list
fi

if [ $(cat /etc/apt/sources.list | grep "deb-src http://ppa.launchpad.net/builds/sphinxsearch" | wc -w) = "0" ];
then
  echo "deb-src http://ppa.launchpad.net/builds/sphinxsearch-daily/ubuntu $VERSION_NAME main" >> /etc/apt/sources.list
fi  

sudo apt-get update
sudo apt-get install sphinxsearch mysql-client mysql-server

#####################################################################
# CONFIGURATION 
# @todo: load up a SQL basic example and test stemmer
#####################################################################

