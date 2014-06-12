#!/bin/bash

echo 'Installing DAILY build of SphinxSearch'

#####################################################################
# Install SphinxSearch
#####################################################################

##Add to launchpad
VERSION_NAME=`cat /etc/lsb-release | grep CODENAME | awk -F '=' '{print $2}'`

if [ $(cat /etc/apt/sources.list | grep "deb http://ppa.launchpad.net/builds/sphinxsearch" | wc -w) = "0" ];
then
  echo "deb http://ppa.launchpad.net/builds/sphinxsearch-daily/ubuntu $VERSION_NAME main" >> /etc/apt/sources.list
fi

if [ $(cat /etc/apt/sources.list | grep "deb-src http://ppa.launchpad.net/builds/sphinxsearch" | wc -w) = "0" ];
then
  echo "deb-src http://ppa.launchpad.net/builds/sphinxsearch-daily/ubuntu $VERSION_NAME main" >> /etc/apt/sources.list
fi  

# Install
sudo apt-get update
sudo apt-get install sphinxsearch

#####################################################################
# Install the LIBSTEMMER for better search results
#####################################################################

cd /etc/sphinx
wget http://snowball.tartarus.org/dist/libstemmer_c.tgz
tar xvf libstemmer_c.tgz
./configure --with-libstemmer
make
make install
