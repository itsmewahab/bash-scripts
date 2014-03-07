#!/bin/bash

############################################################################
#
# Author: Nil Portugués Calderó <contact@nilportugues.com>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
############################################################################
 
START_CWD=`pwd`
ANSWER=""
WILDCARD=""

#################################################################################
#	Install Apache if necessary and creates SSL to save certificates.
#################################################################################
apache2SSL()
{
	AVAILABLE=`command -v apache2`
	if [ -z $AVAILABLE ];
	then
		echo '-------------------------------------------------------------------------------'
		echo 'Installing Apache 2... '
		echo '-------------------------------------------------------------------------------'	
		sudo apt-get -y install apache2
	fi

	echo '-------------------------------------------------------------------------------'	
	echo 'Enabling Apache 2 SSL mod... '
	echo '-------------------------------------------------------------------------------'
	a2enmod ssl

	echo '-------------------------------------------------------------------------------'	
	echo 'Creating SSL directory in Apache 2'
	echo '-------------------------------------------------------------------------------'	

	mkdir /etc/apache2/ssl
	cd /etc/apache2/ssl
}
#################################################################################
#	Apache2 Virtual Host
#################################################################################
apache2SSLVirtualHost()
{
cat << EOF > "$START_CWD/$BASE_DOMAIN.conf"

<VirtualHost *:80>
        ServerAlias $BASE_DOMAIN
        RewriteEngine On
        RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [QSA,R=301,L]
</VirtualHost>

<IfModule mod_ssl.c>
	<VirtualHost *:443>
	        ServerAlias $BASE_DOMAIN     
	        DocumentRoot /var/www/$BASE_DOMAIN

	        SSLEngine on
	        SSLOptions +FakeBasicAuth +ExportCertData +StrictRequire
	        SSLCACertificateFile    /etc/apache2/ssl/$BASE_DOMAIN.ca.crt
	        SSLCertificateFile      /etc/apache2/ssl/$BASE_DOMAIN.chained.crt
	        SSLCertificateKeyFile   /etc/apache2/ssl/$BASE_DOMAIN.key

	       <FilesMatch "\.(cgi|shtml|phtml|php)$">
	          SSLOptions +StdEnvVars
	       </FilesMatch>
	 </VirtualHost>
 </IfModule>

EOF

}

