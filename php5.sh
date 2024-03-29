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

#############################################################################
## Use the latest PHP repos :)
#############################################################################
sudo apt-get install -y python-software-properties
echo "\n" | sudo -S add-apt-repository ppa:ondrej/php5
sudo apt-get -y update

#############################################################################
### Generate all the locales to support i18n in PHP5
#############################################################################
sudo cp /usr/share/i18n/SUPPORTED /var/lib/locales/supported.d/local
sudo locale-gen

#############################################################################
# BASE PHP
#############################################################################
sudo apt-get install -y build-essential libpcre3 libpcre3-dev imagemagick php5 php5-dev php5-cli php5-common php5-fpm php5-cgi php-pear php5-apcu php5-mcrypt
	
#############################################################################
# PHP LIBRARIES
#############################################################################
sudo apt-get install -y php5-xmlrpc php5-xdebug php5-tidy php5-sqlite php5-pspell php5-ps php5-pgsql php5-odbc php5-mysql php5-ming php5-mhash php5-memcached php5-memcache php5-mcrypt php5-intl php5-imap php5-imagick php5-geoip php5-gd php5-dev php5-dbg php5-curl

#############################################################################
# PHPUNIT
#----------------------------------------------------------------------------
# Unit testing suite for PHP.
#############################################################################
sudo curl -o /usr/bin/phpunit https://phar.phpunit.de/phpunit.phar
sudo chmod a+x /usr/bin/phpunit

#############################################################################
# composer
#----------------------------------------------------------------------------
# Download dependencies in your PHP projects.
#############################################################################
sudo apt-get install -y git-core curl
sudo echo "suhosin.executor.include.whitelist = phar" >> /etc/php5/cli/conf.d/suhosin.ini
cd
sudo curl -s http://getcomposer.org/installer | php
sudo mv composer.phar /usr/bin/composer
sudo chmod a+x /usr/bin/composer

#############################################################################
# php-cs-fixer
#----------------------------------------------------------------------------
# Fix and force a coding standard on your code.
#############################################################################
sudo curl http://cs.sensiolabs.org/get/php-cs-fixer.phar -o /usr/bin/php-cs-fixer
sudo chmod a+x /usr/bin/php-cs-fixer


#############################################################################
# phpdox
#----------------------------------------------------------------------------
# Documentation generator.
#############################################################################
sudo apt-get install php5-xsl
sudo curl http://phpdox.de/releases/phpdox.phar -o /usr/bin/phpdox
sudo chmod a+x /usr/bin/phpdox

#############################################################################
# phpmd
#----------------------------------------------------------------------------
# PHP Mess detector
#############################################################################
pear channel-discover pear.phpmd.org
pear channel-discover pear.pdepend.org
pear install --alldeps phpmd/PHP_PMD

#############################################################################
# phpcs
#----------------------------------------------------------------------------
# PHP Code Sniffer (style coding standard detector)
#############################################################################
pear install --alldeps PHP_CodeSniffer

#############################################################################
# GEOIP
#----------------------------------------------------------------------------
# Geolocation library for php
#############################################################################
sudo apt-get install -y libgeoip-dev
sudo pecl install geoip

cd /usr/share/GeoIP/
if [ ! -f "GeoLiteCity.dat.gz" ]; 
then 
  wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz; 
fi

if [ ! -f "GeoIP.dat.gz" ];
then 
  wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz; 
fi

if [ ! -f "GeoIPv6.dat.gz" ];
then 
  wget http://geolite.maxmind.com/download/geoip/database/GeoIPv6.dat.gz; 
fi

gunzip -f *.gz


#############################################################################
# MONGO DB FOR PHP
#############################################################################
sudo pecl install mongo
echo "extension=mongo.so" > /etc/php5/mods-available/mongo.ini
ln -s /etc/php5/mods-available/mongo.ini /etc/php5/cli/conf.d/30-mongo.ini
ln -s /etc/php5/mods-available/mongo.ini /etc/php5/cgi/conf.d/30-mongo.ini
ln -s /etc/php5/mods-available/mongo.ini /etc/php5/fpm/conf.d/30-mongo.ini


