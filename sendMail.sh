#!/bin/bash

if [ "$UID" -ne "0" ]
then
  echo "" 
  echo "You must be sudoer or root. To run this script enter:"
  echo ""
  echo "sudo chmod +x $0; sudo ./$0"
  echo ""
  exit 1
fi

sudo apt-get install -y build-essential libpcre3 libpcre3-dev

## Installation
sudo apt-get install -y opendkim opendkim-tools sendmail openssl mimedefang

## In order to not show the X-Authentication-Warning header
echo "FEATURE('use_ct_file')"                             >> /etc/mail/submit.mc
echo "define('_USE_CT_FILE_','1')dnl"                     >> /etc/mail/submit.mc
echo "define('confCT_FILE','/etc/mail/trusted-users')dnl" >> /etc/mail/submit.mc
echo 'www-data' >> /etc/mail/trusted-users

##Set max attachment size
echo 'O MaxMessageSize=0' >> /etc/mail/sendmail.cf


## Restart
sudo service sendmail restart

## Inform the user.
echo 'Sendmail was installed.'
echo ''
echo 'To add trusted users to sendmail, edit the /etc/mail/trusted-users file'
echo ''

exit 0
