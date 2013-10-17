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

###########################################################
# INSTALLATION
###########################################################
## Download
cd /tmp 
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable

## Install
make

## Remove download files
cd ..
rm redis-stable.tar.gz
rm -Rf redis-stable


###########################################################
# CONFIGURATION
###########################################################
NUM=`cat /etc/sysctl.conf | grep 'vm.overcommit_memory.*=*.1' | wc -l`

if [ "$NUM" = "0" ];
then
  echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
  sysctl vm.overcommit_memory=1
fi  


sudo service redis-server restart


exit 0
