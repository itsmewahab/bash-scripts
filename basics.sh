#!/bin/bash

sudo apt-get install -y build-essential python-software-properties
echo "\n" | sudo -S add-apt-repository ppa:ondrej/php5

sudo apt-get -y update
sudo apt-get -y upgrade
