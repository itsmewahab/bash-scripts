#!/bin/bash

sudo -i
sudo apt-get install -y apache2 apache2-dev libapache2-mod-geoip

#############################################################################
# ENABLE THE BASIC APACHE MODULES
#############################################################################
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod expires

#############################################################################
# BETTER PERFORMANT APACHE2
#############################################################################

echo '
# ----------------------------------------------------------------------
# UTF-8
# ----------------------------------------------------------------------
AddDefaultCharset utf-8
AddCharset utf-8 .css .js

# ----------------------------------------------------------------------
# Gzip data
# ----------------------------------------------------------------------
AddOutputFilterByType DEFLATE text/plain text/html text/javascript text/css application/json$

# ----------------------------------------------------------------------
# Remove Image ETags
# ----------------------------------------------------------------------
<IfModule mod_headers.c>
	Header unset ETag
</IfModule>
FileETag None

# ----------------------------------------------------------------------
# Expires Headers
# ----------------------------------------------------------------------
<IfModule mod_expires.c>
	ExpiresActive on

	# Perhaps better to whitelist expires rules? Perhaps.
	  ExpiresDefault                          "access plus 1 month"

	# cache.appcache needs re-requests in FF 3.6 (thanks Remy ~Introducing HTML5)
	  ExpiresByType text/cache-manifest       "access plus 0 seconds"

	# Your document html
	  ExpiresByType text/html                 "access plus 0 seconds"

	# Data
	  ExpiresByType text/xml                  "access plus 0 seconds"
	  ExpiresByType application/xml           "access plus 0 seconds"
	  ExpiresByType application/json          "access plus 0 seconds"

	# Feed
	  ExpiresByType application/rss+xml       "access plus 1 hour"
	  ExpiresByType application/atom+xml      "access plus 1 hour"

	# Webfonts
	  ExpiresByType application/x-font-ttf    "access plus 2 year"
	  ExpiresByType font/opentype             "access plus 2 year"
	  ExpiresByType application/x-font-woff   "access plus 2 year"
	  ExpiresByType image/svg+xml             "access plus 2 year"
	  ExpiresByType application/vnd.ms-fontobject "access plus 2 year"

	<FilesMatch "\.(ico|txt|js|css|txt|jpe?g|png|gif|bmp|flv|mov|avi|mp4|mp3)$">
		ExpiresActive on
		ExpiresDefault "access plus 2 years"
	</FilesMatch>
</IfModule>
' >> /etc/apache2/apache2.conf 


#############################################################################
# SECURING APACHE2
#############################################################################
echo "ServerSignature Off"  >> /etc/apache2/apache2.conf 
echo "ServerTokens Prod"    >> /etc/apache2/apache2.conf

#############################################################################
# STOP THE WARNING FOR LOCALHOST
#############################################################################
NUM=`cat /etc/hosts | grep '127.0.0.1*.localhost' | wc -l`

if [ "$NUM" -lt "0" ];
then
  echo "127.0.0.1 localhost" >> /etc/hosts 
fi  

## Restart apache2
sudo service apache2 restart
