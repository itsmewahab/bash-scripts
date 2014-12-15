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


## Check for java dependencies first and install if missing
if [ -z $(which java) ];
then
	sudo apt-get install -y default-jre
fi

## URL of the download page and pattern of the file to download
## Get the path of the latest elastic search file from the official site
DEB_FILE=$(curl -s http://www.elasticsearch.org/download/ | sed 's/\<?*href="\(.*\)".*/\1/g' | grep -E -i -how -m 1 '(https://download.elasticsearch.org(.*)elasticsearch(.*).deb)' |  awk -F ':' '{print $2}')
DEB_FILENAME='elasticsearch.deb'

##Download and install.
if [ ! -z $DEB_FILE ];
then
	curl "https:$DEB_FILE" > "$DEB_FILENAME"

	sudo dpkg -i "$DEB_FILENAME"

	if [ $? == "0" ];
	then
		sudo update-rc.d elasticsearch defaults 95 10
		sudo /etc/init.d/elasticsearch start
		exit 0
	else
		echo 'Elastic search could not be installed'
		exit 1
	fi 

else
	echo 'Could not find the Elastic Search DEB file to download.'
fi
