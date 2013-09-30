#!/bin/bash

sudo -i
sudo apt-get install -y apache2 apache2-dev libapache2-mod-geoip

#############################################################################
# ENABLE THE BASIC APACHE MODULES
#############################################################################
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod expires

#############################################################################
# ENABLE PREFORK MODULE
#############################################################################
sudo a2dismod mpm_*
sudo a2enmod mpm_prefork 

NUM=`cat /etc/apache2/apache2.conf | grep mpm_prefork_module`
if [ "$NUM" = "0" ];
then
echo "
<IfModule mpm_prefork_module>
    StartServers        5
    MinSpareServers     5
    MaxSpareServers     10
    MaxClients          150
    ServerLimit	        256
    MaxRequestsPerChild 100
</IfModule>

KeepAlive Off
" >> /etc/apache2/apache2.conf
fi

#############################################################################
# SECURING APACHE2
#############################################################################
echo "ServerSignature Off"  >> /etc/apache2/apache2.conf 
echo "ServerTokens Prod"    >> /etc/apache2/apache2.conf

#############################################################################
# STOP THE WARNING FOR LOCALHOST
#############################################################################
NUM=`cat /etc/hosts | grep '127.0.0.1*.localhost' | wc -l`

if [ "$NUM" -lt "0" ];
then
  echo "127.0.0.1 localhost" >> /etc/hosts 
fi  

## Restart apache2
sudo service apache2 restart
