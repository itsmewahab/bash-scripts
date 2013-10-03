#!/bin/bash

###########################################################
# INSTALLATION
###########################################################

## Add the repo for mongoDB
sudo echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" >> /etc/apt/sources.list.d/10gen.list

## Add the Auth keys
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10

## Install
sudo apt-get -y update
sudo apt-get -y install mongodb-10gen