#################################################################################
#	Install nginx if necessary and creates SSL to save certificates.
#################################################################################
nginxSSL()
{
	AVAILABLE=`command -v nginx`
	if [ -z $AVAILABLE ];
	then
		echo '-------------------------------------------------------------------------------'
		echo 'Installing nginx... '
		echo '-------------------------------------------------------------------------------'	
		sudo apt-get -y install nginx
	fi

	echo '-------------------------------------------------------------------------------'	
	echo 'Creating SSL directory in nginx'
	echo '-------------------------------------------------------------------------------'	

	mkdir /etc/nginx/ssl
	cd /etc/nginx/ssl	
}
#################################################################################
#	Nginx Virtual Host
#################################################################################
nginxSSLVirtualHost()
{
	
	if [ "$WILDCARD" = "0" ];
	then
	
cat << EOF > "$START_CWD/$BASE_DOMAIN.conf"
############################################################################
##	REDIRECT TO HTTPS
############################################################################
server {
    listen 80;
    server_name www.$BASE_DOMAIN $BASE_DOMAIN;
    rewrite ^ https://$BASE_DOMAIN\$request_uri? permanent;
}
############################################################################
##	$BASE_DOMAIN REDIRECTS
############################################################################
server {
    listen 443;
    server_name www.$BASE_DOMAIN;
    
    ssl on;
    ssl_client_certificate  /etc/nginx/ssl/$BASE_DOMAIN.ca.crt;
    ssl_certificate         /etc/nginx/ssl/$BASE_DOMAIN.chained.crt;
    ssl_certificate_key     /etc/nginx/ssl/$BASE_DOMAIN.key;

    rewrite ^ https://$BASE_DOMAIN\$request_uri? permanent;
}

############################################################################
##	$BASE_DOMAIN
############################################################################
server {
	listen 443;
	server_name $BASE_DOMAIN;

	root /var/www/$BASE_DOMAIN;

	location / {
		try_files  \$uri  \$uri/  /index.php?\$args;
		index index.html index.htm index.php;
	}
	
	ssl on;
	ssl_client_certificate  /etc/nginx/ssl/$BASE_DOMAIN.ca.crt
	ssl_certificate         /etc/nginx/ssl/$DOMAIN_NAME.chained.crt;
	ssl_certificate_key     /etc/nginx/ssl/$DOMAIN_NAME.key; 
}
EOF
	else

cat << EOF > "$START_CWD/$BASE_DOMAIN.conf"
############################################################################
##	REDIRECT TO HTTPS
############################################################################
server {
    listen 80;
    server_name www.$BASE_DOMAIN $BASE_DOMAIN;
    rewrite ^ https://$BASE_DOMAIN\$request_uri? permanent;
}
server {
    listen 80;
    server_name  ~^www.(?<subdomain>.+)\.$BASE_DOMAIN$ ~^(?<subdomain>.+)\.$BASE_DOMAIN$;
    rewrite ^ https://\$subdomain.$BASE_DOMAIN\$request_uri? permanent;
}
############################################################################
##	$BASE_DOMAIN REDIRECTS
############################################################################
server {
    listen 443;
    server_name www.$BASE_DOMAIN;
    
    ssl on;
    ssl_client_certificate  /etc/nginx/ssl/$BASE_DOMAIN.ca.crt;
    ssl_certificate         /etc/nginx/ssl/$BASE_DOMAIN.chained.crt;
    ssl_certificate_key     /etc/nginx/ssl/$BASE_DOMAIN.key;

    rewrite ^ https://$BASE_DOMAIN\$request_uri? permanent;
}
############################################################################
##  REDIRECT: WWW.$SUBDOMAIN.$BASE_DOMAIN:443
############################################################################
server {
    listen 443;
    server_name  ~^www.(?<subdomain>.+)\.$BASE_DOMAIN$;

    ssl on;
    ssl_client_certificate  /etc/nginx/ssl/$BASE_DOMAIN.ca.crt;
    ssl_certificate         /etc/nginx/ssl/$BASE_DOMAIN.chained.crt;
    ssl_certificate_key     /etc/nginx/ssl/$BASE_DOMAIN.key; 

    rewrite ^ https://\$subdomain.$BASE_DOMAIN\$request_uri? permanent;
}
############################################################################
##	$BASE_DOMAIN
############################################################################
server {
	listen 443;
	server_name $BASE_DOMAIN;
	root /var/www/$BASE_DOMAIN;

	location / {
		try_files  \$uri  \$uri/  /index.php?\$args;
		index index.html index.htm index.php;
	}
	
	ssl on;
	ssl_client_certificate  /etc/nginx/ssl/$BASE_DOMAIN.ca.crt
	ssl_certificate         /etc/nginx/ssl/$DOMAIN_NAME.chained.crt;
	ssl_certificate_key     /etc/nginx/ssl/$DOMAIN_NAME.key; 
}
EOF
	fi


}

#################################################################################
#	QUESTIONS
#################################################################################
##--------------------------------------------------------------------------------
## QUESTION 1: IS IT WILDCARD SSL?
##--------------------------------------------------------------------------------
question1()
{
	VALID=1
	while [ $VALID -eq 1 ]; 
	do
		read -n 1 ANSWER
		ANSWER=`echo $ANSWER | awk '{print tolower($0)}'`

		case $ANSWER in
		y|yes) 
			DOMAIN_NAME="*.$DOMAIN_NAME"
			VALID=0
			WILDCARD=1
			;;
		n|no)
			DOMAIN_NAME="$DOMAIN_NAME"
			VALID=0
			WILDCARD=0
			;;
		*)
			echo "Please, YES or NO [y|n]?"
			;;
		esac	
	done
}

