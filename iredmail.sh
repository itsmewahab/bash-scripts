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

URL=$(echo $(curl -s http://www.iredmail.org/download.html | sed 's/\<?*href="\(.*\)".*/\1/g' | grep -E -i -how -m 1 '(https://bitbucket.org/zhb/iredmail(.*)iRedMail-(.*).tar.bz2)') | awk -F '"' '{print $1}')

if [ ! -z $URL ];
then
	cd /tmp
	wget $URL
	tar -xvf $(basename $URL)
	folder=$(basename $URL)
	folder="${folder//.tar.bz2}"
	cd $folder
	bash iRedMail.sh 
	exit 0
else
	echo 'Error: Could not download and install iRedMail automatically.'
	echo ''
	echo 'Install it manually by following the instructions at:'
	echo 'http://www.iredmail.org/install_iredmail_on_ubuntu.html'
	echo ''
	exit 1
fi
