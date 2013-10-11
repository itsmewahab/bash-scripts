#!/bin/bash

sudo apt-get install -y python-software-properties
echo "\n" | sudo -S add-apt-repository ppa:ondrej/php5
sudo apt-get update
sudo apt-get upgrade
