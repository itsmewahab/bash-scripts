#!/bin/bash 

sudo ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
sudo apt-get install -y ntp
sudo service ntp restart
