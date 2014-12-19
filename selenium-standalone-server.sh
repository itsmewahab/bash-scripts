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


JAR_FILE=$(curl -s http://docs.seleniumhq.org/download/ | sed 's/\<?*href="\(.*\)".*/\1/g' | grep -E -i -how -m 1 '(http://selenium-release.storage.googleapis.com/(.*)/selenium-server-standalone-(.*).jar)' |  awk -F ':' '{print $2}')
JAR_FILENAME='selenium-server-standalone.jar'


##Download and install.
if [ ! -z $JAR_FILE ];
then
	curl "https:$JAR_FILE" > "$JAR_FILENAME"

	echo 'Success! selenium-server-standalone has been downloaded.'
	echo 'You now may run:'
	echo ''
	echo "java -jar $JAR_FILENAME"
	echo ''
	echo '..and your server will be running'
	exit 0

else
	echo 'Could not download selenium-server-standalone.'
	exit 1
fi
