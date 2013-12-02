#!/bin/bash

## http://blog.simplytestable.com/installing-the-w3c-html-validator-with-html5-support-on-ubuntu/
sudo -i 
sudo apt-get -y install w3c-markup-validator
sed -i 's/Allow Private IPs = no/Allow Private IPs = yes/g' /etc/w3c/validator.conf
