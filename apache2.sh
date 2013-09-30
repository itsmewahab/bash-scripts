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
a2dismod mpm_*
a2enmod mpm_prefork 

echo "
<IfModule mpm_prefork_module>
    StartServers          5
    MinSpareServers       5
    MaxSpareServers      10
    MaxClients          150
    MaxRequestsPerChild   0
</IfModule>
" >> /etc/apache2/apache2.conf

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
