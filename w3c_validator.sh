#!/bin/bash

############################################################################
#
# Author: Nil Portugués Calderó <contact@nilportugues.com>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
############################################################################

## http://blog.simplytestable.com/installing-the-w3c-html-validator-with-html5-support-on-ubuntu/

sudo apt-get -y install w3c-markup-validator
sudo sed -i 's/Allow Private IPs = no/Allow Private IPs = yes/g' /etc/w3c/validator.conf
