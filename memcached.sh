#!/bin/bash
sudo apt-get install -y python-software-properties
echo "\n" | sudo -S add-apt-repository ppa:ondrej/php5
sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get -y install memcached libmemcache-dev libmemcached-dev zlib1g-dev libssl-dev
