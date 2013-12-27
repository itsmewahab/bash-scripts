#!/bin/bash

#############################################################################
## Download Apache Ant
#############################################################################
sudo apt-get -u install ant

#############################################################################
# PHPUNIT
#----------------------------------------------------------------------------
# Unit testing suite for PHP.
#############################################################################
if [ -z $(which phpunit) ];
then
	sudo curl -o /usr/bin/phpunit https://phar.phpunit.de/phpunit.phar
	sudo chmod a+x /usr/bin/phpunit
fi

#############################################################################
# composer
#----------------------------------------------------------------------------
# Download dependencies in your PHP projects.
#############################################################################
if [ -z $(which composer) ];
then
	sudo apt-get install -y git-core curl
	sudo echo "suhosin.executor.include.whitelist = phar" >> /etc/php5/cli/conf.d/suhosin.ini
	cd
	sudo curl -s http://getcomposer.org/installer | php
	sudo mv composer.phar /usr/bin/composer
	sudo chmod a+x /usr/bin/composer
fi

#############################################################################
# php-cs-fixer
#----------------------------------------------------------------------------
# Fix and force a coding standard on your code.
#############################################################################
if [ -z $(which php-cs-fixer) ];
then
	sudo curl http://cs.sensiolabs.org/get/php-cs-fixer.phar -o /usr/bin/php-cs-fixer
	sudo chmod a+x /usr/bin/php-cs-fixer
fi

#############################################################################
# phpdox
#----------------------------------------------------------------------------
# Documentation generator.
#############################################################################
if [ -z $(which phpdox) ];
then
	sudo apt-get install php5-xsl
	sudo curl http://phpdox.de/releases/phpdox.phar -o /usr/bin/phpdox
	sudo chmod a+x /usr/bin/phpdox
fi
#############################################################################
# phpmd
#----------------------------------------------------------------------------
# PHP Mess detector
#############################################################################
if [ -z $(which phpmd) ];
then
	pear channel-discover pear.phpmd.org
	pear channel-discover pear.pdepend.org
	pear install --alldeps phpmd/PHP_PMD
fi

#############################################################################
## Download jenkins-cli
#############################################################################
if [ ! -f jenkins-cli.jar ];
then
	wget http://127.0.0.1:8080/jnlpJars/jenkins-cli.jar
fi

java -jar jenkins-cli.jar -s http://127.0.0.1:8080 login --username admin

#############################################################################
## Install Git support Plugins
#############################################################################
java -jar jenkins-cli.jar -s http://127.0.0.1:8080 install-plugin git git-client github github-api github-oauth bitbucket-oauth git-parameter 

#############################################################################
## Install PHP Plugins
#############################################################################
java -jar jenkins-cli.jar -s http://127.0.0.1:8080 install-plugin checkstyle pmd plot analysis-collector jdepend htmlpublisher dry cloverphp violations xunit
echo $(cat $(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/php-template.xml) | java -jar jenkins-cli.jar -s http://127.0.0.1:8080 create-job php-template

#############################################################################
## Other plugins
#############################################################################
java -jar jenkins-cli.jar -s http://127.0.0.1:8080 install-plugin progress-bar-column-plugin timestamper unicorn ansicolor


## Restart Jenkins
java -jar jenkins-cli.jar -s http://127.0.0.1:8080 safe-restart

rm jenkins-cli.jar
