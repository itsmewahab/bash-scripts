#!/bin/bash

############################################################################
#
# Author: Nil Portugués Calderó <contact@nilportugues.com>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
############################################################################

if [ "$UID" -ne "0" ]
then
  echo "" 
  echo "You must be sudoer or root. To run this script enter:"
  echo ""
  echo "sudo chmod +x $0; sudo ./$0"
  echo ""
  exit 1
fi

sudo apt-get install -y python-software-properties
echo "\n" | sudo -S add-apt-repository ppa:ondrej/php5
sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get -y install memcached libmemcache-dev libmemcached-dev zlib1g-dev libssl-dev

##--------------------------------------------------------------------------
## CONFIGURE THE MEMORY USED BY MEMCACHED
##--------------------------------------------------------------------------
echo '' >  /etc/default/memcached 
echo 'ENABLE_MEMCACHED=yes' >> /etc/default/memcached 
echo 'PORT="11211"' >> /etc/default/memcached 
echo 'USER="memcached"' >> /etc/default/memcached 
echo 'MAXCONN="1024"' >> /etc/default/memcached 
echo 'CACHESIZE="512"' >> /etc/default/memcached 
echo '## make sure we accept connection from external machines on our IP, eg: 192.168.1.12:11211' >> /etc/default/memcached 
echo '##OPTIONS="-l 192.168.1.12 -L"' >> /etc/default/memcached 

sudo service memcached restart 

##--------------------------------------------------------------------------
## CONFIGURE THE MAXIMUM PORTS A LOCAL SERVICE CAN USE.
##--------------------------------------------------------------------------
if [ $(cat /etc/sysctl.conf | grep 'fs.file-max = 50000' | wc -l) = "0" ];
then
  echo '# Increase system file descriptor limit to' >> /etc/sysctl.conf
  echo 'fs.file-max = 50000' >> /etc/sysctl.conf
fi


if [ $(cat /etc/sysctl.conf | grep 'net.ipv4.ip_local_port_range = 2000 65000' | wc -l) = "0" ];
then
  echo '# Increase system IP port limits' >> /etc/sysctl.conf
  echo 'net.ipv4.ip_local_port_range = 2000 65000' >> /etc/sysctl.conf
fi

sudo sysctl -p
