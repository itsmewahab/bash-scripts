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

sudo apt-get update
sudo apt-get install -y unzip vim git-core curl wget build-essential python-software-properties

#############################################################################
### Generate all the locales to support i18n in PHP5
#############################################################################
sudo cp /usr/share/i18n/SUPPORTED /var/lib/locales/supported.d/local
sudo locale-gen

#############################################################################
# FACEBOOK'S HHVM
#############################################################################
wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
echo deb http://dl.hhvm.com/ubuntu precise main | sudo tee /etc/apt/sources.list.d/hhvm.list

sudo apt-get -y update
sudo apt-get install -y --force-yes nginx hhvm hhvm-fastcgi


## For production servers, you’ll almost certainly want to enable JIT (Just in Time) 
## compilation to progressively turn the bytecode contained in hhvm.hhbc.sq3 into native code. 
## Depending on exactly what your code base is doing, this will result in performance 
## improvements of anywhere from 50% to 300% (100% seems to be a fairly common average).
if [ $(cat /etc/hhvm/server.hdf| grep "Jit = true" | wc -l) = "0" ];
then
   echo -e "Eval {\n   Jit = true\n}" >> /etc/hhvm/server.hdf   
fi

## Stop hhvm and start hhvm-fastcgi
sudo service hhvm stop
sudo service hhvm-fastcgi start

#############################################################################
## Replace Nginx with my optimized config.
#############################################################################
wget -O - https://github.com/nilopc/bashInstallers/blob/master/nginx.sh | bash

#############################################################################
# Alias HHVM as PHP
#############################################################################
sudo ln -s `which hhvm` /usr/bin/php
sudo ln -s `which hhvm` /usr/bin/php-cli

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
cd
sudo curl -s http://getcomposer.org/installer | php
sudo mv composer.phar /usr/bin/composer
sudo chmod a+x /usr/bin/composer

#############################################################################
# php-cs-fixer
#############################################################################
sudo curl http://cs.sensiolabs.org/get/php-cs-fixer.phar -o /usr/bin/php-cs-fixer
sudo chmod a+x /usr/bin/php-cs-fixer

#############################################################################
# phpmd
#############################################################################
pear channel-discover pear.phpmd.org
pear channel-discover pear.pdepend.org
pear install --alldeps phpmd/PHP_PMD

#############################################################################
# phpcs
#############################################################################
pear install --alldeps PHP_CodeSniffer

