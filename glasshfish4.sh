#!bin/bash

sudo -i apt-get update
sudo -i apt-get install oracle-java7-installer unzip

wget download.java.net/glassfish/4.0/release/glassfish-4.0.zip
sudo unzip glassfish-4.0.zip -d /opt
sudo chmod -Rf 755 /opt/glassfish4/glassfish/domains/
echo 'export PATH=/opt/glassfish4/bin:$PATH' >> ~/.profile
echo 'alias asadmin='/opt/glassfish4/bin/asadmin' >> ~/.bash_aliases

echo 'Start webserver using: asadmin start-domain'
