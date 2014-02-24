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

VAR=$(cat <<'END_HEREDOC'

PidFile = /var/run/hhvm/pid

Server {
  Port = 80
  SourceRoot = /var/www/example.com
  DefaultDocument = index.php
}

Log {
  Level = Warning
  AlwaysLogUnhandledExceptions = true
  RuntimeErrorReportingLevel = 8191
  UseLogFile = true
  UseSyslog = false
  File = /var/log/hhvm/error.log
  InjectedStackTrace = true
  NativeStackTrace = true
  Access {
    * {
      File = /var/log/hhvm/access.log
      Format = %h %l %u % t \"%r\" %>s %b
    }
  }
}

Debug {
 FullBacktrace = true
 ServerStackTrace = true
 ServerErrorMessage = true
 TranslateSource = true
}

Repo {
  Central {
    Path = /var/log/hhvm/.hhvm.hhbc
  }
}

MySQL {
  TypedResults = false
}

Eval {
   Jit = true
}

END_HEREDOC
)


echo "$VAR" > /etc/hhvm/server.hdf   


## Stop hhvm and start hhvm-fastcgi
sudo service hhvm stop
sudo service hhvm-fastcgi start

#############################################################################
## Cronjob to make sure hhvm-fastcgi never stops running.
#############################################################################
echo '* * * * * if [ $(ps aux | grep hhvm | wc -l) -lt 2 ]; then service hhvm-fastcgi start; fi' >> /var/spool/cron/crontabs/root 

#############################################################################
## Replace Nginx with my optimized config.
#############################################################################
wget -O - https://github.com/nilopc/bashInstallers/blob/master/nginx.sh | bash

VAR=$(cat <<'END_HEREDOC'

###############################################################################
# REDIRECT www.example.com to example.com
###############################################################################
server {
  server_name www.example.com;
  rewrite ^ http://example.com$request_uri? permanent;
}

###############################################################################
# example.com
###############################################################################
server {
  listen   80;
  server_name example.com;

  ## Logging
  access_log	/var/log/nginx/example.com.access.log main;
  error_log	/var/log/nginx/example.com.error.log;

  ## Set Document Root
  root /var/www/example.com/;

  ## Set Directory Index
  index index.php index.html index.htm;

  ## PHP: Redirect all request to index.php
  location / 
  {
    try_files $uri $uri/ /index.php$is_args$args;
    include /etc/nginx/helpers/extra.conf;
  }

  ## PHP: Pass all PHP request to HHVM
  location ~ \.php$ {
    fastcgi_keep_conn on;
    fastcgi_pass   127.0.0.1:9000;
    fastcgi_index  index.php;
    fastcgi_param  SCRIPT_FILENAME /var/www/example.com$fastcgi_script_name;
    include        fastcgi_params;
  }

  ## Remove the X-Powered-By HHVVM header. 
  fastcgi_hide_header X-Powered-By;
}

END_HEREDOC
)

echo "$VAR" > /etc/nginx/sites-available/example.com
service nginx restart

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