#############################################################################
# SECURING PHP CONFIGURATION
#############################################################################
if [ -f /etc/php5/cgi/php.ini ];
then
  echo "mail.add_x_header = Off" 		>> /etc/php5/cgi/php.ini
  
  echo "display_errors = Off" 			>> /etc/php5/cgi/php.ini 
  echo "expose_php = Off"     			>> /etc/php5/cgi/php.ini 
  echo "date.timezone = Europe/Madrid"  	>> /etc/php5/cgi/php.ini 

  echo "opcache.interned_strings_buffer=8"  	>> /etc/php5/cgi/php.ini 
  echo "opcache.max_accelerated_files=4000"  	>> /etc/php5/cgi/php.ini 
  echo "opcache.revalidate_freq=60"  		>> /etc/php5/cgi/php.ini 
  echo "opcache.fast_shutdown=1"  		>> /etc/php5/cgi/php.ini 
  echo "opcache.enable_cli=1"  			>> /etc/php5/cgi/php.ini   
fi

if [ -f /etc/php5/cli/php.ini ];
then
  echo "mail.add_x_header = Off" 		>> /etc/php5/cli/php.ini 
	
  echo "display_errors = Off" 			>> /etc/php5/cli/php.ini 
  echo "expose_php = Off"     			>> /etc/php5/cli/php.ini 
  echo "date.timezone = Europe/Madrid"  	>> /etc/php5/cli/php.ini 

  echo "opcache.interned_strings_buffer=8"  	>> /etc/php5/cli/php.ini 
  echo "opcache.max_accelerated_files=4000"  	>> /etc/php5/cli/php.ini 
  echo "opcache.revalidate_freq=60"  		>> /etc/php5/cli/php.ini 
  echo "opcache.fast_shutdown=1"  		>> /etc/php5/cli/php.ini 
  echo "opcache.enable_cli=1"  			>> /etc/php5/cli/php.ini 
fi

if [ -f /etc/php5/apache2/php.ini ];
then
  echo "mail.add_x_header = Off" 		>> /etc/php5/apache2/php.ini 
  
  echo "display_errors = Off" 			>> /etc/php5/apache2/php.ini 
  echo "expose_php = Off"     			>> /etc/php5/apache2/php.ini 
  echo "date.timezone = Europe/Madrid"  	>> /etc/php5/apache2/php.ini   

  echo "opcache.interned_strings_buffer=8"  	>> /etc/php5/apache2/php.ini 
  echo "opcache.max_accelerated_files=4000"  	>> /etc/php5/apache2/php.ini 
  echo "opcache.revalidate_freq=60"  		>> /etc/php5/apache2/php.ini 
  echo "opcache.fast_shutdown=1"  		>> /etc/php5/apache2/php.ini 
  echo "opcache.enable_cli=1"  			>> /etc/php5/apache2/php.ini 
fi

if [ -f /etc/php5/fpm/php.ini ];
then
  echo "mail.add_x_header = Off" 		>> /etc/php5/fpm/php.ini 
  
  echo "display_errors = Off"			>> /etc/php5/fpm/php.ini 
  echo "expose_php = Off"     			>> /etc/php5/fpm/php.ini 
  echo "date.timezone = Europe/Madrid"  	>> /etc/php5/fpm/php.ini 
  
  echo "opcache.interned_strings_buffer=8"  	>> /etc/php5/fpm/php.ini 
  echo "opcache.max_accelerated_files=4000"  	>> /etc/php5/fpm/php.ini 
  echo "opcache.revalidate_freq=60"  		>> /etc/php5/fpm/php.ini 
  echo "opcache.fast_shutdown=1"  		>> /etc/php5/fpm/php.ini 
  echo "opcache.enable_cli=1"  			>> /etc/php5/fpm/php.ini 
  
  echo "opcache.enable_cli=1"  			>> /etc/php5/fpm/php.ini 
  
  service php5-fpm restart 
fi

#############################################################################
## Fix deprecated comments in extensions, if any
#############################################################################
sudo sed -i 's/#/\/\//g' /etc/php5/cli/conf.d/*.ini
sudo sed -i 's/#/\/\//g' /etc/php5/apache2/conf.d/*.ini

#############################################################################
## RESTART THE WEB SERVERS
#############################################################################

if [ -f /etc/init.d/apache2 ];
then
  sudo service apache2 restart
fi

if [ -f /etc/init.d/nginx ];
then
  sudo service nginx restart
fi

exit 0
