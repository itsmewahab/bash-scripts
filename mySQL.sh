#!/bin/bash
sudo apt-get install -y python-software-properties
echo "\n" | sudo -S add-apt-repository ppa:ondrej/php5
sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get -y install mysql-client mysql-server libapache2-mod-auth-mysql libsasl2-2 sasl2-bin libsasl2-2 libsasl2-dev libsasl2-modules

