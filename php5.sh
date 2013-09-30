#!/bin/bash
sudo -i

#############################################################################
# BASE PHP
#############################################################################

#############################################################################
# PHP LIBRARIES
#############################################################################


#############################################################################
# SENDMAIL
#----------------------------------------------------------------------------
# In order to not show the X-PHP-Originating-Script header
#############################################################################

if [ -f /etc/init.d/sendmail ];
then
  if [ -f /etc/php5/cgi/php.ini ];
  then
    echo "mail.add_x_header = Off" >> /etc/php5/cgi/php.ini 
  fi
  
  if [ -f /etc/php5/cli/php.ini ];
  then
    echo "mail.add_x_header = Off" >> /etc/php5/cli/php.ini
  fi
  
  if [ -f /etc/php5/apache2/php.ini ];
  then
    echo "mail.add_x_header = Off" >> /etc/php5/apache2/php.ini
  fi    
fi

#############################################################################
## RESTART THE WEB SERVERS
#############################################################################

if [ -f /etc/init.d/apache2 ];
then
  sudo service apache2 restart
fi

if [ -f /etc/init.d/apache2 ];
then
  sudo service nginx restart
fi