##--------------------------------------------------------------------------------
## QUESTION 2: IS IT APACHE OR NGINX?
##--------------------------------------------------------------------------------
question2()
{
	VALID=1
	while [ $VALID -eq 1 ]; 
	do
		read ANSWER
		ANSWER=`echo $ANSWER | awk '{print tolower($0)}'`

		case $ANSWER in
			apache) 
				apache2SSL
				VALID=0
				;;
			nginx)
				nginxSSL 	
				VALID=0
				;;
			*)
				echo "Please, Apache2 or Nginx [apache|nginx]?" 
				;;
		esac	
	done
		
	/usr/bin/openssl req -new -newkey rsa:2048 -nodes -keyout $BASE_DOMAIN.key -out $BASE_DOMAIN.srv.crt

	echo ""
	echo "-------------------------------------------------------------------------------"	
	echo "SSL Certificate for $DOMAIN_NAME"
	echo "Copy and paste to the certification entity page to generate the Valid SSL Cert."
	echo "-------------------------------------------------------------------------------"
	echo ""
	cat $BASE_DOMAIN.srv.crt

	echo "" > $BASE_DOMAIN.chained.crt
	echo "-- YOUR UNIQUE VALID SSL CERTIFICATE given by the certification entity --" > $BASE_DOMAIN.chained.crt
	echo "-- The certification entity **ROOT CA** (NOT INTERMEDIATE) code --" >> $BASE_DOMAIN.chained.crt

	echo "" > $BASE_DOMAIN.ca.crt
	echo "-- The certification entity **INTERMEDIATE ROOT CA** --"  > $BASE_DOMAIN.ca.crt
	
	echo ""
	echo "-------------------------------------------------------------------------------"	
	echo "SSL Certificate placeholders, ready."
	echo "-------------------------------------------------------------------------------"	

	cd $START_CWD

	if [ "$ANSWER" == "apache" ];
	then	 
		apache2SSLVirtualHost
		echo ""
		echo "Now, all you need is to fill in the data for the files in /etc/apache2/ssl/ with the given data from the official certification entity."	
		echo ""
		echo "Move the generated file: $START_CWD/$BASE_DOMAIN.conf to /etc/apache2/sites-available" 
		echo ""
		echo "Now run: a2ensite $BASE_DOMAIN.conf "
		echo ""
		echo "Once appended, remember to restart your web server using: service apache2 restart"
		echo ""
	else	
		nginxSSLVirtualHost
		echo ""
		echo "Now, all you need is to fill in the data for the files in /etc/nginx/ssl/ with the given data from the official certification entity."	
		echo ""
		echo "Move the generated file: $START_CWD/$BASE_DOMAIN.conf to /etc/nginx/sites-available" 
		echo ""
		echo "Now run: ln -s /etc/nginx/sites-available/$BASE_DOMAIN.conf  /etc/nginx/sites-enabled/$BASE_DOMAIN.conf "
		echo ""				
		echo "Once appended, remember to restart your web server using: service nginx restart"
		echo ""
	fi	
	echo "-------------------------------------------------------------------------------"	
	echo "End SSL Script"
	echo "-------------------------------------------------------------------------------"		
}


#################################################################################
#	MAIN SCRIPT
#################################################################################

if [ -z $1 ];
then
	echo ""
	echo "Usage: $0 <example.com>"
	echo ""
	exit 1
fi

DOMAIN_NAME=$1
BASE_DOMAIN=$1

echo ''
echo "Is this certificate meant to be used as WILDCARD (*.$DOMAIN_NAME) certificate? [y|n]"
echo ''
question1

echo ''
echo "Is this certificate being installed for Apache or Nginx? [apache|nginx]"
echo ''
question2


exit 0
