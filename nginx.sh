#!/bin/bash

sudo apt-get install -y nginx

sudo mkdir -p /etc/nginx/logs/
sudo touch /etc/nginx/logs/error.log

sudo mkdir -p /usr/share/nginx/logs/
sudo touch /usr/share/nginx/logs/error.log

sudo mkdir -p /etc/nginx/helpers/
sudo touch /etc/nginx/helpers/extra.conf



VAR=$(cat <<'END_HEREDOC'

# nginx Configuration File
# http://wiki.nginx.org/Configuration

# Run as a less privileged user for security reasons.
user www-data;

# How many worker threads to run;
# "auto" sets it to the number of CPU cores available in the system, and
# offers the best performance. Don't set it higher than the number of CPU
# cores if changing this parameter.

# The maximum number of connections for Nginx is calculated by:
# max_clients = worker_processes * worker_connections
worker_processes 4;

# Maximum open file descriptors per process;
# should be > worker_connections.
worker_rlimit_nofile 8192;

events 
{
  # When you need > 8000 * cpu_cores connections, you start optimizing your OS,
  # and this is probably the point at which you hire people who are smarter than
  # you, as this is *a lot* of requests.
  worker_connections 8000;
}

# Default error log file
# (this is only used when you don't override error_log on a server{} level)
error_log  logs/error.log warn;
pid        /var/run/nginx.pid;

http {
  
  server_names_hash_bucket_size 64;
  fastcgi_hide_header X-Powered-By;
  proxy_hide_header X-Powered-By;

  # Hide nginx version information.
  server_tokens off;

  # Define the MIME types for files.
  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;

  # Format to use in log files
  log_format main '{ "timestamp": "$time_local", "fields": { "client": "$remote_addr", "duration_sec": "$request_time", "status": "$status", "request": "$request", "method": "$request_method", "referrer": "$http_referer" } }';


  # Default log file
  # (this is only used when you don't override access_log on a server{} level)
  access_log logs/access.log main;

  # How long to allow each connection to stay idle; longer values are better
  # for each individual client, particularly for SSL, but means that worker
  # connections are tied up longer. (Default: 65)
  keepalive_timeout 20;

  # Speed up file transfers by using sendfile() to copy directly
  # between descriptors rather than using read()/write().
  sendfile        on;

  # Tell Nginx not to send out partial frames; this increases throughput
  # since TCP frames are filled up before being sent out. (adds TCP_CORK)
  tcp_nopush      on;

  # Tell Nginx to enable the Nagle buffering algorithm for TCP packets, which
  # collates several smaller packets together into one larger packet, thus saving
  # bandwidth at the cost of a nearly imperceptible increase to latency. (removes TCP_NODELAY)
  tcp_nodelay     off;


  # Compression

  # Enable Gzip compressed.
  gzip on;

  # Enable compression both for HTTP/1.0 and HTTP/1.1 (required for CloudFront).
  gzip_http_version  1.0;

  # Compression level (1-9).
  # 5 is a perfect compromise between size and cpu usage, offering about
  # 75% reduction for most ascii files (almost identical to level 9).
  gzip_comp_level    5;

  # Don't compress anything that's already small and unlikely to shrink much
  # if at all (the default is 20 bytes, which is bad as that usually leads to
  # larger files after gzipping).
  gzip_min_length    256;

  # Compress data even for clients that are connecting to us via proxies,
  # identified by the "Via" header (required for CloudFront).
  gzip_proxied       any;

  # Tell proxies to cache both the gzipped and regular version of a resource
  # whenever the client's Accept-Encoding capabilities header varies;
  # Avoids the issue where a non-gzip capable client (which is extremely rare
  # today) would display gibberish if their proxy gave them the gzipped version.
  gzip_vary          on;

  # Compress all output labeled with one of the following MIME-types.
  gzip_types
    application/atom+xml
    application/javascript
    application/json
    application/rss+xml
    application/vnd.ms-fontobject
    application/x-font-ttf
    application/x-web-app-manifest+json
    application/xhtml+xml
    application/xml
    font/opentype
    image/svg+xml
    image/x-icon
    text/css
    text/plain
    text/x-component;
  # text/html is always compressed by HttpGzipModule


  # This should be turned on if you are going to have pre-compressed copies (.gz) of
  # static files available. If not it should be left off as it will cause extra I/O
  # for the check. It is best if you enable this in a location{} block for
  # a specific directory, or on an individual server{} level.
  # gzip_static on;

  # Protect against the BEAST attack by preferring RC4-SHA when using SSLv3 and TLS protocols.
  # Note that TLSv1.1 and TLSv1.2 are immune to the beast attack but only work with OpenSSL v1.0.1 and higher and has limited client support.
  ssl_protocols              SSLv3 TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers                RC4:HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers  on;

  # Optimize SSL by caching session parameters for 10 minutes. This cuts down on the number of expensive SSL handshakes.
  # The handshake is the most CPU-intensive operation, and by default it is re-negotiated on every new/parallel connection.
  # By enabling a cache (of type "shared between all Nginx workers"), we tell the client to re-use the already negotiated state.
  # Further optimization can be achieved by raising keepalive_timeout, but that shouldn't be done unless you serve primarily HTTPS.
  ssl_session_cache    shared:SSL:10m; # a 1mb cache can hold about 4000 sessions, so we can hold 40000 sessions
  ssl_session_timeout  10m;

  # This default SSL certificate will be served whenever the client lacks support for SNI (Server Name Indication).
  # Make it a symlink to the most important certificate you have, so that users of IE 8 and below on WinXP can see your main site without SSL errors.
  #ssl_certificate      /etc/nginx/default_ssl.crt;
  #ssl_certificate_key  /etc/nginx/default_ssl.key;

  include sites-enabled/*;
  
  # This tells Nginx to cache open file handles, "not found" errors, metadata about files and their permissions, etc.
  #
  # The upside of this is that Nginx can immediately begin sending data when a popular file is requested,
  # and will also know to immediately send a 404 if a file is missing on disk, and so on.
  #
  # However, it also means that the server won't react immediately to changes on disk, which may be undesirable.
  #
  # In the below configuration, inactive files are released from the cache after 20 seconds, whereas
  # active (recently requested) files are re-validated every 30 seconds.
  #
  # Descriptors will not be cached unless they are used at least 2 times within 20 seconds (the inactive time).
  #
  # A maximum of the 1000 most recently used file descriptors can be cached at any time.
  #
  # Production servers with stable file collections will definitely want to enable the cache.
  open_file_cache          max=1000 inactive=20s;
  open_file_cache_valid    30s;
  open_file_cache_min_uses 2;
  open_file_cache_errors   on;  
  
 
}

END_HEREDOC
)

echo "$VAR" > /etc/nginx/nginx.conf 








VAR=$(cat <<'END_HEREDOC'
types {

# Audio
  audio/midi                            mid midi kar;
  audio/mp4                             aac f4a f4b m4a;
  audio/mpeg                            mp3;
  audio/ogg                             oga ogg;
  audio/x-realaudio                     ra;
  audio/x-wav                           wav;

# Images
  image/bmp                             bmp;
  image/gif                             gif;
  image/jpeg                            jpeg jpg;
  image/png                             png;
  image/tiff                            tif tiff;
  image/vnd.wap.wbmp                    wbmp;
  image/webp                            webp;
  image/x-icon                          ico cur;
  image/x-jng                           jng;

# JavaScript
  application/javascript                js;
  application/json                      json;

# Manifest files
  application/x-web-app-manifest+json   webapp;
  text/cache-manifest                   manifest appcache;

# Microsoft Office
  application/msword                                                         doc;
  application/vnd.ms-excel                                                   xls;
  application/vnd.ms-powerpoint                                              ppt;
  application/vnd.openxmlformats-officedocument.wordprocessingml.document    docx;
  application/vnd.openxmlformats-officedocument.spreadsheetml.sheet          xlsx;
  application/vnd.openxmlformats-officedocument.presentationml.presentation  pptx;

# Video
  video/3gpp                            3gpp 3gp;
  video/mp4                             mp4 m4v f4v f4p;
  video/mpeg                            mpeg mpg;
  video/ogg                             ogv;
  video/quicktime                       mov;
  video/webm                            webm;
  video/x-flv                           flv;
  video/x-mng                           mng;
  video/x-ms-asf                        asx asf;
  video/x-ms-wmv                        wmv;
  video/x-msvideo                       avi;

# Web feeds
  application/xml                       atom rdf rss xml;

# Web fonts
  application/font-woff                 woff;
  application/vnd.ms-fontobject         eot;
  application/x-font-ttf                ttc ttf;
  font/opentype                         otf;
  image/svg+xml                         svg svgz;

# Other
  application/java-archive              jar war ear;
  application/mac-binhex40              hqx;
  application/pdf                       pdf;
  application/postscript                ps eps ai;
  application/rtf                       rtf;
  application/vnd.wap.wmlc              wmlc;
  application/xhtml+xml                 xhtml;
  application/vnd.google-earth.kml+xml  kml;
  application/vnd.google-earth.kmz      kmz;
  application/x-7z-compressed           7z;
  application/x-chrome-extension        crx;
  application/x-opera-extension         oex;
  application/x-xpinstall               xpi;
  application/x-cocoa                   cco;
  application/x-java-archive-diff       jardiff;
  application/x-java-jnlp-file          jnlp;
  application/x-makeself                run;
  application/x-perl                    pl pm;
  application/x-pilot                   prc pdb;
  application/x-rar-compressed          rar;
  application/x-redhat-package-manager  rpm;
  application/x-sea                     sea;
  application/x-shockwave-flash         swf;
  application/x-stuffit                 sit;
  application/x-tcl                     tcl tk;
  application/x-x509-ca-cert            der pem crt;
  application/x-bittorrent              torrent;
  application/zip                       zip;

  application/octet-stream              bin exe dll;
  application/octet-stream              deb;
  application/octet-stream              dmg;
  application/octet-stream              iso img;
  application/octet-stream              msi msp msm;
  application/octet-stream              safariextz;

  text/css                              css;
  text/html                             html htm shtml;
  text/mathml                           mml;
  text/plain                            txt;
  text/vnd.sun.j2me.app-descriptor      jad;
  text/vnd.wap.wml                      wml;
  text/vtt                              vtt;
  text/x-component                      htc;
  text/x-vcard                          vcf;

}

END_HEREDOC
)


echo "$VAR" > /etc/nginx/mime.types 



VAR=$(cat <<'END_HEREDOC'

# Prevent clients from accessing hidden files (starting with a dot)
 # This is particularly important if you store .htpasswd files in the site hierarchy
 location ~* (?:^|/)\. {
    deny all;
 }

 # Prevent clients from accessing to backup/config/source files
 location ~* (?:\.(?:bak|config|sql|fla|psd|ini|log|sh|inc|swp|dist)|~)$ {
    deny all;
 }  
 
 
# Expire rules for static content

 # No default expire rule. This config mirrors that of apache as outlined in the
 # html5-boilerplate .htaccess file. However, nginx applies rules by location,
 # the apache rules are defined by type. A concequence of this difference is that
 # if you use no file extension in the url and serve html, with apache you get an
 # expire time of 0s, with nginx you'd get an expire header of one month in the
 # future (if the default expire rule is 1 month). Therefore, do not use a
 # default expire rule with nginx unless your site is completely static

 # cache.appcache, your document html and data
 location ~* \.(?:manifest|appcache|html?|xml|json)$ {
  expires -1;
  access_log logs/static.log;
 }

 # Feed
 location ~* \.(?:rss|atom)$ {
  expires 1h;
  add_header Cache-Control "public";
 }

 # Media: images, icons, video, audio, HTC
 location ~* \.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webm|htc)$ {
  expires 1M;
  access_log off;
  add_header Cache-Control "public";
 }

 # CSS and Javascript
 location ~* \.(?:css|js)$ {
  expires 1y;
  access_log off;
  add_header Cache-Control "public";
 }

 # WebFonts
 # If you are NOT using cross-domain-fonts.conf, uncomment the following directive
 # location ~* \.(?:ttf|ttc|otf|eot|woff)$ {
 #  expires 1M;
 #  access_log off;
 #  add_header Cache-Control "public";
 # }

 
 # Cross domain webfont access
 location ~* \.(?:ttf|ttc|otf|eot|woff)$ {
    add_header "Access-Control-Allow-Origin" "*";

    # Also, set cache rules for webfonts.
    #
    # See http://wiki.nginx.org/HttpCoreModule#location
    # And https://github.com/h5bp/server-configs/issues/85
    # And https://github.com/h5bp/server-configs/issues/86
    expires 1M;
    access_log off;
    add_header Cache-Control "public";
 } 


END_HEREDOC
)

echo "$VAR" > /etc/nginx/helpers/extra.conf












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

  ## Set Document Root
	root /var/www/example.com/;

  ## Set Directory Index
	index index.php index.html index.htm;

  ## PHP: Redirect all request to index.php
	location / 
	{
		try_files $uri $uri/ /index.php$is_args$args;
	}

  ## PHP: Pass all PHP request to PHP-FPM
	location ~ \.php$ {
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_pass unix:/var/run/php5-fpm.sock;
		fastcgi_index index.php;
		include fastcgi_params;
	}
	
	include /etc/nginx/helpers/extra.conf
}



END_HEREDOC
)

echo "$VAR" > /etc/nginx/sites-available/example.com
