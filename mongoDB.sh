#!/bin/bash

sudo -i 

###########################################################
# INSTALLATION
###########################################################

## Add the repo for mongoDB
echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" >> /etc/apt/sources.list.d/10gen.list

## Add the Auth keys
apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10

## Install
apt-get -y update
apt-get -y install mongodb-10gen
