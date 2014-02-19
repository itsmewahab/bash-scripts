#!/bin/bash

############################################################################
#
# Author: Nil Portugués Calderó <contact@nilportugues.com>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
############################################################################
 
apt-get install -y aria2

## ADD THE REPO
UBUNTU_NAME=`grep DISTRIB_CODENAME /etc/lsb-release  | awk -F "=" {'print $2'}`

echo "deb http://ppa.launchpad.net/apt-fast/stable/ubuntu $UBUNTU_NAME main" 		>> /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/apt-fast/stable/ubuntu $UBUNTU_NAME main" 	>> /etc/apt/sources.list

## INSTALL 
apt-get update
apt-get install -y apt-fast --force-yes
